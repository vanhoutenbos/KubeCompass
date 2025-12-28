#!/bin/bash
# test-rbac.sh - Automated RBAC Testing
# Tests all RBAC roles with kubectl auth can-i

set -euo pipefail

NAMESPACE="${NAMESPACE:-webshop}"
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BOLD}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   RBAC Testing for KubeCompass        ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════╝${NC}"
echo ""

# Test result counters
PASSED=0
FAILED=0

# Function to test permission
test_permission() {
    local user="$1"
    local verb="$2"
    local resource="$3"
    local namespace="$4"
    local expected="$5"  # "yes" or "no"
    
    echo -n "Testing $user: $verb $resource in $namespace ... "
    
    if kubectl auth can-i "$verb" "$resource" -n "$namespace" --as "$user" &>/dev/null; then
        result="yes"
    else
        result="no"
    fi
    
    if [ "$result" = "$expected" ]; then
        echo -e "${GREEN}✅ $result (expected)${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ $result (expected $expected)${NC}"
        ((FAILED++))
    fi
}

# Test with service account
test_sa_permission() {
    local sa="$1"
    local verb="$2"
    local resource="$3"
    local namespace="$4"
    local expected="$5"
    
    echo -n "Testing SA $sa: $verb $resource in $namespace ... "
    
    if kubectl auth can-i "$verb" "$resource" -n "$namespace" --as "system:serviceaccount:$namespace:$sa" &>/dev/null; then
        result="yes"
    else
        result="no"
    fi
    
    if [ "$result" = "$expected" ]; then
        echo -e "${GREEN}✅ $result (expected)${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ $result (expected $expected)${NC}"
        ((FAILED++))
    fi
}

echo -e "${BOLD}Test 1: Namespace Admin${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_permission "namespace-admin" "create" "deployments" "$NAMESPACE" "yes"
test_permission "namespace-admin" "delete" "deployments" "$NAMESPACE" "yes"
test_permission "namespace-admin" "create" "secrets" "$NAMESPACE" "yes"
test_permission "namespace-admin" "delete" "namespaces" "$NAMESPACE" "no"  # Cannot delete namespace itself
echo ""

echo -e "${BOLD}Test 2: Namespace Developer${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_permission "namespace-developer" "create" "deployments" "$NAMESPACE" "yes"
test_permission "namespace-developer" "delete" "deployments" "$NAMESPACE" "no"  # Cannot delete deployments
test_permission "namespace-developer" "get" "secrets" "$NAMESPACE" "yes"
test_permission "namespace-developer" "create" "secrets" "$NAMESPACE" "no"  # Cannot create secrets
test_permission "namespace-developer" "delete" "pods" "$NAMESPACE" "yes"  # Can delete pods
echo ""

echo -e "${BOLD}Test 3: Namespace Viewer${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_permission "namespace-viewer" "get" "pods" "$NAMESPACE" "yes"
test_permission "namespace-viewer" "list" "deployments" "$NAMESPACE" "yes"
test_permission "namespace-viewer" "create" "deployments" "$NAMESPACE" "no"
test_permission "namespace-viewer" "delete" "pods" "$NAMESPACE" "no"
test_permission "namespace-viewer" "get" "secrets" "$NAMESPACE" "no"  # Cannot read secret values
test_permission "namespace-viewer" "list" "secrets" "$NAMESPACE" "yes"  # Can list secret names
echo ""

echo -e "${BOLD}Test 4: Cluster Reader${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_permission "cluster-reader" "get" "pods" "$NAMESPACE" "yes"
test_permission "cluster-reader" "get" "nodes" "" "yes"
test_permission "cluster-reader" "list" "namespaces" "" "yes"
test_permission "cluster-reader" "create" "deployments" "$NAMESPACE" "no"
test_permission "cluster-reader" "delete" "pods" "$NAMESPACE" "no"
echo ""

echo -e "${BOLD}Test 5: CI/CD Deployer (Service Account)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_sa_permission "ci-cd-deployer" "create" "deployments" "$NAMESPACE" "yes"
test_sa_permission "ci-cd-deployer" "update" "services" "$NAMESPACE" "yes"
test_sa_permission "ci-cd-deployer" "get" "secrets" "$NAMESPACE" "yes"
test_sa_permission "ci-cd-deployer" "create" "secrets" "$NAMESPACE" "no"  # Security: cannot create secrets
test_sa_permission "ci-cd-deployer" "delete" "deployments" "$NAMESPACE" "no"  # Cannot delete deployments
echo ""

echo -e "${BOLD}Test 6: Pod Exec Restricted${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_permission "pod-exec-restricted" "get" "pods" "$NAMESPACE" "yes"
test_permission "pod-exec-restricted" "get" "pods/log" "$NAMESPACE" "yes"
test_permission "pod-exec-restricted" "create" "pods/portforward" "$NAMESPACE" "yes"
test_permission "pod-exec-restricted" "create" "pods/exec" "$NAMESPACE" "no"  # Security: no shell access
test_permission "pod-exec-restricted" "create" "deployments" "$NAMESPACE" "no"
echo ""

echo -e "${BOLD}Test 7: Cross-Namespace Isolation${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_permission "namespace-admin" "get" "pods" "tenant-a" "no"  # Cannot access other namespaces
test_permission "namespace-admin" "get" "pods" "tenant-b" "no"
echo ""

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
    exit 0
else
    echo -e "${RED}${BOLD}❌ Some tests failed. Review RBAC configuration.${NC}"
    exit 1
fi
