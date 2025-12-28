# Layer 1: Tool Selection & Platform Capabilities — Webshop Migration Case

**Target Audience**: Platform Engineers, DevOps Engineers, Architects  
**Status**: Tool Selection & Architecture Design  
**Organization**: Dutch webshop / online store with Essential SAFe methodology  
**Prerequisite**: [Layer 0 Foundation](LAYER_0_WEBSHOP_CASE.md) must be established first  

---

## Reading Guide

📋 **[❓ QUESTION]** marks questions that must be answered before implementation can begin  
✅ **"Use X unless Y"** gives clear tool recommendations with alternatives  
🔗 **Layer 0 Link** shows how tool choices trace back to Layer 0 requirements  

---

## Executive Summary

This document translates the Layer 0 requirements from [LAYER_0_WEBSHOP_CASE.md](LAYER_0_WEBSHOP_CASE.md) into **concrete tool choices** and **platform capabilities**. 

### Layer 0 → Layer 1 Mapping

| Layer 0 Requirement | Layer 1 Implementation |
|---------------------|----------------------|
| **Zero-downtime deployments** | Rolling updates via Kubernetes Deployments + readiness probes |
| **Proactive monitoring** | Prometheus + Grafana + Alertmanager |
| **Point-in-time recovery** | Velero for cluster backup + managed database with PITR |
| **Vendor independence** | Cilium (CNI), Argo CD (GitOps), open-source stack |
| **GitOps from day 1** | Argo CD with Git repository as single source of truth |
| **Security by design** | Network policies, RBAC, External Secrets Operator |

### Key Decisions

1. **Managed Kubernetes with Dutch provider** (Layer 0 → reduce operational complexity)
2. **Cilium as CNI** (Network policies, eBPF performance, multi-region ready)
3. **Argo CD for GitOps** (UI for Support/Management, SSO, audit trail)
4. **Prometheus + Grafana** (Open-source observability, vendor independence)
5. **Managed PostgreSQL** (Trade-off: HA complexity vs. vendor independence)
6. **External Secrets Operator** (Vault/cloud KMS integration, no secrets in Git)

---

## 1. Infrastructure & Cluster Provisioning

### 1.1 Kubernetes Distribution Choice

**🔗 Layer 0 Constraint**: Team has no Kubernetes experience (training needed), vendor independence within 1 quarter

**✅ Decision: Managed Kubernetes with Dutch datacenter provider**

**Rationale**:
- **Operational complexity reduction**: Control plane management, upgrades, etcd backups handled by provider
- **Team maturity**: Focus on application migration, not on cluster operations
- **Vendor independence**: Managed Kubernetes API is standard → reproducible with other provider

**Alternatives considered**:
- ❌ **Self-hosted (Kubeadm, RKE2)**: Too complex for team without experience, higher operational burden
- ❌ **Hyperscaler (AWS EKS, Azure AKS, Google GKE)**: Conflicts with Dutch datacenter preference + vendor independence

---

#### 🔍 Managed Kubernetes: Nuances and Lock-in Analysis

It's important to understand that "managed Kubernetes" doesn't mean all vendor lock-in is avoided. There are subtle but important nuances:

##### ✅ What Remains Platform-Agnostic

**Core infrastructure remains decoupled:**
- The Kubernetes cluster itself is an abstraction layer
- All Kubernetes resources (Deployments, Services, ConfigMaps, Secrets) are standard APIs
- Network policies, RBAC, and other Kubernetes-native features are portable
- Container images and application architecture remain cloud-agnostic
- **Conclusion**: Your application workloads can theoretically run on any compatible Kubernetes cluster

##### ⚠️ Where Lock-in Occurs

**Dependencies outside Kubernetes core:**

| Component | Lock-in Risk | Explanation | Mitigation |
|-----------|--------------|-------------|------------|
| **Managed Databases** | 🔴 High | Provider-specific APIs, backup procedures, HA mechanisms | Self-hosted StatefulSet or abstraction layer (e.g., CloudNativePG) |
| **Storage (CSI Drivers)** | 🟡 Medium | Provider-specific storage classes, snapshot APIs | Use standard StorageClass interface, test migration |
| **Load Balancers** | 🟡 Medium | Cloud-specific LoadBalancer implementations | NGINX Ingress makes you more independent of cloud LB |
| **Backup Systems** | 🟡 Medium | Provider-specific volume snapshots | Velero with S3-compatible storage as alternative |
| **Monitoring Integrations** | 🟢 Low | Native integrations with cloud monitoring | Prometheus/Grafana remains portable |
| **Network Features** | 🟡 Medium | Cloud-specific VPC, subnets, firewall rules | CNI plugin (Cilium) remains portable |

##### 📊 Scenario-based Strategy

**1. Startups or Small Teams**
- **Recommendation**: Managed Kubernetes as standard
- **Rationale**: Reduces operational overhead, faster time-to-market
- **Lock-in tolerance**: Acceptable for speed and simplicity
- **Condition**: Document all provider-specific dependencies

**2. Enterprise or Government**
- **Recommendation**: Self-managed Kubernetes with careful consideration
- **Rationale**: Full control, compliance-sensitive data, avoid vendor lock-in
- **Trade-off**: Higher operational complexity, more expertise required
- **Condition**: In-house Kubernetes expertise or external consultants

**3. Multi-Region / Multi-Cloud Setups**
- **Recommendation**: Hybrid approach possible
- **Rationale**: Managed Kubernetes can be convenient if provider supports multi-region
- **Alternative**: Self-managed more flexible for cross-cloud scenarios
- **Condition**: Abstraction layer for storage, databases, and load balancing

##### 🎯 "Dual Track" Strategy for KubeCompass

**Default Option: Managed Kubernetes**
- Lower barrier for teams without Kubernetes experience
- Faster startup phase (control plane management outsourced)
- Focus on application migration, not cluster operations
- **Condition**: Transparent documentation about lock-in points

**Alternative Option: Self-managed Kubernetes**
- For teams with strict compliance requirements
- For organizations with multi-cloud strategy
- For situations where vendor independence is absolute priority
- **Condition**: In-house expertise or budget for consultants

##### 📋 Lock-in Decision Matrix

Use this matrix to determine which lock-ins are acceptable:

```
IF vendor_independence == ABSOLUTE:
  → Self-managed Kubernetes
  → Self-hosted databases (StatefulSets)
  → S3-compatible storage (e.g., MinIO)
  → Velero for backups
  
ELIF team_maturity == LOW AND time_to_market == CRITICAL:
  → Managed Kubernetes
  → Managed databases (PostgreSQL/MySQL)
  → Provider storage (with documented exit strategy)
  → Managed backups (with Velero as fallback)
  
ELIF compliance == STRICT:
  → Self-managed Kubernetes in dedicated datacenter
  → On-premises databases
  → Encrypted storage with key management
  → Disaster recovery plan with multi-site replication
```

##### ✅ Recommendation for this Webshop Case

**Choice: Managed Kubernetes (with conscious trade-offs)**

**Rationale**:
- Team has no Kubernetes experience (training needed)
- Focus on application migration within 1 quarter
- Vendor independence is important, but not absolute
- Dutch datacenter requirement limits hyperscaler options

**Accepted Lock-ins**:
- ✅ Managed Kubernetes control plane (migration possible within 1 quarter)
- ✅ Provider storage via CSI driver (data migration possible)
- ⚠️ Managed PostgreSQL (trade-off: HA vs. vendor independence - see section 5.1)

**Avoided Lock-ins**:
- ❌ Cloud-specific APIs in application code
- ❌ Proprietary monitoring tools (use Prometheus/Grafana)
- ❌ Vendor-specific CI/CD (use GitHub Actions + Argo CD)

**Exit Strategy**:
- Document all provider-specific configurations
- Test migration scenarios to other managed Kubernetes providers
- Annual review of vendor independence vs. operational complexity

---

**[❓ QUESTION 1]**: Which managed Kubernetes provider is chosen?
- Options: TransIP Kubernetes, DigitalOcean, OVHcloud, Scaleway
- Criteria: EU datacenter, SLA, pricing, support quality
- Impact: Determines available features (LoadBalancer support, storage classes, etc.)

**[❓ QUESTION 2]**: What is the Kubernetes version strategy?
- Always N-1 (one version behind latest for stability)?
- Upgrades quarterly, semi-annually, or ad-hoc for security patches?
- Impact: Determines upgrade window planning, compatibility testing

---

### 1.2 Infrastructure as Code (IaC)

**🔗 Layer 0 Principle**: Infrastructure as Code for reproducible environments

**✅ Decision: Terraform for cluster provisioning**

**Rationale**:
- **Vendor independence**: Terraform works with all cloud providers
- **Maturity**: Stable Kubernetes provider, large community
- **State management**: Remote state (S3-compatible backend) for team collaboration

**Alternatives considered**:
- ⚠️ **Pulumi**: Modern IaC (TypeScript/Python), but smaller community and less provider documentation
- ❌ **Crossplane**: Too complex for managed Kubernetes use case (more suitable for multi-cloud orchestration)

**Recommended repository structure** (for your own implementation):
```
infrastructure/
├── terraform/
│   ├── modules/
│   │   ├── kubernetes-cluster/  # Cluster provisioning
│   │   ├── networking/           # VPC, subnets, load balancers
│   │   └── storage/              # Storage classes, persistent volume setup
│   ├── environments/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── production/
│   └── README.md
└── kubernetes/
    ├── argocd/              # GitOps configuration
    ├── platform/            # Platform components
    ├── observability/       # Monitoring and logging
    ├── security/            # Security policies
    ├── applications/        # Application workloads
    └── backup/              # Backup and DR
```

> **📝 Note**: KubeCompass contains no implementation code, only patterns and documentation. 
> Use the above structure as guidance for your own implementation.

**[❓ QUESTION 3]**: Who manages Terraform state?
- Terraform Cloud (free tier), S3-compatible backend at provider, or Git (not recommended)?
- Impact: Team collaboration, state locking, secret management

**[❓ QUESTION 4]**: How often is infrastructure updated?
- With each application release, monthly, or only with breaking changes?
- Impact: Drift detection strategy, CI/CD integration

---

### 1.3 Cluster Sizing & Node Pools

**🔗 Layer 0 Context**: Current VM setup and resource usage (Q7 in Layer 0 section 12.1)

**[❓ QUESTION 5]**: What are the current resource requirements?
- CPU: ____ cores per application instance
- Memory: ____ GB per application instance
- Current traffic: ____ requests/sec, ____ concurrent users
- Impact: Determines node types and number of nodes

**✅ Initial Sizing Proposal** (pending Q5):
```yaml
Node Pools:
  - name: system
    purpose: Control plane workloads (ingress, monitoring, logging)
    size: 2-4 vCPU, 8-16 GB RAM
    count: 2 nodes (HA)
    
  - name: application
    purpose: Webshop workloads
    size: 4-8 vCPU, 16-32 GB RAM
    count: 3 nodes (HA + rolling updates)
    autoscaling: true (min 3, max 6)
```

**Rationale**:
- **System pool separation**: Isolate platform workloads from application workloads (resource contention prevention)
- **3 application nodes**: Minimum for rolling updates without downtime (1 node drain, 2 nodes remain active)
- **Autoscaling**: Handle traffic peaks (Black Friday, sale periods)

**[❓ QUESTION 6]**: What are the traffic patterns?
- Peak hours (evening/weekend), seasonal (Black Friday, Christmas)?
- Impact: Autoscaling thresholds (CPU/memory triggers)

---

## 2. Networking & Service Mesh

### 2.1 CNI Plugin

**🔗 Layer 0 Requirements**:
- Network policies for security
- Multi-region capable (future requirement)
- Performance (webshop must be fast)
- Cloud-agnostic (vendor independence)

**✅ Decision: Cilium**

**Rationale**:
- **eBPF-based**: Higher performance than iptables-based CNIs (Calico, Flannel)
- **Network policies**: L3/L4 and L7 policies (HTTP, gRPC) → fine-grained security
- **Observability**: Hubble for network flow visualization (troubleshooting)
- **Multi-region ready**: Cluster mesh support (not day 1, but architecture doesn't block it)
- **CNCF Graduated**: Vendor-neutral, battle-tested

**"Use Cilium unless"**:
- You already have Calico expertise in-house and don't want to invest in Cilium learning curve
- You have BGP routing requirements (Calico is stronger in BGP)
- You want absolutely simplest setup (Flannel, but lacks many features)

**[❓ QUESTION 7]**: Should Hubble UI be exposed?
- Via Ingress (accessible for teams), or only port-forward (ops only)?
- Impact: Network troubleshooting self-service for developers

---

### 2.2 Ingress Controller

**🔗 Layer 0 Requirement**: Zero-downtime deployments, TLS encryption

**✅ Decision: NGINX Ingress Controller**

**Rationale**:
- **Maturity**: Most used Ingress controller, stable, large community
- **Feature set**: SSL termination, rate limiting, rewrite rules
- **Cloud-agnostic**: Works everywhere (not dependent on cloud-specific load balancers)

**"Use NGINX Ingress unless"**:
- You want dynamic configuration without restarts (Traefik has better hot-reload)
- You're already all-in on Envoy ecosystem (Istio, Contour)

**[❓ QUESTION 8]**: SSL certificate management?
- cert-manager (automatic Let's Encrypt), wildcard certificate (manual), or cloud-managed?
- Impact: Certificate renewal automation, DNS-01 vs HTTP-01 challenge

---

### 2.3 Service Mesh

**🔗 Layer 0 Non-Goal**: Service mesh not needed for monolithic application

**✅ Decision: No service mesh (day 1)**

**"Add service mesh later when"**:
- Microservices architecture (multiple services communicating)
- Advanced traffic management (canary deployments, A/B testing)

---

### 2.4 Network Policies

**🔗 Layer 0 Requirement**: Defense in depth, least privilege

**✅ Decision: Network policies from day 1**

**[❓ QUESTION 9]**: What external dependencies does the application have?
- Payment providers (IP ranges/domains), shipping APIs, email services (SMTP)?
- Impact: Egress policies must whitelist external endpoints

---

## 3. GitOps & CI/CD

### 3.1 GitOps Tool

**🔗 Layer 0 Principle**: GitOps is Layer 0 principle (all deployments via Git)

**✅ Decision: Argo CD**

**Rationale**:
- **UI**: Support and management can view deployment status without kubectl access
- **SSO integration**: OIDC integration with identity provider (Keycloak/Azure AD)
- **Multi-tenancy**: Projects for team isolation (Dev, Staging, Prod)
- **Audit trail**: Change tracking for compliance
- **CNCF Graduated**: Vendor-neutral, production-proven

**"Use Argo CD unless"**:
- You want GitOps-pure (no UI) → Flux is more "Git is single source of truth"
- You have complex Helm + image automation requirements → Flux has stronger Helm support

**[❓ QUESTION 10]**: Git branching strategy?
- Trunk-based (main branch → auto-deploy to dev, PR to prod)?
- GitFlow (dev/staging/prod branches)?
- Impact: Argo CD sync strategy, approval workflows

---

### 3.2 CI/CD Pipeline

**✅ Decision: GitHub Actions**

**[❓ QUESTION 12]**: Self-hosted runners needed?
- GitHub-hosted runners (easy, but limited resources), or self-hosted (more control, costs)?

---

### 3.3 Container Registry

**✅ Decision: Harbor (self-hosted)**

**[❓ QUESTION 13]**: Where does Harbor run?
- In Kubernetes cluster (resource overhead), or dedicated VM (isolation)?

---

## 4. Observability

### 4.1 Metrics & Monitoring

**✅ Decision: Prometheus + Grafana**

**[❓ QUESTION 14]**: Which business metrics are critical?
- Checkout conversion rate, order processing time, payment success rate?

**[❓ QUESTION 15]**: Alert fatigue prevention?
- Which alerts are pager-worthy (middle of the night), which are Slack-only?

---

### 4.2 Logging

**✅ Decision: Grafana Loki**

**[❓ QUESTION 16]**: PII in logs?
- Must logs be GDPR-compliant (no customer data logged)?

---

### 4.3 Uptime Monitoring (External)

**✅ Decision: UptimeRobot (external SaaS) + Prometheus Blackbox Exporter (internal)**

**[❓ QUESTION 17]**: Alerting escalation path?
- Who gets alerts? PagerDuty (ops on-call), Slack, email?

---

## 5. Security & Compliance

### 5.1 RBAC Model

**🔗 Layer 0 Constraint**: Developers no production access, Ops has namespace-scoped access

**[❓ QUESTION 18]**: Identity provider integration?
- OIDC with Keycloak (self-hosted), Azure AD, Google Workspace?

**[❓ QUESTION 19]**: Break-glass procedures?
- Who has cluster-admin access in emergencies?

---

### 5.2 Secrets Management

**✅ Decision: External Secrets Operator + HashiCorp Vault**

**[❓ QUESTION 20]**: Vault unsealing?
- Auto-unseal via cloud KMS (convenience), or manual unseal (security)?

**[❓ QUESTION 21]**: Secret rotation frequency?
- Database passwords: monthly, quarterly?

---

### 5.3 Image Scanning

**✅ Decision: Trivy (in CI/CD) + Harbor scanning (in registry)**

**[❓ QUESTION 22]**: CVE remediation policy?
- Block deployment on CRITICAL CVE (strict), or warning only (pragmatic)?

---

### 5.4 Pod Security Standards

**✅ Decision: Pod Security Standards (restricted profile)**

**[❓ QUESTION 23]**: Are there workloads requiring privileged access?

**[❓ QUESTION 24]**: Database location?
- Within Kubernetes (StatefulSet), or external managed database?

---

## 6. Data Management & Storage

### 6.1 Persistent Storage

**✅ Decision: Cloud provider CSI driver + managed disks**

**[❓ QUESTION 25]**: Storage provider capabilities?
- Which CSI driver does the provider offer? Snapshots supported?

---

### 6.2 Database Strategy

**✅ Decision: Managed PostgreSQL (cloud provider)**

**[❓ QUESTION 26]**: Current database?
- SQL Server, MySQL, PostgreSQL, or something else?

**[❓ QUESTION 27]**: Database size & load?
- How many GB data, how many queries/sec?

---

### 6.3 Backup & Disaster Recovery

**✅ Decision: Velero for Kubernetes backup + database native backup**

**[❓ QUESTION 28]**: Disaster recovery testing frequency?
- Monthly, quarterly, or ad-hoc?

**[❓ QUESTION 29]**: Backup encryption?
- At-rest encryption in S3-compatible storage?

---

### 6.4 Caching Layer

**✅ Decision: Valkey (Redis fork)**

**[❓ QUESTION 30]**: Current session management?
- Sessions in application memory (problematic for horizontal scaling)?

---

## 7. Application Migration Readiness

### 7.1 Application Architecture Validation

**[❓ QUESTION 31]**: Is the application stateless?
- [ ] Sessions stored in database/Redis
- [ ] No local file uploads
- [ ] No shared filesystem dependencies

**[❓ QUESTION 32]**: Can the application scale horizontally?

**[❓ QUESTION 33]**: Are there hardcoded localhost/IP dependencies?

**[❓ QUESTION 34]**: Health check endpoints?
- [ ] `/health` endpoint (liveness probe)
- [ ] `/ready` endpoint (readiness probe)

---

### 7.2 Database Migration Strategy

**[❓ QUESTION 35]**: Database migration approach?
- **Option A**: Lift & shift (database remains external VM)
- **Option B**: Database migrates to managed cloud database
- **Option C**: Phased approach

**[❓ QUESTION 36]**: Schema migrations backward compatible?

---

### 7.3 External Dependencies

**[❓ QUESTION 37]**: Which external APIs are used?
- Payment providers, shipping APIs, email services?

**[❓ QUESTION 38]**: Outbound IP whitelisting requirements?

---

## 8. Team Workflow & Operational Model

### 8.1 Deployment Workflow

**[❓ QUESTION 39]**: Deployment approval process?
- Auto-deploy to dev/staging, manual approval for production?

**[❓ QUESTION 40]**: Hotfix process?

---

### 8.2 Monitoring & Alerting Ownership

**[❓ QUESTION 41]**: On-call rotation?

---

### 8.3 Training & Onboarding

**[❓ QUESTION 42]**: External consultant needed?

---

## 9. Cost Estimation

**[❓ QUESTION 43]**: Current monthly infrastructure costs?

**[❓ QUESTION 44]**: Budget approval?

---

## 10. Migration Roadmap

### Phase 1: Foundation (Week 1-4)
- [ ] Kubernetes cluster provisioning (Terraform)
- [ ] CNI deployment (Cilium)
- [ ] Ingress controller (NGINX)
- [ ] GitOps setup (Argo CD)
- [ ] Observability stack (Prometheus, Grafana, Loki)
- [ ] Secrets management (Vault + External Secrets Operator)

### Phase 2: Platform Hardening (Week 5-8)
- [ ] RBAC configuration
- [ ] Network policies
- [ ] Pod Security Standards
- [ ] Container registry (Harbor)
- [ ] Backup setup (Velero)
- [ ] CI/CD pipeline (GitHub Actions)

### Phase 3: Application Migration (Week 9-12)
- [ ] Application containerization
- [ ] Kubernetes manifests
- [ ] Database migration
- [ ] Caching layer (Valkey)
- [ ] Health checks implementation
- [ ] Dev environment deployment

### Phase 4: Staging & Testing (Week 13-16)
- [ ] Staging environment deployment
- [ ] Load testing
- [ ] Disaster recovery testing
- [ ] Security testing
- [ ] Runbook creation
- [ ] Team training

### Phase 5: Production Cutover (Week 17-20)
- [ ] Production environment deployment
- [ ] Blue-green cutover
- [ ] DNS switch
- [ ] Monitoring validation
- [ ] Post-cutover monitoring
- [ ] Old infrastructure decommissioning

---

## 11. Success Criteria

| Criterion | Layer 0 Target | Layer 1 Implementation | Validation |
|-----------|----------------|----------------------|------------|
| **Deployment downtime** | 0 minutes | Rolling updates + readiness probes | Deploy during business hours |
| **Incident detection** | < 2 minutes | Prometheus alerts + UptimeRobot | Simulate failure |
| **Data recovery** | Point-in-time (max 15 min loss) | Managed DB PITR + Velero | Quarterly DR drill |
| **Vendor migration** | < 1 quarter | Terraform IaC + open-source stack | Annual portability review |
| **Developer self-service** | Deploy via Git PR | Argo CD + GitHub Actions | Developers can deploy without Ops |

---

## 12. Open Questions Summary

**Critical for implementation start** (MUST be answered):
- [❓ Q1] Which managed Kubernetes provider?
- [❓ Q5] Resource requirements (CPU/memory)?
- [❓ Q26] Current database (MySQL/PostgreSQL/SQL Server)?
- [❓ Q31-34] Application stateless? Health checks present?
- [❓ Q43-44] Budget approval?

**Important but not blocking**:
- [❓ Q10] Git branching strategy
- [❓ Q14] Business metrics
- [❓ Q18] Identity provider (OIDC)
- [❓ Q39] Deployment approval process

**Can be decided later**:
- [❓ Q7] Expose Hubble UI?
- [❓ Q12] Self-hosted CI runners?
- [❓ Q42] External consultant?

---

## 13. Next Steps: From Layer 1 to Layer 2

After implementing Layer 1 (first 4-6 months), Layer 2 (enhancement) can be considered:

### Layer 2 Possibilities (Optional)
- **Service mesh** (Istio/Linkerd) - if microservices architecture
- **Distributed tracing** (Jaeger/Tempo) - for performance debugging
- **Chaos engineering** (Chaos Mesh) - for resilience testing
- **Policy enforcement** (OPA/Kyverno) - for compliance automation
- **Cost optimization** (Kubecost) - for chargeback/showback
- **Multi-region** (Cilium Cluster Mesh) - for latency improvement

---

## 14. References

**KubeCompass Framework**:
- **[FRAMEWORK.md](FRAMEWORK.md)**: Decision layers explanation
- **[MATRIX.md](MATRIX.md)**: Tool recommendations with scoring
- **[LAYER_0_WEBSHOP_CASE.md](LAYER_0_WEBSHOP_CASE.md)**: Foundational requirements
- **[SCENARIOS.md](SCENARIOS.md)**: Enterprise multi-tenant scenario
- **[PRODUCTION_READY.md](PRODUCTION_READY.md)**: Compliance requirements

**Tool Documentation**:
- [Cilium Documentation](https://docs.cilium.io/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Velero Documentation](https://velero.io/docs/)
- [Harbor Documentation](https://goharbor.io/docs/)

---

**Document Status**: ⚠️ Draft - Requires answers to [❓ QUESTIONS] before implementation  
**Owner**: Platform Team / Lead Architect  
**Review Cycle**: After answering critical questions (Q1, Q5, Q26, Q31-34, Q43-44)  
**Next Phase**: Layer 2 (enhancement) after 6 months production stability  

---

**Layer 1 Document Version**: 1.0  
**Based on**: Layer 0 v2.0 (LAYER_0_WEBSHOP_CASE.md)  
**Last Update**: December 2024  
**License**: MIT — free to use and adapt
