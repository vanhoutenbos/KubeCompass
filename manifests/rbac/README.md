# RBAC Examples for KubeCompass

**Role-Based Access Control examples for testing and production use**

---

## Overview

This directory contains production-ready RBAC configurations following the **principle of least privilege**.

### What's Included

| File | Purpose | Use Case |
|------|---------|----------|
| `namespace-admin.yaml` | Full admin within namespace | Team lead, senior developers |
| `namespace-developer.yaml` | Deploy & view within namespace | Regular developers |
| `namespace-viewer.yaml` | Read-only within namespace | Junior devs, QA, support |
| `cluster-reader.yaml` | Read-only cluster-wide | SRE, monitoring tools |
| `ci-cd-deployer.yaml` | CI/CD pipeline service account | GitLab CI, GitHub Actions |
| `pod-exec-restricted.yaml` | Allow pod access, no exec | Debugging without shell access |
| `secret-reader.yaml` | Read secrets (specific namespace) | Apps needing config |
| `multitenant-isolation.yaml` | Tenant isolation example | Multi-tenant platforms |

---

## Quick Start

```bash
# Apply all RBAC examples
kubectl apply -f manifests/rbac/

# Test with specific user
kubectl auth can-i get pods --as=developer@example.com --namespace=webshop

# Verify permissions
kubectl auth can-i --list --as=developer@example.com --namespace=webshop
```

---

## Examples

### 1. Namespace Admin (Full Control in Namespace)

**Use Case**: Team lead who manages all resources in their team's namespace

```yaml
# namespace-admin.yaml
---
# Role: Full control within namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: namespace-admin
  namespace: webshop
  labels:
    rbac.kubecompass.io/role: admin
    rbac.kubecompass.io/scope: namespace
rules:
# All resources in core API group
- apiGroups: [""]
  resources: ["*"]
  verbs: ["*"]

# All resources in apps API group
- apiGroups: ["apps"]
  resources: ["*"]
  verbs: ["*"]

# All resources in batch API group
- apiGroups: ["batch"]
  resources: ["*"]
  verbs: ["*"]

# Networking resources
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses", "networkpolicies"]
  verbs: ["*"]

# Autoscaling
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["*"]

---
# RoleBinding: Bind admin role to team leads
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: webshop-admins
  namespace: webshop
  labels:
    rbac.kubecompass.io/binding: admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: namespace-admin
subjects:
# Specific users
- kind: User
  name: alice@example.com
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: bob@example.com
  apiGroup: rbac.authorization.k8s.io

# Or bind to group (if using OIDC)
- kind: Group
  name: webshop-team-leads
  apiGroup: rbac.authorization.k8s.io
```

### 2. Namespace Developer (Deploy & View)

**Use Case**: Developer who can deploy apps but not delete critical resources

```yaml
# namespace-developer.yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: namespace-developer
  namespace: webshop
  labels:
    rbac.kubecompass.io/role: developer
rules:
# Pods: full control (for debugging)
- apiGroups: [""]
  resources: ["pods", "pods/log", "pods/status"]
  verbs: ["get", "list", "watch", "create", "delete"]

# Pod exec (for debugging)
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]

# Deployments: create and update (but not delete)
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]

# Services: full control
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

# ConfigMaps and Secrets: read and create (not delete)
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list", "watch", "create", "update"]

# Jobs: full control
- apiGroups: ["batch"]
  resources: ["jobs", "cronjobs"]
  verbs: ["get", "list", "watch", "create", "update", "delete"]

# Ingress: read and update
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]

# Events: read-only (for debugging)
- apiGroups: [""]
  resources: ["events"]
  verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: webshop-developers
  namespace: webshop
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: namespace-developer
subjects:
- kind: Group
  name: webshop-developers
  apiGroup: rbac.authorization.k8s.io
```

### 3. Namespace Viewer (Read-Only)

**Use Case**: Junior developers, QA, support team who need to view but not modify

```yaml
# namespace-viewer.yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: namespace-viewer
  namespace: webshop
  labels:
    rbac.kubecompass.io/role: viewer
rules:
# View all standard resources
- apiGroups: ["", "apps", "batch", "autoscaling", "networking.k8s.io"]
  resources:
  - pods
  - pods/log
  - pods/status
  - deployments
  - replicasets
  - statefulsets
  - services
  - configmaps
  - secrets  # Controversial: view secrets? Consider removing
  - jobs
  - cronjobs
  - ingresses
  - horizontalpodautoscalers
  - events
  verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: webshop-viewers
  namespace: webshop
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: namespace-viewer
subjects:
- kind: Group
  name: webshop-qa
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: webshop-support
  apiGroup: rbac.authorization.k8s.io
```

### 4. Cluster Reader (Read-Only Cluster-Wide)

**Use Case**: SRE team, monitoring systems, audit tools

```yaml
# cluster-reader.yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-reader
  labels:
    rbac.kubecompass.io/role: reader
    rbac.kubecompass.io/scope: cluster
rules:
# View all resources cluster-wide
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]

# Explicitly deny these sensitive operations
# (cannot be done with RBAC alone - use admission controllers)
# - Viewing secret values (can see secret names though)
# - Exec into pods
# - Port-forward

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: sre-cluster-readers
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-reader
subjects:
- kind: Group
  name: sre-team
  apiGroup: rbac.authorization.k8s.io

# Monitoring service account
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring
```

### 5. CI/CD Deployer (Service Account)

**Use Case**: GitLab CI, GitHub Actions, Jenkins deployment pipelines

```yaml
# ci-cd-deployer.yaml
---
# ServiceAccount for CI/CD
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-deployer
  namespace: webshop
  labels:
    app.kubernetes.io/name: gitlab-deployer
    app.kubernetes.io/managed-by: kubecompass

---
# Role: Deploy and update applications
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ci-deployer
  namespace: webshop
rules:
# Deployments: create, update, patch (no delete for safety)
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]

# StatefulSets: read-only (manual ops only)
- apiGroups: ["apps"]
  resources: ["statefulsets"]
  verbs: ["get", "list", "watch"]

# Services: full control
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

# ConfigMaps: create and update
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]

# Secrets: create and update (consider External Secrets instead)
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]

# Pods: read-only (for checking deployment status)
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "watch"]

# Ingress: full control
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

# Jobs: full control
- apiGroups: ["batch"]
  resources: ["jobs"]
  verbs: ["get", "list", "watch", "create", "delete"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-deployer-binding
  namespace: webshop
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ci-deployer
subjects:
- kind: ServiceAccount
  name: gitlab-deployer
  namespace: webshop

---
# How to get token for CI/CD:
# kubectl create token gitlab-deployer -n webshop --duration=87600h
# Or create long-lived secret (not recommended):
# apiVersion: v1
# kind: Secret
# metadata:
#   name: gitlab-deployer-token
#   namespace: webshop
#   annotations:
#     kubernetes.io/service-account.name: gitlab-deployer
# type: kubernetes.io/service-account-token
```

### 6. Pod Exec Restricted (Debug Without Shell)

**Use Case**: Allow viewing logs and port-forward, but not shell access

```yaml
# pod-exec-restricted.yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-debugger-no-exec
  namespace: webshop
rules:
# Pods: read access
- apiGroups: [""]
  resources: ["pods", "pods/status"]
  verbs: ["get", "list", "watch"]

# Logs: read access
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list"]

# Port-forward: allowed
- apiGroups: [""]
  resources: ["pods/portforward"]
  verbs: ["get", "list", "create"]

# Exec: DENIED (not listed = no permission)
# - apiGroups: [""]
#   resources: ["pods/exec"]
#   verbs: ["create"]  # <-- Intentionally omitted

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: junior-devs-debug
  namespace: webshop
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-debugger-no-exec
subjects:
- kind: Group
  name: junior-developers
  apiGroup: rbac.authorization.k8s.io
```

### 7. Secret Reader (Specific Namespace)

**Use Case**: Application service account that needs to read secrets

```yaml
# secret-reader.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: webshop-app
  namespace: webshop

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader
  namespace: webshop
rules:
# ConfigMaps: read-only
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch"]

# Secrets: read-only (specific secrets via ResourceNames for more security)
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
  resourceNames:
  - webshop-db-credentials
  - webshop-api-keys
  - webshop-tls-cert

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: webshop-app-secrets
  namespace: webshop
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: secret-reader
subjects:
- kind: ServiceAccount
  name: webshop-app
  namespace: webshop
```

### 8. Multi-Tenant Isolation

**Use Case**: SaaS platform with tenant namespaces, prevent cross-tenant access

```yaml
# multitenant-isolation.yaml
---
# Tenant A - Namespace Admin
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: tenant-admin
  namespace: tenant-a
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tenant-a-admin
  namespace: tenant-a
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: tenant-admin
subjects:
- kind: User
  name: tenant-a-admin@example.com
  apiGroup: rbac.authorization.k8s.io

---
# Tenant B - Separate Namespace, No Access to Tenant A
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: tenant-admin
  namespace: tenant-b
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tenant-b-admin
  namespace: tenant-b
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: tenant-admin
subjects:
- kind: User
  name: tenant-b-admin@example.com
  apiGroup: rbac.authorization.k8s.io

---
# Platform Admin - Cluster-wide access
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: platform-admins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin  # Built-in role
subjects:
- kind: Group
  name: platform-team
  apiGroup: rbac.authorization.k8s.io
```

---

## Testing RBAC

### Manual Testing

```bash
# Test as specific user
kubectl auth can-i create deployments --as=developer@example.com --namespace=webshop
# Output: yes/no

# List all permissions for user
kubectl auth can-i --list --as=developer@example.com --namespace=webshop

# Test with service account
kubectl auth can-i get secrets --as=system:serviceaccount:webshop:gitlab-deployer --namespace=webshop
```

### Automated Testing Script

```bash
#!/bin/bash
# test-rbac.sh

set -e

NAMESPACE="webshop"
USER="developer@example.com"

echo "Testing RBAC for $USER in namespace $NAMESPACE"
echo "=============================================="

# Test cases
tests=(
  "get:pods:yes"
  "delete:pods:yes"
  "create:deployments:yes"
  "delete:deployments:no"
  "get:secrets:yes"
  "delete:secrets:no"
  "exec:pods:yes"
  "delete:namespaces:no"
)

for test in "${tests[@]}"; do
  IFS=':' read -r verb resource expected <<< "$test"
  
  result=$(kubectl auth can-i "$verb" "$resource" --as="$USER" --namespace="$NAMESPACE" 2>/dev/null)
  
  if [ "$result" = "$expected" ]; then
    echo "✅ PASS: $verb $resource = $result"
  else
    echo "❌ FAIL: $verb $resource = $result (expected $expected)"
  fi
done
```

Run tests:
```bash
chmod +x test-rbac.sh
./test-rbac.sh
```

---

## Best Practices

### 1. Principle of Least Privilege
- Start with minimal permissions
- Add permissions as needed
- Review quarterly

### 2. Use Groups Over Individual Users
```yaml
# Bad: Binding to individual users
subjects:
- kind: User
  name: alice@example.com
- kind: User
  name: bob@example.com

# Good: Binding to groups
subjects:
- kind: Group
  name: webshop-developers
```

### 3. Service Accounts for Automation
- Never use user credentials in CI/CD
- Use short-lived tokens when possible
- Audit service account usage

### 4. Namespace Isolation
- Don't grant cluster-wide permissions unless necessary
- Use RoleBindings (namespace-scoped) over ClusterRoleBindings

### 5. Regular Audits
```bash
# List all ClusterRoleBindings
kubectl get clusterrolebindings -o wide

# Find who has cluster-admin
kubectl get clusterrolebindings -o json | jq '.items[] | select(.roleRef.name=="cluster-admin") | .metadata.name'

# Audit specific user
kubectl get rolebindings,clusterrolebindings --all-namespaces -o json | \
  jq '.items[] | select(.subjects[]?.name=="alice@example.com")'
```

---

## Common Pitfalls

### ❌ Overly Permissive Wildcards
```yaml
# Bad: Too permissive
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
```

### ❌ Granting cluster-admin to Service Accounts
```yaml
# Bad: CI/CD with cluster-admin
- kind: ServiceAccount
  name: gitlab-deployer
  namespace: default
roleRef:
  kind: ClusterRole
  name: cluster-admin  # ❌ Too much power!
```

### ❌ Viewing Secrets by Default
```yaml
# Questionable: Should viewers see secrets?
- apiGroups: [""]
  resources: ["secrets"]  # ⚠️ Consider removing
  verbs: ["get", "list"]
```

---

## Integration with OIDC

Example with Google OAuth:

```yaml
# kube-apiserver flags
--oidc-issuer-url=https://accounts.google.com
--oidc-client-id=<your-client-id>
--oidc-username-claim=email
--oidc-groups-claim=groups
```

Then RBAC bindings automatically work:
```yaml
subjects:
- kind: Group
  name: webshop-developers@example.com  # Google Group
  apiGroup: rbac.authorization.k8s.io
```

---

## Related Documentation

- 🔒 [Network Policies](../networking/README.md) - Network-level security
- 🧪 [Testing Guide](../../tests/README.md) - Security testing methodology
- 📖 [Kubernetes RBAC Docs](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

---

**Last Updated**: December 28, 2025  
**Maintainers**: Platform Engineering Team
