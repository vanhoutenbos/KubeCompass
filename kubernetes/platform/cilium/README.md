# Cilium Installation and Configuration

## Overview

Cilium is the chosen CNI (Container Network Interface) for the webshop platform, providing:
- High-performance eBPF-based networking
- L3/L4/L7 network policies
- Observability via Hubble
- Multi-cluster networking (future)

## Installation

### Prerequisites

1. Kubernetes cluster with kernel >= 4.9.17
2. Helm 3.x installed
3. kubectl access to cluster

### Install via Helm

```bash
# Add Cilium Helm repository
helm repo add cilium https://helm.cilium.io/
helm repo update

# Install Cilium
helm install cilium cilium/cilium --version 1.14.5 \
  --namespace kube-system \
  --set operator.replicas=2 \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}" \
  --set ipam.mode=kubernetes \
  --set kubeProxyReplacement=strict \
  --set k8sServiceHost=<API_SERVER_IP> \
  --set k8sServicePort=6443 \
  --set l7Proxy=true \
  --set bpf.masquerade=true
```

Replace `<API_SERVER_IP>` with your Kubernetes API server IP.

### Verify Installation

```bash
# Check Cilium pods
kubectl get pods -n kube-system -l k8s-app=cilium

# Check Cilium status
cilium status --wait

# Run connectivity test
cilium connectivity test
```

## Hubble UI Access

Hubble UI is for **operations only**, not exposed publicly.

```bash
# Port-forward to Hubble UI
kubectl port-forward -n kube-system svc/hubble-ui 12000:80

# Access at: http://localhost:12000
```

## Network Policies

Cilium supports advanced network policies:

### L3/L4 Policies (IP/Port)

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-frontend-to-backend
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
```

### L7 Policies (HTTP)

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-api-paths
spec:
  endpointSelector:
    matchLabels:
      app: api
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
          path: "/api/.*"
```

### Egress Policies (External APIs)

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-payment-api
spec:
  endpointSelector:
    matchLabels:
      app: payment-service
  egress:
  - toFQDNs:
    - matchName: "api.payment-provider.com"
    toPorts:
    - ports:
      - port: "443"
        protocol: TCP
```

## Observability

### Hubble CLI

```bash
# Install Hubble CLI
export HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
curl -L --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-amd64.tar.gz{,.sha256sum}
tar xzvf hubble-linux-amd64.tar.gz
sudo mv hubble /usr/local/bin

# Port-forward to Hubble Relay
kubectl port-forward -n kube-system svc/hubble-relay 4245:80

# Observe flows
hubble observe --server localhost:4245

# Observe specific namespace
hubble observe --namespace webshop

# Observe dropped packets
hubble observe --verdict DROPPED
```

### Metrics

Cilium exports Prometheus metrics:
- `/metrics` on port 9090 (cilium-agent)
- Hubble metrics on port 9091

Metrics include:
- `cilium_forward_count_total`: Forwarded packets
- `cilium_drop_count_total`: Dropped packets
- `cilium_policy_l7_total`: L7 policy decisions
- `hubble_flows_processed_total`: Observed flows

## Troubleshooting

### Check Cilium Status

```bash
kubectl -n kube-system exec -it ds/cilium -- cilium status --verbose
```

### Check Network Policies

```bash
kubectl -n kube-system exec -it ds/cilium -- cilium policy get
```

### Debug Connectivity

```bash
# Check endpoint connectivity
kubectl -n kube-system exec -it ds/cilium -- cilium endpoint list

# Monitor policy decisions
kubectl -n kube-system exec -it ds/cilium -- cilium monitor --type policy-verdict
```

### Common Issues

1. **Pods not getting IP addresses**
   - Check IPAM mode: `kubectl get cm -n kube-system cilium-config -o yaml | grep ipam`
   - Verify IP pool: `kubectl get ciliumnodes`

2. **Network policies not working**
   - Verify policy is applied: `cilium policy get`
   - Check endpoint labels: `cilium endpoint list`
   - Monitor policy verdicts: `cilium monitor --type policy-verdict`

3. **Hubble not showing flows**
   - Verify Hubble is enabled: `cilium status | grep Hubble`
   - Check Hubble relay: `kubectl get pods -n kube-system -l k8s-app=hubble-relay`

## Upgrade

```bash
# Check current version
helm list -n kube-system

# Upgrade Cilium
helm upgrade cilium cilium/cilium --version <NEW_VERSION> \
  --namespace kube-system \
  --reuse-values

# Monitor upgrade
kubectl rollout status daemonset/cilium -n kube-system
```

## Layer 0 Alignment

- ✅ **Vendor Independence**: Open-source, works with any Kubernetes
- ✅ **Security by Design**: L3/L4/L7 policies, eBPF-based
- ✅ **Observability**: Hubble for network visibility
- ✅ **Multi-cluster Ready**: Supports future multi-region architecture

## References

- [Cilium Documentation](https://docs.cilium.io/)
- [Hubble Documentation](https://docs.cilium.io/en/stable/observability/hubble/)
- [Network Policy Examples](https://docs.cilium.io/en/stable/policy/)
