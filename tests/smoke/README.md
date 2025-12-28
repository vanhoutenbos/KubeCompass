# Smoke Tests

Basic validation tests for Kind clusters. Run these after cluster creation to ensure everything works.

## Quick Start

### Windows
```powershell
.\tests\smoke\run-tests.ps1
```

### Linux/WSL
```bash
./tests/smoke/run-tests.sh
```

## Test Coverage

1. **Cluster API Connectivity** - Verifies kubectl can reach the API server
2. **Node Readiness** - Ensures all nodes are in Ready state
3. **System Pods Health** - Checks all kube-system pods are running
4. **DNS Resolution** - Tests CoreDNS functionality
5. **Namespace Creation** - Validates RBAC and API access
6. **Pod Deployment** - Tests basic workload scheduling
7. **Service Creation** - Validates service networking

## Expected Results

All tests should pass on a healthy cluster:

```
═══════════════════════════════════════════════════
  Test Results
═══════════════════════════════════════════════════

Total tests: 7
Passed:      7
Failed:      0

✓ All tests passed! Cluster is operational.
```

## Running Against Specific Cluster

```powershell
# Windows
.\tests\smoke\run-tests.ps1 -Context kind-kubecompass-cilium

# Linux
./tests/smoke/run-tests.sh kind-kubecompass-calico
```

## Troubleshooting

### DNS tests fail on Cilium/Calico clusters
This is expected if you haven't installed the CNI yet. Install the CNI first:

```bash
# Cilium
cilium install

# Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

### System pods not running
Wait a few minutes for pods to start. Check status:

```bash
kubectl get pods -n kube-system
```

### Pod deployment timeout
Increase sleep time in test script or check node resources:

```bash
kubectl describe nodes
```

## Integration with CI/CD

These tests can be used in automated pipelines:

```yaml
# Example GitHub Actions
- name: Run smoke tests
  run: ./tests/smoke/run-tests.sh
```

Exit codes:
- `0` - All tests passed
- `1` - One or more tests failed
