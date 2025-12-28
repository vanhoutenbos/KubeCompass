# Security Testing for KubeCompass

Automated tests for RBAC and Network Policies.

## RBAC Testing

Test all RBAC roles with `kubectl auth can-i`:

```bash
# Run all RBAC tests
./test-rbac.sh

# Test specific namespace
NAMESPACE=production ./test-rbac.sh
```

**What it tests**:
- ✅ Namespace admin (create/delete permissions)
- ✅ Namespace developer (deploy but not delete)
- ✅ Namespace viewer (read-only)
- ✅ Cluster reader (cluster-wide read)
- ✅ CI/CD deployer service account
- ✅ Pod exec restrictions
- ✅ Cross-namespace isolation

## Network Policy Testing

Test connectivity between pods:

```bash
# Run all network policy tests
./test-network-policies.sh

# Test specific namespace
NAMESPACE=webshop ./test-network-policies.sh
```

**What it tests**:
- ✅ DNS resolution (must always work)
- ✅ Three-tier architecture (frontend → backend → database)
- ✅ Unauthorized access (should be blocked)
- ✅ Within-namespace communication
- ✅ Cross-namespace isolation (multi-tenancy)

## Prerequisites

```bash
# Install netcat for connectivity tests
kubectl run test-pod --image=nicolaka/netshoot --command -- sleep 3600

# Or use busybox (lighter)
kubectl run test-pod --image=busybox --command -- sleep 3600
```

## CI/CD Integration

```yaml
# .gitlab-ci.yml
security-tests:
  stage: test
  script:
    - kubectl config use-context test-cluster
    - ./tests/security/test-rbac.sh
    - ./tests/security/test-network-policies.sh
  only:
    - main
```

## Related Documentation

- 🔐 [RBAC Examples](../../manifests/rbac/README.md)
- 🔐 [Network Policy Examples](../../manifests/networking/README.md)
