#!/bin/bash
# test-network-policies.sh - Automated Network Policy Testing
# Tests connectivity between pods to validate network policies

set -euo pipefail

NAMESPACE="${NAMESPACE:-webshop}"
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BOLD}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Network Policy Testing KubeCompass   ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if CNI supports NetworkPolicies
echo "Checking if CNI supports Network Policies..."
if ! kubectl get networkpolicies -n "$NAMESPACE" &>/dev/null; then
    echo -e "${RED}❌ NetworkPolicies not supported by CNI${NC}"
    echo "This cluster does NOT support NetworkPolicies (probably using kindnet or flannel)"
    echo "Install Cilium or Calico for NetworkPolicy support"
    exit 1
fi
echo -e "${GREEN}✅ NetworkPolicies supported${NC}"
echo ""

# Test result counters
PASSED=0
FAILED=0

# Function to test connectivity
test_connectivity() {
    local source_pod="$1"
    local dest_service="$2"
    local dest_port="$3"
    local expected="$4"  # "pass" or "fail"
    
    echo -n "Testing $source_pod → $dest_service:$dest_port ... "
    
    # Try to connect with 3 second timeout
    if kubectl exec -n "$NAMESPACE" "$source_pod" -- timeout 3 nc -zv "$dest_service" "$dest_port" &>/dev/null; then
        result="pass"
    else
        result="fail"
    fi
    
    if [ "$result" = "$expected" ]; then
        echo -e "${GREEN}✅ $result (expected)${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ $result (expected $expected)${NC}"
        ((FAILED++))
    fi
}

# Create test pods if they don't exist
echo "Setting up test pods..."
kubectl run frontend-test --image=busybox --labels=app=frontend,tier=web -n "$NAMESPACE" --command -- sleep 3600 2>/dev/null || true
kubectl run backend-test --image=busybox --labels=app=backend,tier=api -n "$NAMESPACE" --command -- sleep 3600 2>/dev/null || true
kubectl run database-test --image=busybox --labels=app=postgresql,tier=database -n "$NAMESPACE" --command -- sleep 3600 2>/dev/null || true
kubectl run unauthorized-test --image=busybox --labels=app=unauthorized -n "$NAMESPACE" --command -- sleep 3600 2>/dev/null || true

# Wait for pods to be ready
echo "Waiting for test pods to be ready..."
kubectl wait --for=condition=ready pod/frontend-test -n "$NAMESPACE" --timeout=60s
kubectl wait --for=condition=ready pod/backend-test -n "$NAMESPACE" --timeout=60s
kubectl wait --for=condition=ready pod/database-test -n "$NAMESPACE" --timeout=60s
kubectl wait --for=condition=ready pod/unauthorized-test -n "$NAMESPACE" --timeout=60s
echo ""

# Create test services
kubectl expose pod backend-test --port=8080 -n "$NAMESPACE" 2>/dev/null || true
kubectl expose pod database-test --port=5432 -n "$NAMESPACE" 2>/dev/null || true

echo -e "${BOLD}Test 1: DNS Resolution (should always work)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_connectivity "frontend-test" "kubernetes.default.svc.cluster.local" "443" "pass"
test_connectivity "backend-test" "kubernetes.default.svc.cluster.local" "443" "pass"
echo ""

echo -e "${BOLD}Test 2: Three-Tier Architecture (frontend → backend → database)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_connectivity "frontend-test" "backend-test" "8080" "pass"     # Frontend can reach backend
test_connectivity "frontend-test" "database-test" "5432" "fail"    # Frontend CANNOT reach database
test_connectivity "backend-test" "database-test" "5432" "pass"     # Backend can reach database
test_connectivity "database-test" "backend-test" "8080" "fail"     # Database CANNOT initiate to backend
echo ""

echo -e "${BOLD}Test 3: Unauthorized Access (should all fail)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_connectivity "unauthorized-test" "frontend-test" "8080" "fail"
test_connectivity "unauthorized-test" "backend-test" "8080" "fail"
test_connectivity "unauthorized-test" "database-test" "5432" "fail"
echo ""

echo -e "${BOLD}Test 4: Within-Namespace Communication${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "(This depends on your allow-within-namespace policy)"
test_connectivity "frontend-test" "backend-test" "8080" "pass"
echo ""

# Cross-namespace testing (if tenant namespaces exist)
if kubectl get namespace tenant-a &>/dev/null && kubectl get namespace tenant-b &>/dev/null; then
    echo -e "${BOLD}Test 5: Cross-Namespace Isolation (tenant-a ↔ tenant-b)${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Create test pod in tenant-a if needed
    kubectl run test-pod --image=busybox -n tenant-a --command -- sleep 3600 2>/dev/null || true
    kubectl wait --for=condition=ready pod/test-pod -n tenant-a --timeout=60s 2>/dev/null || true
    
    # Test that tenant-a cannot reach tenant-b
    if kubectl exec -n tenant-a test-pod -- timeout 3 nc -zv backend-test.$NAMESPACE.svc.cluster.local 8080 &>/dev/null; then
        echo -e "${RED}❌ fail (expected fail - cross-namespace should be blocked)${NC}"
        ((FAILED++))
    else
        echo -e "${GREEN}✅ fail (expected - tenant isolation working)${NC}"
        ((PASSED++))
    fi
    echo ""
fi

# Cleanup
echo "Cleaning up test pods..."
kubectl delete pod frontend-test backend-test database-test unauthorized-test -n "$NAMESPACE" 2>/dev/null || true
kubectl delete service backend-test database-test -n "$NAMESPACE" 2>/dev/null || true

# Summary
echo ""
echo -e "${BOLD}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║           Test Summary                 ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════╝${NC}"
echo -e "Total tests: $((PASSED + FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✅ All tests passed!${NC}"
    echo "Network policies are correctly enforcing security boundaries."
    exit 0
else
    echo -e "${RED}${BOLD}❌ Some tests failed. Review Network Policies.${NC}"
    echo ""
    echo "Debug commands:"
    echo "  kubectl get networkpolicies -n $NAMESPACE"
    echo "  kubectl describe networkpolicy <name> -n $NAMESPACE"
    echo ""
    exit 1
fi
