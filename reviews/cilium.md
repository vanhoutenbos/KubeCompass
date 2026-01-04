# Cilium Review

**Domain**: Networking (CNI)  
**Decision Type**: Foundational (Priority 0)  
**Tested Version**: v1.14.5  
**Test Date**: 2024-12-20  
**Reviewer**: @vanhoutenbos (KubeCompass maintainer)  
**GitHub Stars**: 17,000+  
**CNCF Status**: Graduated

---

## Overview

Cilium is a modern CNI (Container Network Interface) plugin built on eBPF technology. Unlike traditional CNIs that rely on iptables, Cilium operates directly in the Linux kernel for high-performance networking and security.

**What makes it special**:
- **eBPF-based**: Kernel-level networking without iptables overhead
- **L7 visibility**: HTTP, gRPC, Kafka protocol awareness for fine-grained policies
- **Hubble**: Built-in network observability and flow visualization
- **Native encryption**: Optional transparent encryption for inter-node traffic
- **Service mesh capabilities**: Can replace or complement Istio/Linkerd

---

## Installation & Setup

### Dependencies
- **Kubernetes**: 1.23+ (tested on 1.28)
- **Linux kernel**: 4.9+ (5.10+ recommended for full eBPF features)
- **Helm**: For standard installation (or cilium CLI)

### Installation Method
```bash
# Using Cilium CLI (recommended)
cilium install --version 1.14.5

# Or using Helm
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version 1.14.5 \
  --namespace kube-system \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true
```

### Time to Working State
- **Installation**: 5-10 minutes (depends on cluster size)
- **Initial testing**: Pods communicate immediately after CNI is ready
- **Hubble UI**: Additional 2-3 minutes to deploy observability components

### Documentation Quality
✅ **Excellent**
- Comprehensive official docs (https://docs.cilium.io)
- Step-by-step installation guides for all major cloud providers
- Rich examples for network policies, service mesh, observability
- Active Slack community and GitHub discussions

---

## Core Functionality

### Does It Work as Advertised?
✅ **Yes, and exceeds expectations**

**Basic networking**:
- Pod-to-pod communication works flawlessly
- Service discovery and DNS resolution reliable
- Supports standard Kubernetes NetworkPolicy resources

**L7 network policies**:
- Tested HTTP-based policies (allow only GET `/api/public`, deny POST)
- Kafka topic-level policies work as documented
- gRPC method filtering tested successfully

**Hubble observability**:
- Flow logs provide incredible visibility into pod communications
- UI is intuitive for troubleshooting network issues
- CLI (`hubble observe`) is powerful for debugging

### Performance Observations
- **eBPF advantage**: Noticeably lower CPU usage compared to Calico in similar cluster
- **Latency**: No measurable latency increase vs. host networking
- **Scalability**: Tested up to 100 nodes and 1000+ pods without issues
- **Resource usage**: ~200MB memory per node for Cilium agent (acceptable)

### Limitations Found
- **Kernel version dependency**: Some advanced features require kernel 5.10+
  - Older kernels (4.9-5.4) work but with reduced functionality
  - Check kernel version before committing: `uname -r`
- **Learning curve**: L7 policies use CiliumNetworkPolicy CRDs (not standard K8s NetworkPolicy)
  - Requires learning new YAML structure
  - More powerful but less portable than standard policies
- **Hubble storage**: Flow logs are ephemeral (stored in memory)
  - For long-term retention, export to external system (Loki, Elasticsearch)

---

## Integration

### How It Integrates with the Stack

**CNI only**:
- Replaces default CNI (Calico, Flannel, etc.)
- Works with any Kubernetes cluster (cloud or on-prem)
- No changes needed to application code

**With observability**:
- Hubble metrics integrate with Prometheus (via `cilium-operator`)
- Flow logs can be exported to Loki, Elasticsearch, or S3
- Grafana dashboards available for network visibility

**With service mesh**:
- Can act as a lightweight service mesh (L7 load balancing, traffic management)
- Or run alongside Istio/Linkerd (Cilium handles networking, mesh handles app traffic)

**With security tools**:
- CiliumNetworkPolicy works alongside OPA/Gatekeeper and Kyverno
- Hubble flow logs integrate with SIEM for security monitoring
- Tetragon (Cilium's runtime security tool) leverages same eBPF infrastructure

### Standards Compliance
- ✅ Implements Kubernetes NetworkPolicy API (standard)
- ✅ CNI plugin spec compliant
- ➕ Extends with CiliumNetworkPolicy for L7 features (non-standard but well-documented)

### Interoperability
- Works with all standard Kubernetes controllers (Deployments, Services, Ingress)
- Compatible with cloud load balancers (ELB, Azure LB, GCP LB)
- Tested with NGINX Ingress, cert-manager, Prometheus stack — no conflicts

---

## Failure Scenarios

### What We Broke and How

**Test 1: Cilium agent crash**
- **Method**: Killed `cilium-agent` pod on one node
- **Impact**: Pods on that node lost network connectivity temporarily
- **Recovery**: DaemonSet restarted agent within 10 seconds, connectivity restored
- **Blast radius**: Only affected pods on single node (as expected)
- **Observability**: Hubble logs showed network disruption clearly

**Test 2: etcd corruption (Cilium state store)**
- **Method**: Deleted Cilium's identity and endpoint CRDs
- **Impact**: Network policies temporarily unenforced
- **Recovery**: Cilium operator recreated CRDs automatically within 30 seconds
- **Lesson**: Cilium state is Kubernetes-native (CRDs), so k8s backup (Velero) protects it

**Test 3: Kernel panic on node**
- **Method**: Forced kernel panic to simulate catastrophic node failure
- **Impact**: All pods on node failed (not Cilium-specific)
- **Recovery**: Kubernetes rescheduled pods to healthy nodes, networking restored within 2 minutes
- **Lesson**: eBPF maps are lost on kernel failure, but Cilium re-initializes on pod start

### Recovery Process
- **Automated**: DaemonSet ensures Cilium agent runs on every node
- **Manual**: Rarely needed; if Cilium operator fails, restart it: `kubectl rollout restart -n kube-system deployment/cilium-operator`

### Observability of Failures
✅ **Excellent**
- Cilium agent logs are detailed and actionable
- Hubble UI shows connection failures in real-time
- Prometheus metrics expose agent health and policy drop counts
- `cilium status` command provides instant health check

---

## Upgrade Path

### Ease of Version Upgrades
✅ **Smooth, but plan for minor downtime**

**Tested upgrade**: v1.13.x → v1.14.5
- **Method**: `cilium upgrade --version 1.14.5` (CLI) or Helm upgrade
- **Downtime**: ~30 seconds per node as agent restarts (rolling upgrade)
- **Impact**: Existing connections maintained, new connections briefly delayed
- **Rollback**: Supported via `cilium rollback` or Helm rollback

### Breaking Changes
- **Minor versions**: Usually backward-compatible (1.13 → 1.14 was seamless)
- **Major versions**: Read release notes carefully (e.g., 1.12 → 1.13 changed BPF filesystem path)
- **Deprecation policy**: Well-communicated in docs, usually 2-3 minor versions before removal

### Rollback Capability
✅ **Yes**
- Helm/CLI rollback works reliably
- Tested downgrade from 1.14.5 → 1.13.8 successfully
- Recommendation: Test upgrades in non-prod first (as with any CNI change)

---

## Operational Overhead

### Configuration Complexity
**Medium**

**Initial setup**: Simple (one Helm command or cilium CLI)
**Advanced features**: Require learning CiliumNetworkPolicy CRDs and eBPF concepts

**Example complexity**:
- Basic NetworkPolicy: ✅ Easy (standard Kubernetes API)
- L7 HTTP policies: 📖 Medium (need to understand Cilium CRDs)
- Service mesh mode: 📚 Expert (deep understanding of networking and mesh concepts)

**Recommendation**: Start with basic NetworkPolicy, layer in L7 policies as needed

### Ongoing Maintenance
**Low to medium**

**Routine tasks**:
- **Version upgrades**: Quarterly or as security patches released (1-2 hours, tested in non-prod first)
- **Policy tuning**: As applications change (ongoing, but manageable)
- **Monitoring**: Check Prometheus metrics and Hubble for anomalies (automated alerting recommended)

**Troubleshooting**:
- `cilium status` — quick health check
- `cilium connectivity test` — validates networking end-to-end
- `hubble observe` — real-time flow debugging
- Hubble UI — visual troubleshooting for non-CLI users

### Skill Level Required
- **Basic operation**: Junior/mid-level engineer (if using standard NetworkPolicy)
- **Advanced features**: Senior engineer with networking knowledge (L7 policies, service mesh)
- **Troubleshooting**: Understanding of Linux networking and eBPF helpful but not mandatory (Cilium CLI abstracts most complexity)

---

## Exit Strategy

### Migration Complexity
⚠️ **High** (as with any CNI change)

**Why it's hard**:
- CNI is deeply embedded in cluster networking
- Changing CNI requires draining and restarting all nodes (or rebuilding cluster)
- Custom CiliumNetworkPolicy resources won't work with other CNIs (must rewrite as standard NetworkPolicy)

**Migration path** (if leaving Cilium):
1. Audit all CiliumNetworkPolicy resources
2. Rewrite as standard Kubernetes NetworkPolicy (lose L7 features)
3. Test replacement CNI in parallel cluster
4. Blue-green switch or rebuild cluster with new CNI
5. Migrate workloads to new cluster

**Estimated effort**: Varies by cluster size and complexity

### Data Portability
✅ **Good**
- **Hubble flow logs**: Export to standard formats (JSON, protobuf) before switching
- **Policies**: Standard NetworkPolicy resources are portable; CiliumNetworkPolicy are not
- **No vendor lock-in**: All configuration is open-source CRDs and YAML

### Vendor Lock-In Risk
**Low**

- **Open-source**: Apache 2.0 license, no proprietary components
- **CNCF Graduated**: Vendor-neutral governance, community-driven
- **Commercial support**: Available from Isovalent (creators of Cilium), but optional
- **Self-hosted**: No SaaS dependency

**Mitigation**: Use standard NetworkPolicy where possible, layer in CiliumNetworkPolicy only for advanced use cases

---

## Verdict

### Strengths
✅ **Modern eBPF architecture**: High performance, low overhead  
✅ **L7 network policies**: Fine-grained security (HTTP, gRPC, Kafka)  
✅ **Hubble observability**: Best-in-class network visibility without extra tools  
✅ **CNCF Graduated**: Production-proven, vendor-neutral, long-term support  
✅ **Service mesh capabilities**: Can reduce complexity by replacing separate mesh  
✅ **Active community**: Fast issue resolution, frequent releases, great docs  

### Weaknesses
⚠️ **Kernel dependency**: Requires relatively modern kernel (4.9+, prefer 5.10+)  
⚠️ **Learning curve**: CiliumNetworkPolicy is more complex than standard policies  
⚠️ **Migration cost**: Hard to switch away from once adopted (true of any CNI)  
⚠️ **Hubble storage**: Ephemeral flow logs (must export for long-term retention)  

### Recommended For
✅ **Enterprise environments**: Finance, government, multi-tenant platforms  
✅ **Security-first organizations**: Zero-trust networking, compliance requirements  
✅ **Observability-heavy stacks**: Teams that value deep network visibility  
✅ **Greenfield clusters**: Starting fresh without legacy CNI constraints  

### Avoid If
❌ **Very old kernels**: Stuck on kernel < 4.9 (upgrade kernel first)  
❌ **Extreme simplicity needed**: Flannel or cloud-native CNI might be easier  
❌ **Already invested in another CNI**: Migration cost may not justify benefits  

---

## Personal Opinion

**TL;DR: Cilium is the CNI we wish existed 5 years ago.**

After testing Cilium extensively, it's hard to go back to iptables-based CNIs. The eBPF architecture is not just faster — it fundamentally changes what's possible (L7 policies, deep observability, encryption). Hubble alone is worth the learning curve; troubleshooting network issues is 10x easier with flow visualization.

**Trade-offs**: The CiliumNetworkPolicy CRDs add complexity and lock-in risk. However, for enterprise environments that need zero-trust networking and compliance, the L7 policy capabilities are essential. You *can* start with standard NetworkPolicy and layer in Cilium-specific features later, which reduces risk.

**Bottom line**: If you're building a new cluster and your kernel is 5.10+, **choose Cilium**. If you're migrating from Calico/Flannel, the ROI depends on whether you need L7 policies and Hubble observability. For simple setups, the migration cost might not be worth it — but for multi-tenant, security-focused environments, Cilium is the clear winner.

**Confidence level**: High — we'd deploy this in production without hesitation.

---

## Additional Resources

- **Official docs**: https://docs.cilium.io
- **GitHub**: https://github.com/cilium/cilium
- **Slack**: https://cilium.io/slack
- **Getting started**: https://docs.cilium.io/en/stable/gettingstarted/
- **Hubble UI demo**: https://docs.cilium.io/en/stable/gettingstarted/hubble/

---

*Last updated: 2024-12-20 | Next review: 2025-06-20*
