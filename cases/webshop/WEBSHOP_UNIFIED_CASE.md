# Webshop Case: Unified Decision Framework

**Case Type**: SME E-commerce Migration  
**Version**: 1.0  
**Organization**: Dutch webshop with Essential SAFe methodology  
**Status**: Foundational analysis complete, ready for interactive decision support  

---

## 1. Executive Summary

### Organization Profile
- **Type**: SME (Small-Medium Enterprise)
- **Size**: ~10 people across Dev, Ops, Functional Management, and Support teams
- **Industry**: E-commerce (physical products with EU shipping)
- **Geography**: Netherlands (EU datacenter requirement for GDPR)
- **Methodology**: Essential SAFe (scaled agile framework)
- **Kubernetes Maturity**: **None** - Team has no Kubernetes experience

### Primary Constraints (Hard)
1. **Vendor Independence**: Must be able to migrate to another provider within 1 quarter
2. **GDPR Compliance**: Customer data must remain within EU
3. **Business Continuity**: Checkout downtime = direct revenue loss
   - Max acceptable downtime: 30 minutes/month (99.9% uptime)
   - Max data loss (RPO): 15 minutes for transactions
   - Max recovery time (RTO): 30 minutes for critical systems
4. **Budget**: No enterprise SaaS budgets (prefer open-source)
5. **Security**: No production kubectl access for developers (GitOps only)
6. **Team Maturity**: No Kubernetes expertise (training and consultant needed)

### Current Pain Points
- ✋ **Manual releases** (Monday nights only, with downtime)
- 🚨 **Reactive incident detection** (customers call, accidental discovery)
- 💾 **Nightly backups only** (no point-in-time recovery)
- 🗄️ **SQL database** as single point of failure
- 🔧 **Inconsistent VM configuration** (no systematic patching)

### Business Drivers
1. **Eliminate deployment downtime** - Deploy when ready, not when "allowed"
2. **Proactive monitoring** - Detect issues before customers notice
3. **Data protection** - Point-in-time recovery for critical transactions
4. **Reduce operational burden** - Systematic patching and updates
5. **Enable developer self-service** - Deploy via Git without Ops bottleneck

### Success Metrics
| Metric | Current State | Target | Validation Method |
|--------|---------------|--------|-------------------|
| **Deployment downtime** | 1-4 hours per release | 0 minutes (rolling updates) | Deploy during business hours |
| **Incident detection** | 10-60 minutes (customers report) | < 2 minutes (automated alerts) | Simulate failures |
| **Data recovery** | Last nightly backup | Point-in-time (max 15 min loss) | Quarterly DR drill |
| **Vendor migration time** | Unknown/untested | < 1 quarter | Annual portability review |
| **Developer self-service** | Ops does manual deploys | Deploy via Git PR | Developers deploy without Ops |

---

## 2. Priority 0: Foundations

*For complete Priority 0 details, see [PRIORITY_0_WEBSHOP_CASE.md](../../PRIORITY_0_WEBSHOP_CASE.md)*

### Goals (Primary)
1. **Eliminate Deployment Downtime** - Zero-downtime releases via rolling updates
2. **Proactive Operations** - Detect issues before customers notice (<2 min detection)
3. **Data Protection & Recovery** - Point-in-time recovery (max 15 min data loss)
4. **Vendor Independence** - Migration to another provider within 1 quarter
5. **Clear Team Ownership** - Developers deploy via GitOps, Ops facilitates platform

### Non-Goals (Explicitly Excluded)
1. ❌ **Microservices Refactoring** - MVC monolith stays intact (lift & shift only)
2. ❌ **Multi-Region Deployment** - Too complex for team without K8s experience
3. ❌ **Advanced Observability** - Distributed tracing is Priority 2 (metrics/logs first)
4. ❌ **Service Mesh** - Not needed for monolith (defer until microservices)
5. ❌ **100% Uptime Guarantee** - Realistic target is 99.9% (30 min/month acceptable)
6. ❌ **Developer kubectl Access** - GitOps only (security/compliance requirement)

### Hard Constraints (Non-Negotiable)
1. **Vendor Independence** - Migration within 1 quarter (no cloud-specific services)
2. **GDPR Compliance** - Customer data within EU datacenters
3. **Business Continuity** - 99.9% uptime, 15 min RPO, 30 min RTO
4. **Security Baseline** - No production kubectl for developers
5. **Budget Realism** - No enterprise SaaS budgets (open-source preferred)
6. **Team Maturity** - No K8s experience (consultant + training mandatory)

### Trade-offs Accepted
| Trade-off | Decision | Rationale |
|-----------|----------|-----------|
| **Managed vs Self-hosted K8s** | Managed | Team lacks experience |
| **Managed DB vs StatefulSet** | Managed DB preferred | Operational simplicity > vendor independence for data layer |
| **Open-source vs SaaS observability** | Open-source | Budget + vendor independence |
| **GitOps complexity vs Control** | Accept learning curve | Security & audit trail justify investment |

### Key Risks & Mitigations
**HIGH RISK**:
1. **No K8s Experience** → External consultant (3-6 months) + training + POC first
2. **Complex DB Migration** → Test extensively, consider managed DB for HA
3. **Accidental Vendor Lock-in** → Portability checklist, quarterly reviews, IaC from day 1
4. **GitOps Breaks SAFe Process** → Map workflows, pilot with 1 team first

---

## 3. Priority 1: Tool Mapping & "Choose X unless Y" Rules

*For complete Priority 1 details with all 44 questions, see [PRIORITY_1_WEBSHOP_CASE.md](../../PRIORITY_1_WEBSHOP_CASE.md)*

### Infrastructure & Provisioning

#### Kubernetes Distribution
**Decision**: Managed Kubernetes at Dutch/EU provider

**Choose MANAGED KUBERNETES unless**:
- ❌ Team has strong K8s expertise → Self-managed viable
- ❌ Vendor independence overrides operational simplicity → Self-managed required
- ❌ Compliance requires on-premises → Self-managed required

**Recommended Providers for Webshop Case**:
1. **TransIP Kubernetes** ⭐⭐⭐⭐⭐ (Dutch support, EU datacenter, GDPR-friendly)
   - ⚠️ **No Terraform for cluster lifecycle** - uses hybrid IaC approach
   - ✅ Full Terraform support for in-cluster resources
   - 📖 **See**: [TransIP Infrastructure as Code Guide](../../docs/TRANSIP_INFRASTRUCTURE_AS_CODE.md)
2. **OVHcloud Kubernetes** ⭐⭐⭐⭐ (Competitive pricing, Amsterdam/Gravelines)
   - ✅ Full Terraform support including cluster lifecycle
3. **Scaleway Kubernetes** ⭐⭐⭐⭐ (Budget option, EU-native)
   - ✅ Full Terraform support including cluster lifecycle

**Critical Question**: **Q1** - Which provider? (Blocks cluster provisioning)
**Important Trade-off**: TransIP offers best Dutch support/GDPR but requires manual cluster provisioning. Scaleway/OVHcloud offer full Terraform automation but non-Dutch support.

#### Infrastructure as Code
**Decision**: Terraform

**Choose TERRAFORM unless**:
- ❌ Team prefers programming languages → Pulumi (TypeScript/Python)
- ❌ Multi-cloud orchestration critical → Crossplane

**Critical Question**: **Q5** - CPU/memory requirements? **[BLOCKER]** (Affects node sizing)

---

### Networking

#### CNI Selection
**Decision**: Cilium

**Choose CILIUM unless**:
- ❌ Team has deep Calico expertise → Leverage existing knowledge
- ❌ BGP routing critical → Calico stronger
- ❌ Maximum simplicity needed → Flannel sufficient

**Rationale**: eBPF performance, network policies, Hubble observability, multi-region ready

#### Ingress Controller
**Decision**: NGINX Ingress Controller

**Choose NGINX unless**:
- ❌ Advanced routing needed → Traefik
- ❌ API gateway features → Kong, Ambassador

---

### GitOps & CI/CD

#### GitOps Tool
**Decision**: Argo CD

**Choose ARGO CD unless**:
- ❌ Pure Git workflow (no UI) → Flux
- ❌ Helm + image automation critical → Flux
- ❌ Multi-tenancy not needed → Flux simpler

**Rationale**: UI for Support/Management, SSO integration, audit trail, RBAC

**Critical Question**: **Q10** - Git branching strategy? (Maps to SAFe, affects workflow)

#### CI/CD Pipeline
**Decision**: GitHub Actions

**Choose GITHUB ACTIONS unless**:
- ❌ Self-hosted Git → GitLab CI
- ❌ Complex enterprise workflows → Tekton, Jenkins

---

### Observability

#### Metrics Stack
**Decision**: Prometheus + Grafana

**Choose PROMETHEUS + GRAFANA unless**:
- ❌ Budget allows SaaS AND team < 5 → Datadog/New Relic (less ops burden)
- ❌ Compliance prohibits SaaS → Prometheus required

**Critical Questions**:
- **Q14** - Which business metrics critical? (Orders/min, checkout success rate)
- **Q15** - Alert fatigue prevention? (Start minimal, iterate)

#### Logging Stack
**Decision**: Loki + Promtail

**Choose LOKI unless**:
- ❌ Advanced log analysis needed → ELK stack
- ❌ Team has ELK expertise → Leverage existing

**Critical Question**: **Q16** - PII in logs? (GDPR compliance)

---

### Security

#### Secrets Management
**Decision**: External Secrets Operator + Vault

**Choose VAULT + ESO unless**:
- ❌ Cloud KMS acceptable → Cloud provider secrets (simpler)
- ❌ Very few secrets → Sealed Secrets

**Critical Questions**:
- **Q18** - Identity provider? (Keycloak? Azure AD?)
- **Q19** - Break-glass procedures?

---

### Data Management

#### Database Strategy
**Decision**: Managed Cloud Database (PostgreSQL or MySQL)

**Choose MANAGED DATABASE unless**:
- ❌ Vendor independence > operational complexity → StatefulSet + replication
- ❌ Compliance requires on-premises → Self-hosted required

**Trade-off**: Managed DB = HA/backups/PITR out of box, but vendor dependency

**CRITICAL QUESTIONS** (Implementation Blockers):
- **Q26** - Current database? (MySQL/PostgreSQL/SQL Server?) **[BLOCKER]**
- **Q31** - Application stateless? (Sessions in Redis/DB, not in-memory?) **[BLOCKER]**
- **Q32** - Can scale horizontally? **[BLOCKER]**
- **Q33** - Hardcoded localhost/IP dependencies? **[BLOCKER]**
- **Q34** - Health check endpoints exist? **[BLOCKER]**

#### Backup & DR
**Decision**: Velero (cluster backup) + Managed DB PITR

**Choose VELERO unless**:
- ❌ CSI snapshots sufficient → Cloud-native snapshots
- ❌ Enterprise features needed → Kasten K10

---

## 4. Priority 2: Enhancements (Future, Not Day 1)

*For complete Priority 2 triggers and trade-offs, see [PRIORITY_2_WEBSHOP_CASE.md](../../PRIORITY_2_WEBSHOP_CASE.md)*

### When to Implement Priority 2 Capabilities

| Capability | Trigger | Complexity | Timing |
|-----------|---------|------------|--------|
| **Service Mesh** | > 5 microservices, per-service security | High | After microservices refactoring (6-12 months) |
| **Distributed Tracing** | Cross-service debugging takes > 1h | Medium | When > 5 services |
| **Chaos Engineering** | Validate HA, prevent incident recurrence | Low-Medium | After platform stability (6 months) |
| **Policy Enforcement** | Compliance requirement, > 10 developers | Medium | When manual review doesn't scale |
| **Cost Visibility** | Budget concerns, multi-tenant | Low | **Day 1** (Kubecost recommended from start) |
| **Multi-Region** | Latency requirements, DR active-active | High | When international expansion confirmed |

**Key Principle**: Don't build for problems you don't have yet. Priority 2 is about maturity, not day 1.

---

## 5. Open Questions - Prioritized by Impact

### CRITICAL (Implementation Blockers - Must Answer Before Starting)

| ID | Question | Impact | Default Assumption if Unknown |
|----|----------|--------|------------------------------|
| **Q1** | Which managed K8s provider? | Blocks cluster provisioning | TransIP (Dutch, EU, managed) |
| **Q5** | CPU/memory requirements? | Blocks node sizing & cost | Medium nodes (8 CPU, 16GB RAM) |
| **Q26** | Current database? | Blocks migration planning | PostgreSQL (assume modern) |
| **Q31** | Application stateless? | Blocks containerization | Assume yes, must verify |
| **Q32** | Can scale horizontally? | Blocks HA design | Assume yes, must verify |
| **Q33** | Hardcoded localhost/IP dependencies? | Blocks containerization | Assume no, must verify |
| **Q34** | Health check endpoints exist? | Blocks readiness probes | Must be implemented |
| **Q43** | Current monthly infra costs? | Blocks budget planning | €500-2000/month (estimate) |
| **Q44** | Budget approval obtained? | Blocks entire project | Assume yes (or project wouldn't exist) |

### IMPORTANT (Needed in First 2 Weeks)

| ID | Question | Impact | Deadline |
|----|----------|--------|----------|
| **Q10** | Git branching strategy? | Affects GitOps workflow | Week 1 |
| **Q14** | Critical business metrics? | Affects observability design | Week 2 |
| **Q18** | Identity provider? | Affects authentication setup | Week 2 |
| **Q19** | Break-glass procedures? | Affects emergency access | Week 2 |
| **Q35** | Database migration approach? | Affects cutover strategy | Week 2 |

### CAN DEFER (Priority 2 or Implementation Phase)

| ID | Question | Can Defer Until |
|----|----------|-----------------|
| **Q7** | Hubble UI exposure? | Priority 2 observability |
| **Q12** | Self-hosted CI runners? | When security requires |
| **Q30** | Session management refactor? | Application containerization phase |
| **Q42** | External consultant needed? | Recommendation: **YES** (strongly advised) |

**Total Questions**: 44 from Priority 1, categorized by urgency

---

## 6. Provider Recommendations Matrix

### For Webshop Case (SME, ~10 people, no K8s experience, GDPR)

**Scenario: Operational Simplicity + Vendor Independence Balance**

```
IF (
  organization = "Dutch SME"
  AND team_size < 10
  AND kubernetes_experience = "none"
  AND gdpr_compliance = "required"
  AND vendor_independence = "critical but not absolute"
  AND budget = "limited"
)
THEN recommend:
  PRIMARY: TransIP Kubernetes OR OVHcloud Kubernetes
  ALTERNATIVE: Scaleway (if cost critical)
  WITH: External consultant (3-6 months)
  WITH: Terraform IaC (portability)
  WITH: Open-source tooling (Cilium, Argo CD, Prometheus)
  ACCEPT: Managed database vendor dependency (operational simplicity trade-off)
```

**Provider Comparison**:

| Provider | Region | Cost | Pros | Cons | Verdict |
|----------|--------|------|------|------|---------|
| **TransIP** | NL | €€ | Dutch support, GDPR, trusted | Smaller ecosystem | ⭐⭐⭐⭐⭐ **Top choice** |
| **OVHcloud** | FR/NL | €€ | Good pricing, Amsterdam datacenter | French company | ⭐⭐⭐⭐ Strong alt |
| **Scaleway** | FR/NL | €€ | Lowest cost, EU-native | Less mature | ⭐⭐⭐⭐ Budget option |
| **DigitalOcean** | Global | €€€ | Mature, great UX | No EU-only guarantee | ⭐⭐⭐ If global OK |
| **AKS/EKS/GKE** | Global | €€€€ | Feature-rich, enterprise | Vendor lock-in risk, cost | ❌ Conflicts with goals |

### Other Scenarios

**Enterprise/Government** → Self-managed K8s (control, compliance, transparency) OR managed with strict portability  
**Startup (solo DevOps)** → Managed K8s (DigitalOcean, Scaleway) - simplicity paramount  
**Scale-Up (10+ services)** → Self-managed OR managed + Priority 2 features (service mesh, policy enforcement)

---

## 7. "Choose X unless Y" Compiled Decision Rules

### Infrastructure
- **Managed K8s** UNLESS team has expertise OR vendor independence absolute
- **Terraform** UNLESS team prefers code (Pulumi) OR multi-cloud orchestration (Crossplane)

### Networking
- **Cilium** UNLESS team has Calico expertise OR BGP critical OR max simplicity (Flannel)
- **NGINX Ingress** UNLESS advanced routing (Traefik) OR API gateway (Kong)

### GitOps & CI/CD
- **Argo CD** UNLESS pure Git workflow (Flux) OR no UI needed (Flux) OR Helm automation (Flux)
- **GitHub Actions** UNLESS self-hosted Git (GitLab CI) OR complex workflows (Tekton)
- **Cloud Registry** UNLESS vendor independence critical (Harbor self-hosted)

### Observability
- **Prometheus + Grafana** UNLESS budget allows SaaS + small team (Datadog)
- **Loki** UNLESS advanced log analysis (ELK) OR team has ELK expertise

### Security
- **Vault + ESO** UNLESS cloud KMS acceptable (simpler) OR very few secrets (Sealed Secrets)
- **OIDC + RBAC** UNLESS no IdP exists (Keycloak)

### Data
- **Managed Database** UNLESS vendor independence > operational complexity (StatefulSet)
- **Velero + DB PITR** UNLESS CSI snapshots sufficient OR enterprise features (Kasten K10)
- **Valkey (Redis fork)** UNLESS existing Redis license OR cloud-managed acceptable

### Priority 2 (Future)
- **NO Service Mesh** UNLESS > 5 microservices + security needs
- **NO Distributed Tracing** UNLESS > 5 services + debugging takes > 1h
- **YES Cost Visibility (Day 1)** - easier to track from start
- **NO Multi-Region** UNLESS latency requirements OR DR active-active

---

## 8. Gaps & Inconsistencies

### Unanswered Assumptions
1. **Application Stateless?** - Assumption: Yes (sessions externalized) - **Must verify Q31**
2. **Team Accepts GitOps Learning Curve?** - Assumption: Yes with training - **Risk: Resistance**
3. **Managed DB Acceptable?** - Assumption: Operational simplicity > vendor independence - **Management decision needed**
4. **Budget Approved?** - Assumption: Yes - **Must confirm Q43-44**

### Conflicting Requirements
1. **Vendor Independence vs Operational Simplicity**
   - Resolution: Managed K8s (portable API) + Terraform + open-source tools
   - Accept: Managed DB as acceptable vendor dependency
   
2. **Security (No kubectl) vs Developer Productivity**
   - Resolution: GitOps only, Argo CD UI for visibility, break-glass for emergencies

3. **Budget vs Enterprise Features**
   - Resolution: Open-source stack, accept operational burden, consultant helps setup

### Missing Information (Blocks Detailed Planning)
- **Infrastructure**: Q5 (resources), Q43 (costs)
- **Application**: Q26 (database), Q31-34 (architecture)
- **Process**: Q10 (Git workflow), Q39 (approval process)
- **Security**: Q18 (IdP), Q19 (break-glass)

---

## 9. Next Steps & Implementation Guidance

### Before Implementation Starts

1. **Answer Critical Questions** (Q1, Q5, Q26, Q31-34, Q43-44)
2. **Engage External Consultant** (Q42 - Recommendation: **YES**)
3. **Team Training** (Kubernetes fundamentals, GitOps, observability)
4. **Proof of Concept** (Non-prod cluster, simple app, validate workflow)

### Implementation Phases (High-Level)

**Phase 1: Foundation** (Week 1-4) - Cluster, CNI, Ingress, GitOps, Observability  
**Phase 2: Hardening** (Week 5-8) - RBAC, Network Policies, Registry, Backup, CI/CD  
**Phase 3: Migration** (Week 9-12) - Containerization, DB migration, Caching, Dev env  
**Phase 4: Testing** (Week 13-16) - Staging, Load testing, DR testing, Runbooks  
**Phase 5: Cutover** (Week 17-20) - Production deployment, Blue-green cutover, Monitoring  

### Success Validation

| Metric | Target | Validation Method |
|--------|--------|-------------------|
| Deployment downtime | 0 minutes | Deploy during business hours |
| Incident detection | < 2 minutes | Simulate failures, measure alert time |
| Data recovery | 15 min RPO | Quarterly DR drill, restore test |
| Vendor migration | < 1 quarter | Annual portability review, test IaC reproduction |
| Developer self-service | Deploy via Git | Developers deploy without Ops involvement |

---

## 10. Interactive AI Advisor Workflow

*This document enables interactive decision support. Users answer critical questions to receive personalized recommendations.*

### Workflow Example:

**AI**: "Which managed Kubernetes provider are you leaning towards? (TransIP, OVHcloud, Scaleway, or self-managed?)"  
**User**: "TransIP"  
**AI**: "Excellent choice for a Dutch organization prioritizing GDPR compliance and local support. Next, what are your estimated CPU/memory requirements per application instance?"  
**User**: "Current VM runs with 4 CPU, 8GB RAM"  
**AI**: "Based on your requirements, I recommend starting with 2-3 worker nodes (8 CPU, 16GB each) for HA and capacity. This allows for rolling updates without resource constraints. Now, what is your current database? (MySQL, PostgreSQL, SQL Server, or other?)"  
[Continue through critical questions...]

**After all critical questions answered**: Provide personalized provider recommendations, tool stack, cost estimates, risk mitigations specific to their answers.

See **[AI_CASE_ADVISOR.md](../AI_CASE_ADVISOR.md)** for complete interactive agent instructions.

---

## 11. References & Related Documents

### KubeCompass Framework
- **[UNIFIED_CASE_STRUCTURE.md](../../UNIFIED_CASE_STRUCTURE.md)** - Template for this document
- **[FRAMEWORK.md](../../FRAMEWORK.md)** - Decision layers and timing
- **[SCENARIOS.md](../../SCENARIOS.md)** - Enterprise and other scenario examples

### Original Layer Documents (Source Material)
- **[PRIORITY_0_WEBSHOP_CASE.md](../../PRIORITY_0_WEBSHOP_CASE.md)** - Foundational requirements (1155 lines)
- **[PRIORITY_1_WEBSHOP_CASE.md](../../PRIORITY_1_WEBSHOP_CASE.md)** - Tool selection + 44 questions (579 lines)
- **[PRIORITY_2_WEBSHOP_CASE.md](../../PRIORITY_2_WEBSHOP_CASE.md)** - Enhancement triggers (644 lines)

### Interactive Tools
- **[tool-selector-wizard.html](../../tool-selector-wizard.html)** - Web UI for tool selection
- **[AI_CHAT_GUIDE.md](../../AI_CHAT_GUIDE.md)** - AI integration prompts

---

**Document Status**: ✅ Complete - Ready for Interactive Decision Support  
**Version**: 1.0  
**Last Update**: December 2024  
**License**: MIT - Free to use and adapt  
**Feedback**: Open an issue or PR on GitHub

---

*This document transforms 2378 lines of raw case analysis (Priority 0/1/2) into a structured decision framework suitable for interactive AI advisors, scenario comparison, and automated recommendations.*
