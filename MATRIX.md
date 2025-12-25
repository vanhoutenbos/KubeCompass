# Decision Matrix

## How to Use This Matrix

This matrix helps you **prioritize decisions** when building a Kubernetes platform. Not all choices are equal — some are **foundational** (hard to change later), while others are **additive** (easy to introduce or swap).

### Filters & Preferences

You can filter tools by:
- **Maturity**: Alpha, Beta, Stable, CNCF Graduated
- **Stars threshold**: Minimum GitHub stars (1000+ recommended for production)
- **License**: Open-source only, permissive licenses, etc.
- **Vendor independence**: Foundation-hosted, multi-vendor, single-vendor
- **Complexity**: Simple, medium, expert-level

**Default view**: When no filters are applied, you'll see **our opinionated recommendations** based on hands-on testing, but all scores are shown so you can make your own informed choice.

---

## Layer 0: Foundational Decisions (Decide Day 1)

These decisions are **architecturally significant** and expensive to change later. Make them before deploying workloads.

### 1. Container Networking (CNI)

**Why it's foundational**: The CNI plugin defines how pods communicate, implements network policies, and affects observability. Changing it requires draining nodes and redeploying workloads.

| Tool | Maturity | Stars (GitHub) | Vendor Independence | Complexity | Key Features |
|------|----------|----------------|---------------------|------------|--------------|
| **Cilium** | CNCF Graduated | 17,000+ | Foundation | Medium | eBPF-based, L7 visibility, native encryption, Hubble observability |
| **Calico** | Stable | 5,500+ | Multi-vendor (Tigera) | Medium | Mature, strong network policies, BGP routing |
| **Flannel** | Stable | 8,500+ | Foundation (CNCF Sandbox) | Simple | Simple overlay networking, good for basic setups |

**Our Recommendation**: **Cilium** for enterprise environments

**Why**:
- **eBPF-based**: Modern, performant, kernel-level networking without iptables overhead
- **Security**: Built-in network policies with L7 awareness (HTTP, gRPC, Kafka)
- **Observability**: Hubble provides deep network visibility for troubleshooting
- **Compliance**: Audit logging for SOC 2, network flow tracking for ISO 27001
- **CNCF Graduated**: Battle-tested, long-term support, vendor-neutral

**When to choose alternatives**:
- **Calico**: If you need BGP routing, have existing Calico expertise, or prefer mature battle-tested solution
- **Flannel**: For simple, non-production environments where advanced features aren't needed

**Decision impact**: High — requires cluster rebuild or significant downtime to change

📖 **[See full Cilium review](reviews/cilium.md)**

---

### 2. GitOps Strategy

**Why it's foundational**: GitOps defines how your team deploys, how repositories are structured, and how changes are tracked. Retrofitting GitOps later requires restructuring all manifests and retraining teams.

**First question**: Do you want GitOps at all?

- **Yes**: Git as single source of truth, declarative deployments, audit trails
- **No**: Manual kubectl apply or CI/CD scripts pushing directly to cluster

**If yes**, then choose a tool:

| Tool | Maturity | Stars (GitHub) | Vendor Independence | Complexity | Key Features |
|------|----------|----------------|---------------------|------------|--------------|
| **Argo CD** | CNCF Graduated | 20,000+ | Foundation | Medium | Rich UI, multi-tenant, RBAC integration, SSO support |
| **Flux** | CNCF Graduated | 7,500+ | Foundation | Medium | GitOps-pure, toolkit approach, Helm support, image automation |

**Our Recommendation**: **Argo CD** for enterprise multi-tenant environments

**Why**:
- **User-friendly UI**: Non-technical stakeholders can view deployment status
- **Multi-tenancy**: Projects and RBAC for team isolation
- **SSO integration**: Works with Keycloak, Azure AD, Okta for compliance
- **Audit trails**: Change tracking for ISO 27001 compliance
- **CNCF Graduated**: Production-proven, widely adopted

**When to choose Flux**:
- More GitOps-pure philosophy (no UI, Git is the only interface)
- Prefer toolkit approach (compose Flux components as needed)
- Strong Helm and image automation requirements

**Decision impact**: High — changing GitOps tool requires repository restructuring, team retraining, and manifest migration

📖 **[See full Argo CD review](reviews/argo-cd.md)** *(coming soon)*

---

### 3. Identity & Access Control (RBAC)

**Why it's foundational**: Your RBAC model defines who can do what in the cluster. Retrofitting fine-grained access control is painful once teams are onboarded.

#### Native Kubernetes RBAC

**Required for all clusters** — built-in, no alternative.

**Best practices**:
- **Least privilege**: No cluster-admin by default
- **Namespace isolation**: Teams get namespaces with scoped permissions
- **Service accounts**: Per-application, scoped to namespace
- **Resource quotas**: Prevent resource exhaustion

#### Authentication Integration

**Goal**: Integrate corporate SSO instead of distributing kubeconfig files.

| Solution | Type | Key Features |
|----------|------|--------------|
| **Keycloak** | Open-source IdP | OIDC/SAML, self-hosted, highly configurable |
| **Azure AD / Okta / Auth0** | Managed IdP | Cloud-hosted, enterprise SSO, compliance-friendly |
| **Dex** | OIDC connector | Lightweight, connects Kubernetes to upstream IdP |

**Our Recommendation**: **Keycloak integration with Kubernetes RBAC**

**Why**:
- **Keycloak as IdP**: Provides OIDC/SAML integration for Kubernetes API server
- **RBAC enforcement**: Kubernetes RBAC still controls permissions, Keycloak only handles authentication
- **Compliance**: Centralized audit logs, MFA support, SSO for SOC 2/ISO 27001
- **Multi-tenancy**: Team-based role mappings through OIDC groups

**How it works**:
1. Keycloak authenticates users (SSO with OIDC)
2. Kubernetes API server validates OIDC tokens from Keycloak
3. Kubernetes RBAC maps OIDC groups to Roles/ClusterRoles
4. Users get scoped access based on their group membership

**Decision impact**: Medium-High — changing authentication requires user migration and kubectl config updates

---

### 4. Secrets Management

**Why it's foundational**: Secrets are needed by all workloads. Choosing a weak solution creates security debt that's expensive to fix.

**Golden rule**: **Never commit secrets to Git.**

| Tool | Maturity | Stars (GitHub) | Vendor Independence | Complexity | Key Features |
|------|----------|----------------|---------------------|------------|--------------|
| **HashiCorp Vault** | Stable | 30,000+ | Single-vendor (HashiCorp) | Expert | Dynamic secrets, encryption as service, audit logs, multi-cloud |
| **External Secrets Operator (ESO)** | CNCF Sandbox | 4,300+ | Foundation | Medium | Syncs secrets from external stores (Vault, AWS, Azure, GCP) |
| **Sealed Secrets** | Stable | 6,800+ | Single-vendor (Bitnami) | Simple | Encrypts secrets for Git storage, GitOps-friendly |

**Our Recommendation**: **HashiCorp Vault + External Secrets Operator**

**Why**:
- **Vault**: Industry-standard secrets management with encryption at rest, audit logging, dynamic secrets
- **ESO**: Kubernetes-native integration, syncs Vault secrets to Kubernetes Secrets automatically
- **Compliance**: Audit trails (SOC 2), encryption (GDPR), access control (ISO 27001)
- **Flexibility**: Can migrate between secret backends without changing application code

**When to choose Sealed Secrets**:
- Simpler GitOps flow (encrypted secrets in Git)
- Don't need dynamic secrets or complex rotation
- Want to avoid running Vault infrastructure

**Decision impact**: High — changing secrets management affects all workloads and requires secret migration

📖 **[See full Vault + ESO review](reviews/vault-eso.md)** *(coming soon)*

---

### 5. Storage Backend (Persistent Volumes)

**Why it's foundational**: Stateful workloads depend on storage. Migrating storage solutions risks data loss.

| Solution | Type | Vendor Independence | Complexity | Key Features |
|----------|------|---------------------|------------|--------------|
| **Cloud-native CSI** (EBS, Azure Disk, GCP PD) | Managed | Single-vendor (cloud) | Simple | Fully managed, automatic backups, high availability |
| **Rook-Ceph** | Self-hosted | Multi-vendor (CNCF Graduated) | Expert | Cloud-agnostic, distributed storage, S3-compatible |
| **Longhorn** | Self-hosted | Single-vendor (Rancher/SUSE) | Medium | Simple distributed storage, snapshot support |

**Our Recommendation**: **Cloud-native CSI drivers** (EBS, Azure Disk, GCP Persistent Disk)

**Why**:
- **Simplicity**: No storage cluster to manage
- **Reliability**: Cloud providers handle replication and backups
- **Performance**: SSD-backed, predictable I/O
- **Cost-effective**: Pay only for what you use

**When to choose Rook-Ceph**:
- Multi-cloud or on-prem requirements
- Need S3-compatible object storage
- Want cloud independence (avoid vendor lock-in)

**When to choose Longhorn**:
- Edge computing or resource-constrained environments
- Want simpler alternative to Ceph

**Decision impact**: High — migrating storage requires careful data migration and downtime

---

## Layer 1: Core Operations (Decide Within First Month)

These are important for production operations but can be added or changed with moderate effort.

### 6. Observability: Metrics

**Why it's Layer 1**: You need monitoring early, but metrics backends are swappable with some effort.

| Tool | Maturity | Stars (GitHub) | Vendor Independence | Complexity | Key Features |
|------|----------|----------------|---------------------|------------|--------------|
| **Prometheus** | CNCF Graduated | 54,000+ | Foundation | Medium | Industry standard, pull-based, PromQL, Alertmanager integration |
| **VictoriaMetrics** | Stable | 11,000+ | Multi-vendor | Medium | Prometheus-compatible, better compression, lower resource usage |
| **Datadog / New Relic** | Managed SaaS | Commercial | Single-vendor | Simple | Hosted, no infrastructure, broader APM features |

**Our Recommendation**: **Prometheus** (with optional Thanos for long-term storage)

**Why**:
- **CNCF Graduated**: Industry standard, universally supported
- **Ecosystem**: Grafana dashboards, Alertmanager, exporters for everything
- **PromQL**: Powerful query language for complex metrics
- **Compliance**: Self-hosted, no data leaves your infrastructure

**When to choose VictoriaMetrics**:
- Very large scale (millions of metrics)
- Need better resource efficiency than Prometheus

**Decision impact**: Medium — migrating metrics requires dashboard updates and alert rule changes

---

### 7. Observability: Logging

| Tool | Maturity | Stars (GitHub) | Vendor Independence | Complexity | Key Features |
|------|----------|----------------|---------------------|------------|--------------|
| **Loki** | CNCF Sandbox | 23,000+ | Foundation (Grafana) | Medium | Prometheus-like for logs, label-based indexing, low storage cost |
| **ELK Stack** (Elasticsearch, Logstash, Kibana) | Stable | 69,000+ | Multi-vendor (Elastic) | Expert | Full-text search, rich querying, expensive at scale |
| **Fluentd / Fluent Bit** | CNCF Graduated | 12,000+ | Foundation | Medium | Log forwarding and aggregation (often paired with Loki or ELK) |

**Our Recommendation**: **Loki + Grafana**

**Why**:
- **Unified observability**: Works with Prometheus and Grafana (same UI)
- **Cost-effective**: Indexes labels, not full text (cheaper storage)
- **Compliance**: Self-hosted, audit logs stay in your control

**Decision impact**: Medium — changing logging backend requires shipper reconfiguration

---

### 8. Ingress Controller

| Tool | Maturity | Stars (GitHub) | Vendor Independence | Complexity | Key Features |
|------|----------|----------------|---------------------|------------|--------------|
| **NGINX Ingress** | Stable | 17,000+ | Multi-vendor (CNCF) | Simple | Mature, widely used, extensive annotations |
| **Traefik** | Stable | 50,000+ | Multi-vendor | Simple | Modern, dynamic config, built-in Let's Encrypt |
| **Istio Gateway / Cilium Ingress** | CNCF Graduated / Incubating | Varies | Foundation | Medium-Expert | Service mesh integration, advanced traffic management |

**Our Recommendation**: **NGINX Ingress** for most use cases

**Why**:
- **Battle-tested**: Deployed everywhere, mature and stable
- **Simple**: Easy to configure, extensive documentation
- **Compliance**: TLS termination, audit logging

**When to choose Traefik**:
- Want automatic Let's Encrypt certificate management
- Prefer modern, dynamic configuration

**Decision impact**: Low-Medium — ingress controllers are relatively easy to swap

---

## Layer 2: Enhancements (Add When Needed)

These tools are **plug-and-play** and can be added or removed without disrupting the platform.

### 9. Image Scanning

| Tool | Maturity | Stars (GitHub) | Vendor Independence | Complexity | Key Features |
|------|----------|----------------|---------------------|------------|--------------|
| **Trivy** | CNCF Incubating | 23,000+ | Multi-vendor (Aqua) | Simple | Fast, comprehensive DB, CI/CD and admission controller modes |
| **Grype** | Stable | 8,000+ | Multi-vendor (Anchore) | Simple | Vulnerability scanning, SBOM generation |
| **Snyk** | Commercial SaaS | Commercial | Single-vendor | Simple | Hosted, developer-friendly, integrates with IDEs |

**Our Recommendation**: **Trivy**

**Why**:
- **CNCF Incubating**: Growing community, vendor-neutral
- **Comprehensive**: Scans OS packages, language dependencies, IaC misconfigurations
- **Flexible**: Works in CI/CD, as admission controller, or standalone CLI

**Decision impact**: Low — easy to add, remove, or swap

---

### 10. Policy Enforcement

| Tool | Maturity | Stars (GitHub) | Vendor Independence | Complexity | Key Features |
|------|----------|----------------|---------------------|------------|--------------|
| **OPA/Gatekeeper** | CNCF Graduated | 9,000+ | Foundation | Medium | General-purpose policy engine, Rego language |
| **Kyverno** | CNCF Incubating | 5,500+ | Foundation | Medium | Kubernetes-native, YAML-based policies, easier learning curve |

**Our Recommendation**: **Kyverno** for Kubernetes-specific policies

**Why**:
- **Easier to learn**: YAML-based policies vs. Rego
- **Kubernetes-native**: Designed specifically for Kubernetes
- **CNCF Incubating**: Growing adoption, vendor-neutral

**When to choose OPA/Gatekeeper**:
- Need general-purpose policy engine beyond Kubernetes
- Already using Rego in other contexts

**Decision impact**: Low — policy engines are additive and don't affect core platform

---

### 11. Runtime Security & Threat Detection

| Tool | Maturity | Stars (GitHub) | Vendor Independence | Complexity | Key Features |
|------|----------|----------------|---------------------|------------|--------------|
| **Falco** | CNCF Graduated | 7,000+ | Foundation | Medium | Runtime threat detection, kernel-level monitoring, customizable rules |
| **Tetragon** | CNCF Sandbox | 3,500+ | Foundation (Cilium) | Medium | eBPF-based, deep runtime visibility, Cilium integration |

**Our Recommendation**: **Falco**

**Why**:
- **CNCF Graduated**: Production-proven, mature
- **Runtime security**: Detects anomalies at kernel level (file access, process execution, network activity)
- **Compliance**: Real-time alerting for SOC 2, ISO 27001 incident detection

**Decision impact**: Low — can be added or removed without affecting workloads

---

## How to Approach This Matrix

### Phase 1: Foundation (Week 1)
1. ✅ Choose CNI (Cilium recommended)
2. ✅ Decide on GitOps (Argo CD recommended)
3. ✅ Set up RBAC + authentication (Keycloak + Kubernetes RBAC)
4. ✅ Implement secrets management (Vault + ESO)
5. ✅ Configure storage backend (cloud-native CSI)

### Phase 2: Core Operations (Week 2-4)
6. ✅ Deploy observability (Prometheus + Loki + Grafana)
7. ✅ Set up ingress (NGINX Ingress or Traefik)
8. ✅ Implement backup strategy (Velero)

### Phase 3: Security Enhancements (Month 2+)
9. ✅ Add image scanning (Trivy in CI/CD)
10. ✅ Implement policy enforcement (Kyverno)
11. ✅ Deploy runtime security (Falco)

---

## Filtering Examples

### "Show me only CNCF Graduated tools"
- CNI: Cilium
- GitOps: Argo CD or Flux
- Metrics: Prometheus
- Logging: Fluentd/Fluent Bit (paired with Loki)
- Policy: OPA/Gatekeeper
- Runtime Security: Falco

### "Show me simplest possible stack"
- CNI: Flannel
- GitOps: Flux (or skip GitOps)
- Secrets: Sealed Secrets
- Metrics: Prometheus
- Logging: Loki
- Ingress: NGINX
- Image Scanning: Trivy

### "Show me enterprise multi-tenant stack"
- CNI: Cilium
- GitOps: Argo CD
- Identity: Keycloak + Kubernetes RBAC
- Secrets: Vault + ESO
- Storage: Cloud-native CSI
- Metrics: Prometheus + Thanos
- Logging: Loki
- Ingress: NGINX with rate limiting
- Policy: Kyverno
- Runtime Security: Falco
- Image Scanning: Trivy

---

## Next Steps

- 📖 **[See Production-Ready Definition](PRODUCTION_READY.md)** for compliance and uptime targets
- 📚 **[Browse Real-World Scenarios](SCENARIOS.md)** for architecture examples
- 🔍 **[Read Tool Reviews](reviews/)** for detailed hands-on testing results

---

*This matrix is a living document. As tools evolve and new options emerge, we'll update recommendations based on hands-on testing.*
