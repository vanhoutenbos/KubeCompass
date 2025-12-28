# CNI Comparison Matrix

Comprehensive comparison of Container Network Interfaces for Kubernetes.

## Quick Recommendation

**Choose Cilium** unless:
- You need BGP routing → **Calico**
- You have existing Calico expertise → **Calico**
- You want absolute simplicity → **Kindnet** (dev only)
- Cloud-managed cluster with native CNI → **Cloud provider CNI**

## Comparison Matrix

| Feature | Cilium | Calico | Flannel | Weave | Cloud Native CNIs |
|---------|--------|--------|---------|-------|-------------------|
| **Dataplane** | eBPF | iptables/eBPF | VXLAN | mesh | varies |
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Network Policies** | L3-L7 | L3-L4 | ❌ None | L3 | varies |
| **Observability** | Hubble (built-in) | Basic | Minimal | Basic | varies |
| **Service Mesh** | ✅ Built-in | ❌ Need Istio | ❌ No | ❌ No | ❌ Need separate |
| **Learning Curve** | Medium-High | Medium | Low | Medium | Low-Medium |
| **Production Maturity** | ⭐⭐⭐⭐⭐ CNCF | ⭐⭐⭐⭐⭐ Production | ⭐⭐⭐⭐ Stable | ⭐⭐⭐ Legacy | ⭐⭐⭐⭐⭐ |
| **Vendor Lock-in** | Low | Low | Low | Medium | **HIGH** |
| **BGP Support** | Limited | ✅ Full | ❌ No | ❌ No | varies |
| **Multi-cluster** | ✅ Native | ✅ Via config | ❌ No | ✅ Yes | varies |
| **Encryption** | ✅ WireGuard/IPSec | ✅ WireGuard/IPSec | ❌ No | ✅ Yes | varies |

## Detailed Analysis

### Cilium ⭐ Recommended

**Best for:** Modern Kubernetes platforms prioritizing observability and security

**Pros:**
- ✅ **eBPF-based** - Superior performance, no iptables overhead
- ✅ **Hubble** - Built-in network observability (flow visualization)
- ✅ **L7 network policies** - Application-aware security
- ✅ **Service mesh capabilities** - Without sidecar overhead
- ✅ **CNCF Graduated** - Production-ready, strong community
- ✅ **Identity-based security** - Beyond IP-based rules
- ✅ **Kube-proxy replacement** - Even better performance

**Cons:**
- ❌ **Kernel requirements** - Needs Linux 4.9+ (usually fine)
- ❌ **Complexity** - More features = steeper learning curve
- ❌ **BGP limitations** - Not as mature as Calico for BGP

**Use Cases:**
- Modern cloud-native platforms
- Security-focused environments
- Multi-tenant clusters
- When you need deep observability
- Service mesh without sidecars

**Kind Testing:**
```yaml
# kind/cluster-cilium.yaml
networking:
  disableDefaultCNI: true
  kubeProxyMode: "none"  # Cilium replaces kube-proxy
```

### Calico

**Best for:** Traditional networks, BGP routing, enterprise environments

**Pros:**
- ✅ **Mature** - Battle-tested, years of production use
- ✅ **BGP support** - Excellent for on-prem, peering with physical routers
- ✅ **Flexible dataplane** - iptables or eBPF
- ✅ **Strong network policies** - Industry standard
- ✅ **Enterprise support** - Tigera backing
- ✅ **Documentation** - Extensive, well-maintained

**Cons:**
- ❌ **iptables overhead** - Unless using eBPF mode
- ❌ **No service mesh** - Need separate solution
- ❌ **Basic observability** - Need additional tools
- ❌ **More traditional** - Less "cloud-native" feel

**Use Cases:**
- On-premise data centers
- BGP networking requirements
- Existing Calico expertise
- Enterprise compliance requirements
- Hybrid cloud with physical network integration

**Kind Testing:**
```yaml
# kind/cluster-calico.yaml
networking:
  disableDefaultCNI: true
  podSubnet: "192.168.0.0/16"  # Calico default
```

### Flannel

**Best for:** Simple dev/test environments, learning Kubernetes

**Pros:**
- ✅ **Simple** - Easy to understand and deploy
- ✅ **Lightweight** - Minimal resource usage
- ✅ **Stable** - Core functionality is rock-solid
- ✅ **Low complexity** - Great for learning

**Cons:**
- ❌ **No network policies** - Security limitation
- ❌ **Basic features only** - No advanced capabilities
- ❌ **Limited observability** - Minimal visibility
- ❌ **Not for production** - Missing too many features

**Use Cases:**
- Learning Kubernetes
- Dev/test environments
- Simple non-production workloads
- When you need something quick

### Weave Net

**Best for:** Legacy environments (consider alternatives)

**Status:** ⚠️ **Less actively maintained**

**Pros:**
- ✅ **Mesh networking** - Automatic network topology
- ✅ **Easy setup** - Historically simple
- ✅ **Encryption** - Built-in

**Cons:**
- ❌ **Performance** - Not competitive with modern CNIs
- ❌ **Maintenance concerns** - Weaveworks shutdown
- ❌ **Better alternatives exist** - Cilium or Calico preferred

**Recommendation:** Choose Cilium or Calico instead.

### Cloud Provider CNIs

**Azure CNI, AWS VPC CNI, GKE native networking**

**Best for:** Managed Kubernetes when you want cloud integration

**Pros:**
- ✅ **Cloud integration** - Native VPC/VNET networking
- ✅ **Support** - Cloud provider backed
- ✅ **Performance** - Optimized for cloud
- ✅ **Simpler ops** - Provider manages complexity

**Cons:**
- ❌ **Vendor lock-in** - ⚠️ **CRITICAL** - Hard to migrate
- ❌ **Cloud-specific** - Not portable
- ❌ **IP exhaustion** - Pod IPs from VPC/VNET
- ❌ **Less control** - Provider dictates features

**Use Cases:**
- Managed Kubernetes (AKS, EKS, GKE)
- Need native cloud networking
- Want provider support
- ⚠️ **Accept vendor lock-in**

**Migration risk:** 🔴 **HIGH** - Changing CNI in production is **extremely difficult**

## Decision Framework

### Start Here: What's your primary concern?

```
Need BGP routing?
├─ YES → Calico
└─ NO → Continue

Need deep observability?
├─ YES → Cilium
└─ NO → Continue

Want service mesh capabilities?
├─ YES → Cilium
└─ NO → Continue

Maximum simplicity (dev only)?
├─ YES → Flannel or Kindnet
└─ NO → Continue

Managed cluster, prefer native?
├─ YES → Cloud provider CNI ⚠️ (lock-in)
└─ NO → Cilium (default)
```

### Testing Strategy

**Test locally with Kind:**

1. **Cilium cluster** - Test eBPF, Hubble, L7 policies
2. **Calico cluster** - Test network policies, traditional networking
3. **Compare** - Performance, features, complexity

**Don't mix CNIs in one cluster!** Use separate Kind clusters.

## Performance Characteristics

### Cilium (eBPF)
- **Latency:** ~10-50μs overhead
- **Throughput:** Near line-rate
- **CPU:** Low (no iptables rules)
- **Scalability:** Excellent (10k+ pods)

### Calico (iptables)
- **Latency:** ~50-200μs overhead
- **Throughput:** Good
- **CPU:** Higher (iptables rule processing)
- **Scalability:** Good (validated to 5k+ nodes)

### Calico (eBPF mode)
- **Latency:** Similar to Cilium
- **Throughput:** Near line-rate
- **CPU:** Low
- **Scalability:** Excellent

### Flannel
- **Latency:** ~100-300μs overhead
- **Throughput:** Moderate
- **CPU:** Low
- **Scalability:** Moderate (1k pods)

## Network Policy Capabilities

| Policy Type | Cilium | Calico | Flannel | Weave |
|-------------|--------|--------|---------|-------|
| **L3 (IP)** | ✅ | ✅ | ❌ | ✅ |
| **L4 (Port)** | ✅ | ✅ | ❌ | ✅ |
| **L7 (HTTP)** | ✅ | ❌ | ❌ | ❌ |
| **DNS-based** | ✅ | ✅ | ❌ | ❌ |
| **Identity-based** | ✅ | ❌ | ❌ | ❌ |
| **Egress Gateway** | ✅ | ✅ | ❌ | ❌ |
| **Host policies** | ✅ | ✅ | ❌ | ❌ |

## Observability

| Feature | Cilium | Calico | Flannel | Weave |
|---------|--------|--------|---------|-------|
| **Flow logs** | Hubble (built-in) | Via Tigera | ❌ | Basic |
| **Metrics** | Prometheus native | Prometheus | Minimal | Basic |
| **UI** | Hubble UI | Via Tigera | ❌ | ❌ |
| **Service map** | ✅ | Via Tigera | ❌ | ❌ |
| **L7 visibility** | ✅ | ❌ | ❌ | ❌ |

## Migration Complexity

**Changing CNI in production: 🔴 EXTREMELY DIFFICULT**

| From/To | Cilium | Calico | Cloud CNI |
|---------|--------|--------|-----------|
| **None (new cluster)** | Easy | Easy | Easy |
| **Cilium** | - | Hard | **AVOID** |
| **Calico** | Hard | - | **AVOID** |
| **Cloud CNI** | **AVOID** | **AVOID** | - |

**Recommendation:** Choose your CNI early. Changing later requires:
- Cluster downtime
- Complex migration process
- Risk of data loss
- Potential IP readdressing

## License & Support

| CNI | License | Enterprise Support |
|-----|---------|-------------------|
| **Cilium** | Apache 2.0 | Isovalent |
| **Calico** | Apache 2.0 | Tigera |
| **Flannel** | Apache 2.0 | Community |
| **Weave** | Apache 2.0 | ⚠️ Uncertain |
| **Cloud CNI** | Proprietary | Cloud provider |

## Testing with KubeCompass

### Test Cilium
```bash
./kind/create-cluster.sh cilium
cilium install
cilium status
cilium connectivity test
```

### Test Calico
```bash
./kind/create-cluster.sh calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
kubectl get pods -n kube-system
calicoctl node status
```

### Compare Performance
```bash
# Deploy same workload to both clusters
# Measure latency, throughput, resource usage
# Document findings in reviews/
```

## Final Recommendation

**For KubeCompass testing:**
1. ✅ **Cilium** - Primary recommendation
2. ✅ **Calico** - Alternative for BGP needs
3. ❌ **Others** - Not recommended for new deployments

**For production:**
- **Start with Cilium** unless you have specific Calico requirements
- **Avoid cloud CNIs** unless vendor lock-in is acceptable
- **Test locally first** with Kind clusters

## Resources

- [Cilium Documentation](https://docs.cilium.io/)
- [Calico Documentation](https://docs.projectcalico.org/)
- [CNCF CNI Specification](https://github.com/containernetworking/cni)
- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

---

**Next:** Test both Cilium and Calico in Kind clusters to validate for your use case.
