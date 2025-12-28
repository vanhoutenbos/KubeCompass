#!/usr/bin/env bash
# Smoke Test Suite for Kind Cluster
# Validates basic cluster functionality

set -euo pipefail

# Configuration
CONTEXT="${1:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}→${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
failure() { echo -e "${RED}✗${NC} $*"; }
test_header() { echo -e "${YELLOW}TEST:${NC} $*"; }

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  KubeCompass - Smoke Test Suite${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Set context if provided
if [[ -n "$CONTEXT" ]]; then
    kubectl config use-context "$CONTEXT" &> /dev/null
    info "Using context: $CONTEXT"
fi

CURRENT_CONTEXT=$(kubectl config current-context)
info "Current context: $CURRENT_CONTEXT"
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: Cluster connectivity
test_header "1. Cluster API connectivity"
if kubectl cluster-info &> /dev/null; then
    success "Cluster API is reachable"
    ((TESTS_PASSED++))
else
    failure "Cannot reach cluster API"
    ((TESTS_FAILED++))
fi

# Test 2: Nodes are ready
test_header "2. Node readiness"
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
READY_COUNT=$(kubectl get nodes --no-headers | grep -c " Ready" || true)

if [[ "$NODE_COUNT" -eq "$READY_COUNT" ]]; then
    success "All $NODE_COUNT node(s) are ready"
    ((TESTS_PASSED++))
else
    failure "Only $READY_COUNT of $NODE_COUNT nodes are ready"
    ((TESTS_FAILED++))
fi

# Test 3: System pods running
test_header "3. System pods health"
SYSTEM_POD_COUNT=$(kubectl get pods -n kube-system --no-headers | wc -l)
RUNNING_POD_COUNT=$(kubectl get pods -n kube-system --no-headers | grep -c "Running" || true)

if [[ "$SYSTEM_POD_COUNT" -eq "$RUNNING_POD_COUNT" ]]; then
    success "All $SYSTEM_POD_COUNT system pods are running"
    ((TESTS_PASSED++))
else
    failure "Only $RUNNING_POD_COUNT of $SYSTEM_POD_COUNT system pods are running"
    ((TESTS_FAILED++))
fi

# Test 4: DNS resolution
test_header "4. DNS resolution"
if kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default &> /dev/null; then
    success "DNS resolution works"
    ((TESTS_PASSED++))
else
    failure "DNS resolution failed"
    ((TESTS_FAILED++))
fi

# Test 5: Create namespace
test_header "5. Namespace creation"
if kubectl create namespace smoke-test &> /dev/null; then
    success "Namespace creation successful"
    ((TESTS_PASSED++))
    kubectl delete namespace smoke-test &> /dev/null
else
    failure "Namespace creation failed"
    ((TESTS_FAILED++))
fi

# Test 6: Deploy test pod
test_header "6. Pod deployment"
if kubectl run smoke-test-pod --image=nginx:alpine --restart=Never -n default &> /dev/null; then
    sleep 10
    POD_STATUS=$(kubectl get pod smoke-test-pod -n default -o jsonpath='{.status.phase}')
    
    if [[ "$POD_STATUS" == "Running" ]]; then
        success "Pod deployment successful"
        ((TESTS_PASSED++))
    else
        failure "Pod is not running (status: $POD_STATUS)"
        ((TESTS_FAILED++))
    fi
    
    kubectl delete pod smoke-test-pod -n default &> /dev/null
else
    failure "Pod deployment failed"
    ((TESTS_FAILED++))
fi

# Test 7: Service creation
test_header "7. Service creation"
if kubectl create service clusterip smoke-test-svc --tcp=80:80 -n default &> /dev/null; then
    success "Service creation successful"
    ((TESTS_PASSED++))
    kubectl delete service smoke-test-svc -n default &> /dev/null
else
    failure "Service creation failed"
    ((TESTS_FAILED++))
fi

# Results
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test Results${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
echo "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed:      $TESTS_PASSED${NC}"
echo -e "${RED}Failed:      $TESTS_FAILED${NC}"
echo ""

if [[ "$TESTS_FAILED" -eq 0 ]]; then
    success "All tests passed! Cluster is operational."
    exit 0
else
    failure "Some tests failed. Please investigate."
    exit 1
fi
