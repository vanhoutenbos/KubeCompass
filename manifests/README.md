# Manifests

Kubernetes manifests organized by layer and concern.

## Structure

```
manifests/
  ├── base/              # Priority 2 - Test workloads
  ├── namespaces/        # Priority 0 - Namespace definitions
  ├── rbac/              # Priority 0 - RBAC policies
  └── networking/        # Priority 0/1 - Network policies
```

## Layer Philosophy

### Priority 0 - Platform Foundation
- Namespaces
- RBAC
- Network policies
- Security policies
- Base monitoring

### Priority 1 - Application Support
- Data services
- Messaging
- Caching
- Service mesh (future)

### Priority 2 - Applications
- Test workloads
- Demo applications
- Use case implementations

## Quick Deploy

### Deploy namespaces
```bash
kubectl apply -f manifests/namespaces/
```

### Deploy test workload
```bash
kubectl apply -f manifests/base/
```

### Verify
```bash
kubectl get all -n kube-compass-test
```

## Guidelines

✅ **DO**:
- Keep manifests declarative
- Use labels consistently
- Document resource limits
- Version control everything
- Use descriptive names

❌ **DON'T**:
- Hard-code values
- Mix layers in one file
- Use `latest` tags in production-like tests
- Deploy without validation
- Skip resource limits

## Labels

All manifests use consistent labeling:

```yaml
metadata:
  labels:
    layer: "0|1|2"           # Platform layer
    managed-by: kubecompass  # Management ownership
    type: <type>             # Resource type/category
    app: <name>              # Application name (Priority 2)
```

## Next Steps

1. Deploy namespaces
2. Run smoke tests
3. Deploy test workloads
4. Add RBAC policies
5. Configure network policies
