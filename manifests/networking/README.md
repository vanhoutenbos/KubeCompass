# Network Policy Examples for KubeCompass

**Network segmentation and zero-trust networking examples**

---

## Overview

Network Policies provide **Layer 3/4 firewall rules** for Kubernetes pods. They enforce **zero-trust** networking by default-denying all traffic and explicitly allowing required connections.

### Prerequisites

⚠️ **Network Policies require a CNI plugin that supports them**:
- ✅ **Cilium** (eBPF-based, recommended)
- ✅ **Calico** (iptables or eBPF)
- ✅ **Weave Net**
- ❌ **Kindnet** (Kind default) - does NOT support NetworkPolicies
- ❌ **Flannel** - does NOT support NetworkPolicies

```bash
# Test if NetworkPolicies are supported
kubectl apply -f test-netpol.yaml
kubectl describe networkpolicy test-policy
# If you see events, it's working
```

### What's Included

| File | Purpose | Use Case |
|------|---------|----------|
| `deny-all-default.yaml` | Default deny all traffic | Zero-trust baseline |
| `allow-dns.yaml` | Allow DNS lookups | Required for service discovery |
| `allow-within-namespace.yaml` | Namespace isolation | Multi-tenant clusters |
| `allow-ingress-to-frontend.yaml` | Expose frontend to ingress | Web applications |
| `allow-frontend-to-backend.yaml` | 3-tier architecture | Microservices |
| `allow-backend-to-database.yaml` | Database access control | Secure data layer |
| `allow-monitoring.yaml` | Prometheus scraping | Observability |
| `allow-egress-external.yaml` | Controlled external access | API calls, webhooks |
| `deny-cross-namespace.yaml` | Prevent namespace leakage | Multi-tenancy |

---

## Quick Start

```bash
# Apply all network policies
kubectl apply -f manifests/networking/

# Test connectivity
kubectl run test-pod --image=busybox --command -- sleep 3600
kubectl exec -it test-pod -- wget -O- http://frontend-service

# View applied policies
kubectl get networkpolicies -n webshop
kubectl describe networkpolicy allow-frontend-to-backend -n webshop
```

---

## Examples

### 1. Default Deny All (Zero-Trust Baseline)

**Use Case**: Start with zero-trust - deny all traffic, then explicitly allow

```yaml
# deny-all-default.yaml
---
# Deny all ingress traffic to all pods
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: webshop
  labels:
    policy.kubecompass.io/type: baseline
spec:
  podSelector: {}  # Applies to all pods
  policyTypes:
  - Ingress

---
# Deny all egress traffic from all pods
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-egress
  namespace: webshop
  labels:
    policy.kubecompass.io/type: baseline
spec:
  podSelector: {}  # Applies to all pods
  policyTypes:
  - Egress
```

**Result**: All pods in `webshop` namespace cannot send or receive traffic.

### 2. Allow DNS (Required!)

**Use Case**: Allow pods to resolve DNS names (required for service discovery)

```yaml
# allow-dns.yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: webshop
  labels:
    policy.kubecompass.io/type: infrastructure
spec:
  podSelector: {}  # Applies to all pods
  policyTypes:
  - Egress
  egress:
  # Allow DNS queries to kube-dns/CoreDNS
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    - podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
```

### 3. Allow Traffic Within Namespace

**Use Case**: Pods in same namespace can talk to each other (namespace isolation)

```yaml
# allow-within-namespace.yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-within-namespace
  namespace: webshop
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector: {}  # From any pod in same namespace
  egress:
  - to:
    - podSelector: {}  # To any pod in same namespace
```

### 4. Allow Ingress to Frontend

**Use Case**: Ingress controller can reach frontend pods

```yaml
# allow-ingress-to-frontend.yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-to-frontend
  namespace: webshop
spec:
  podSelector:
    matchLabels:
      app: frontend
      tier: web
  policyTypes:
  - Ingress
  ingress:
  # Allow from ingress controller namespace
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
```

### 5. Three-Tier Architecture (Frontend → Backend → Database)

**Frontend → Backend**:

```yaml
# allow-frontend-to-backend.yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: webshop
spec:
  podSelector:
    matchLabels:
      app: backend
      tier: api
  policyTypes:
  - Ingress
  ingress:
  # Allow from frontend pods only
  - from:
    - podSelector:
        matchLabels:
          app: frontend
          tier: web
    ports:
    - protocol: TCP
      port: 8080
```

**Backend → Database**:

```yaml
# allow-backend-to-database.yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-database
  namespace: webshop
spec:
  podSelector:
    matchLabels:
      app: postgresql
      tier: database
  policyTypes:
  - Ingress
  ingress:
  # Allow from backend pods only
  - from:
    - podSelector:
        matchLabels:
          app: backend
          tier: api
    ports:
    - protocol: TCP
      port: 5432

---
# Also configure egress from backend to database
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-egress-to-database
  namespace: webshop
spec:
  podSelector:
    matchLabels:
      app: backend
      tier: api
  policyTypes:
  - Egress
  egress:
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
  # Allow to database
  - to:
    - podSelector:
        matchLabels:
          app: postgresql
          tier: database
    ports:
    - protocol: TCP
      port: 5432
```

**Complete 3-Tier Policy**:

```yaml
# webshop-3tier-complete.yaml
---
# Frontend pods
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
  namespace: webshop
spec:
  podSelector:
    matchLabels:
      tier: web
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # Allow from ingress controller
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
  egress:
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
  # Allow to backend
  - to:
    - podSelector:
        matchLabels:
          tier: api
    ports:
    - protocol: TCP
      port: 8080

---
# Backend pods
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: webshop
spec:
  podSelector:
    matchLabels:
      tier: api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # Allow from frontend
  - from:
    - podSelector:
        matchLabels:
          tier: web
    ports:
    - protocol: TCP
      port: 8080
  egress:
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
  # Allow to database
  - to:
    - podSelector:
        matchLabels:
          tier: database
    ports:
    - protocol: TCP
      port: 5432
  # Allow to external APIs (example: payment gateway)
  - to:
    - namespaceSelector: {}
      podSelector: {}
    ports:
    - protocol: TCP
      port: 443

---
# Database pods
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
  namespace: webshop
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # Allow from backend only
  - from:
    - podSelector:
        matchLabels:
          tier: api
    ports:
    - protocol: TCP
      port: 5432
  egress:
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
  # No other egress (database should not initiate external connections)
```

### 6. Allow Monitoring (Prometheus)

**Use Case**: Prometheus can scrape metrics from all pods

```yaml
# allow-monitoring.yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-prometheus-scraping
  namespace: webshop
spec:
  podSelector:
    matchLabels:
      prometheus.io/scrape: "true"
  policyTypes:
  - Ingress
  ingress:
  # Allow from Prometheus in monitoring namespace
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: monitoring
    - podSelector:
        matchLabels:
          app: prometheus
    ports:
    - protocol: TCP
      port: 9090  # Prometheus metrics port
```

### 7. Allow Egress to External APIs

**Use Case**: Backend needs to call external payment gateway

```yaml
# allow-egress-external.yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-external-apis
  namespace: webshop
spec:
  podSelector:
    matchLabels:
      app: backend
      tier: api
  policyTypes:
  - Egress
  egress:
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
  
  # Allow HTTPS to specific external domains (via CIDR or FQDN)
  # Note: FQDN requires Cilium or Calico with DNS-based policies
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443
  
  # Or restrict by IP range (example: AWS API Gateway)
  - to:
    - ipBlock:
        cidr: 52.0.0.0/8  # Example AWS range
    ports:
    - protocol: TCP
      port: 443
```

**Cilium FQDN-based egress** (more powerful):

```yaml
# Requires Cilium CNI
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-payment-gateway
  namespace: webshop
spec:
  endpointSelector:
    matchLabels:
      app: backend
  egress:
  - toFQDNs:
    - matchName: "api.stripe.com"
    - matchName: "api.paypal.com"
    - matchPattern: "*.example.com"
  - toPorts:
    - ports:
      - port: "443"
        protocol: TCP
```

### 8. Deny Cross-Namespace Traffic (Multi-Tenancy)

**Use Case**: Prevent tenant-a from accessing tenant-b

```yaml
# deny-cross-namespace.yaml
---
# Tenant A: Only allow within namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-cross-namespace
  namespace: tenant-a
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # Only from same namespace
  - from:
    - podSelector: {}
  egress:
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
  # Only to same namespace
  - to:
    - podSelector: {}

---
# Tenant B: Same policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-cross-namespace
  namespace: tenant-b
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector: {}
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
  - to:
    - podSelector: {}
```

### 9. Allow Specific Service Communication (Label-Based)

**Use Case**: Service mesh-style policies using labels

```yaml
# service-to-service-labels.yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: cart-service-policy
  namespace: webshop
spec:
  podSelector:
    matchLabels:
      app: cart-service
  policyTypes:
  - Ingress
  ingress:
  # Allow from frontend
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  
  # Allow from checkout service
  - from:
    - podSelector:
        matchLabels:
          app: checkout-service
    ports:
    - protocol: TCP
      port: 8080
```

---

## Testing Network Policies

### Manual Testing

```bash
# Create test pods
kubectl run frontend --image=nginx --labels=app=frontend,tier=web -n webshop
kubectl run backend --image=nginx --labels=app=backend,tier=api -n webshop
kubectl run database --image=postgres:15 --labels=app=postgresql,tier=database -n webshop

# Test connectivity
kubectl exec -n webshop frontend -- curl -m 3 http://backend:8080
# Should succeed with allow-frontend-to-backend.yaml

kubectl exec -n webshop frontend -- curl -m 3 http://database:5432
# Should timeout (no policy allows frontend→database)

kubectl exec -n webshop backend -- curl -m 3 http://database:5432
# Should succeed with allow-backend-to-database.yaml
```

### Automated Testing Script

```bash
#!/bin/bash
# test-network-policies.sh

set -e

NAMESPACE="webshop"

echo "Testing Network Policies in $NAMESPACE"
echo "========================================"

# Test cases: source:dest:port:expected
tests=(
  "frontend:backend:8080:pass"
  "frontend:database:5432:fail"
  "backend:database:5432:pass"
  "backend:frontend:8080:fail"
  "database:backend:8080:fail"
)

for test in "${tests[@]}"; do
  IFS=':' read -r source dest port expected <<< "$test"
  
  echo -n "Testing $source → $dest:$port ... "
  
  if kubectl exec -n "$NAMESPACE" "$source" -- timeout 3 nc -zv "$dest" "$port" &>/dev/null; then
    result="pass"
  else
    result="fail"
  fi
  
  if [ "$result" = "$expected" ]; then
    echo "✅ $result (expected)"
  else
    echo "❌ $result (expected $expected)"
  fi
done
```

### Cilium Network Policy Testing

```bash
# If using Cilium, use cilium CLI for advanced testing
cilium connectivity test

# Check policy enforcement
cilium endpoint list
cilium policy get --all

# Trace connectivity
cilium policy trace <pod-id> <destination-ip> --port 8080
```

---

## Best Practices

### 1. Start with Default Deny
Always create baseline deny-all policies first:
```yaml
# Apply these FIRST
kubectl apply -f deny-all-default.yaml
kubectl apply -f allow-dns.yaml
```

### 2. Use Descriptive Labels
```yaml
# Good: Clear purpose
matchLabels:
  app: frontend
  tier: web
  role: public-facing

# Bad: Generic labels
matchLabels:
  name: app1
```

### 3. Document Your Policies
```yaml
metadata:
  name: allow-frontend-to-backend
  annotations:
    description: "Allows frontend pods to call backend API on port 8080"
    jira-ticket: "SEC-1234"
    reviewed-date: "2025-12-15"
```

### 4. Layer Your Policies
```yaml
# Multiple policies can apply to same pod - they are additive
# Base policy: deny all
# Policy 1: allow DNS
# Policy 2: allow ingress from frontend
# Policy 3: allow egress to database
```

### 5. Test Before Production
```bash
# Apply in test namespace first
kubectl apply -f network-policy.yaml -n test-webshop

# Verify connectivity
./test-network-policies.sh

# Then promote to production
kubectl apply -f network-policy.yaml -n prod-webshop
```

---

## Common Pitfalls

### ❌ Forgetting DNS
```yaml
# This will break EVERYTHING
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress: []  # ❌ No DNS allowed!
```

Always allow DNS:
```yaml
egress:
- to:
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: kube-system
  ports:
  - protocol: UDP
    port: 53
```

### ❌ Wrong Selector Combination
```yaml
# This does NOT work as expected
egress:
- to:
  - namespaceSelector:
      matchLabels:
        env: production
  - podSelector:
      matchLabels:
        app: backend
```
This means: "namespace=production OR pod=backend" (not AND)

Correct:
```yaml
egress:
- to:
  - namespaceSelector:
      matchLabels:
        env: production
    podSelector:
      matchLabels:
        app: backend
```

### ❌ Not Testing Changes
Always test connectivity after applying policies!

---

## CNI-Specific Features

### Cilium (Recommended)

**Advantages**:
- ✅ Layer 7 policies (HTTP, gRPC, Kafka)
- ✅ FQDN-based egress filtering
- ✅ Identity-based policies (not just IPs)
- ✅ Hubble UI for visualization

```yaml
# Layer 7 HTTP policy (Cilium-only)
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-specific-http-paths
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: frontend
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
      rules:
        http:
        - method: "GET"
          path: "/api/v1/products"
        - method: "POST"
          path: "/api/v1/orders"
```

### Calico

**Advantages**:
- ✅ Global network policies (cluster-wide)
- ✅ Service-based policies
- ✅ Rich GUI (Calico Cloud)

```yaml
# Global policy (Calico-only)
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: deny-egress-to-metadata-service
spec:
  selector: all()
  types:
  - Egress
  egress:
  - action: Deny
    destination:
      nets:
      - 169.254.169.254/32  # AWS metadata service
```

---

## Visualization

### Cilium Hubble UI
```bash
# Install Hubble (if using Cilium)
cilium hubble enable --ui

# Port-forward to access UI
cilium hubble ui
```

### Manual Visualization
```bash
# Generate policy diagram
kubectl get networkpolicies -n webshop -o yaml | \
  yq eval '.items[] | .metadata.name + " -> " + (.spec.podSelector.matchLabels | to_entries | .[].value)' -
```

---

## Related Documentation

- 🔐 [RBAC Examples](../rbac/README.md) - Identity-based access control
- 🧪 [Policy Testing](../../tests/policy/README.md) - Automated policy validation
- 📖 [Cilium Docs](https://docs.cilium.io/en/stable/policy/)
- 📖 [Calico Docs](https://docs.tigera.io/calico/latest/network-policy/)

---

**Last Updated**: December 28, 2025  
**Maintainers**: Platform Engineering Team
