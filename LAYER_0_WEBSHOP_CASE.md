# Layer 0: Foundation & Context — Webshop Migration Case

**Target Audience**: Engineers, Architects, Management  
**Status**: Foundational — must be established before technical implementation begins  
**Organization**: Dutch webshop / online store with Essential SAFe methodology  

---

## What is Layer 0?

Layer 0 defines **the foundation on which all technical decisions are built**. It's not about concrete tools, YAML configurations, or pipelines, but about:

- **Non-functional requirements** that determine the platform architecture
- **Constraints** that cannot be changed without major impact
- **Principles** that guide all subsequent choices
- **Boundaries** of what is acceptable and what is not

### Why Layer 0 First?

Without a clear Layer 0 foundation:
- Fundamental choices are later dismissed as "details" while they determine the architecture
- Implicit assumptions lead to wrong tool choices
- There is no clear framework to evaluate decisions
- Vendor lock-in is accidentally accepted

**Layer 0 must be answered before you even begin with Kubernetes implementation.**

---

## Executive Summary

### Situation
Dutch webshop with Essential SAFe organization (multiple teams: Dev, Ops, Functional Management, Support) migrating from manual VM deployments to Kubernetes. Company sells physical products with own shipping throughout Europe. Downtime during checkout = direct revenue loss.

### Current Pain Points
- ✋ Manual releases (only Monday nights, with downtime)
- 🚨 Reactive incident detection (customers call, accidental discovery)
- 💾 Nightly backups without point-in-time recovery
- 🗄️ SQL database as single point of failure
- 🔧 Inconsistent VM configuration without systematic patching

### Strategic Goals (Layer 0)
1. **Zero-downtime deployments** — deploy when ready, not when "allowed"
2. **Proactive monitoring** — detect problems before customers call
3. **Data resilience** — point-in-time recovery, no transaction loss
4. **Vendor independence** — migration to another provider within 1 quarter possible
5. **Clear ownership** — Dev, Ops, and Support know who is responsible for what

### Fundamental Principles (Non-Negotiable)
- 🔐 **Security by design** — Least privilege, defense in depth, encryption
- 🔓 **Open-source preference** — No vendor lock-in, reproducible architecture
- 📝 **GitOps from day 1** — All deployments via Git, no manual kubectl
- 👥 **Shared responsibility** — Dev + Ops collaboration, not "everything to Ops"
- 🎯 **Business impact driven** — Decisions based on revenue risk, not tech hype

### Critical Success Criteria
| Criterion | Target | Current Situation |
|-----------|--------|------------------|
| **Deployment downtime** | 0 minutes (rolling updates) | 1-4 hours per release |
| **Incident detection** | < 2 minutes (alerts) | 10-60 minutes (customers call) |
| **Data recovery** | Point-in-time (max 15 min loss) | Last nightly backup |
| **Vendor migration time** | < 1 quarter | Unknown / not tested |
| **Developer self-service** | Deploy via Git PR | Ops does manually |

---

## Explicit Goals

### Primary Goals
1. **Eliminate Deployment Downtime**
   - Zero-downtime releases via rolling updates
   - Deploy when features are ready, not when "downtime is allowed"
   - Rollback capability within minutes

2. **Proactive Operations**
   - Detect issues before customers notice
   - Automated recovery for common failures
   - Clear dashboards for all teams (Dev, Ops, Support)

3. **Data Protection & Recovery**
   - Point-in-time recovery for critical data (orders, customer information)
   - Geographically distributed backups
   - Tested restore procedures (backups are worthless if restore doesn't work)

4. **Vendor Independence**
   - Migration to another cloud provider within 1 quarter
   - Open-source tooling preference
   - Infrastructure as Code for reproducible environments

5. **Clear Team Ownership**
   - Developers can deploy themselves (via GitOps)
   - Operations facilitates platform (not a bottleneck)
   - Support has insight without system access

### Secondary Goals
- Systematic patching and updates (not ad-hoc)
- Audit trail for compliance (who did what when)
- Foundation for future multi-region (not day 1, but architecture doesn't block it)
- Developer productivity (faster iteration, less waiting for Ops)

---

## Explicit Non-Goals (Out of Scope for Layer 0)

### What We Are NOT Doing (Now)
1. **Microservices Refactoring** ❌
   - Current MVC monolith remains intact
   - Focus: lift & shift to Kubernetes
   - Microservices are future option, not Layer 0 requirement

2. **Multi-Region Deployment** ❌
   - Too complex for organization without Kubernetes experience
   - Single region with option for later expansion
   - CDN for static assets is sufficient for latency improvement

3. **Advanced Observability** ❌
   - Distributed tracing is nice-to-have, not foundational
   - Focus on metrics and logs first
   - Tracing can come later (Layer 2)

4. **Service Mesh** ❌
   - Not needed for monolithic application
   - Can come later with microservices transition
   - Architecture must allow service mesh, but not implement it

5. **100% Uptime Guarantee** ❌
   - Realistic: incidents can happen
   - Focus: minimize downtime, not eliminate it
   - Accept that maintenance and incidents have impact

6. **Immediate Developer Kubernetes Access** ❌
   - Developers get NO kubectl access (security)
   - GitOps is only deployment method
   - Read-only dashboards are available

### Why This Is Important
Non-goals prevent **scope creep** and **analysis paralysis**. Teams tend to build "for the future", which leads to over-engineering and delays. Layer 0 is pragmatic: do what's needed, not what's nice.

---

## Hard Constraints

### Non-Negotiable Requirements

#### 1. Vendor Independence
- **Constraint**: Migration to another infrastructure provider must be possible within **1 quarter**
- **Implication**: No dependency on cloud-specific services (AWS ECS, Azure Container Apps, etc.)
- **Validation**: Infrastructure as Code must be reproducible on other clouds

#### 2. Data Sovereignty & GDPR
- **Constraint**: Customer data must remain within EU
- **Implication**: Datacenter choice limited to EU regions
- **Validation**: Backup storage must also be EU-compliant

#### 3. Business Continuity
- **Constraint**: Checkout functionality is **business-critical**
  - Max acceptable downtime: **30 minutes per month** (99.9% uptime target)
  - Max acceptable data loss (RPO): **15 minutes** for transactions
  - Max recovery time (RTO): **30 minutes** for critical systems
- **Implication**: High availability for database and application required

#### 4. Security Baseline
- **Constraint**: No production access for developers (compliance requirement)
- **Implication**: GitOps is only deployment method (no kubectl apply)
- **Validation**: RBAC policies must enforce this

#### 5. Operational Ownership
- **Constraint**: Operations remains owner of production environment
- **Implication**: Developers can deploy themselves, but Ops determines guardrails (resource limits, security policies)
- **Validation**: Platform team has final say over cluster configuration

#### 6. Budget Realism
- **Constraint**: No enterprise SaaS budgets (Datadog, New Relic, etc.)
- **Implication**: Open-source tooling preference
- **Validation**: Choices must be justified without vendor support contracts

#### 7. Team Maturity
- **Constraint**: Team has **no Kubernetes experience** (training needed)
- **Implication**: Start simple, no complex multi-cluster setups
- **Validation**: Operational model must be feasible for team of ~10 people

### Trade-offs We Accept

| Trade-off | Choice | Rationale |
|-----------|--------|-----------|
| **Managed Kubernetes vs. Self-hosted** | Managed (at Dutch provider) | Team has no experience; managed reduces operational burden |
| **Managed Database vs. Kubernetes StatefulSet** | TBD in Layer 1 | Balance between vendor independence and operational complexity |
| **Open-source vs. SaaS observability** | Open-source (Prometheus/Grafana) | Budget + vendor independence |
| **GitOps complexity vs. Control** | Accept learning curve | Security and audit trail justify investment |

---

## Explicit Risks & Mitigations

### High Risk (Must Be Mitigated)

#### 1. Team Has No Kubernetes Experience
- **Risk**: Wrong architecture choices, operational blunders, long learning curve
- **Impact**: Downtime, security incidents, frustration
- **Mitigation**:
  - [ ] External Kubernetes consultant for initial setup (3-6 months)
  - [ ] Training for team (official courses + hands-on workshops)
  - [ ] Proof of Concept in non-production environment first
  - [ ] Extensive documentation and runbooks

#### 2. Database Migration is Complex
- **Risk**: SQL database is single point of failure; migration to HA setup is complex
- **Impact**: Downtime during migration, potential data loss
- **Mitigation**:
  - [ ] Start with read-replicas (no failover) for query load distribution
  - [ ] Test restore procedures extensively in non-prod
  - [ ] Consider managed database (cloud provider) for HA capabilities
  - [ ] Schema migrations must be backward compatible (blue-green capable)

#### 3. Vendor Lock-in By Accident
- **Risk**: Use of vendor-specific features "because it's easy"
- **Impact**: Cannot migrate within 1 quarter (hard constraint breach)
- **Mitigation**:
  - [ ] Architecture review board (Ops + external consultant)
  - [ ] Explicit "portability checklist" for every tool choice
  - [ ] Infrastructure as Code from day 1 (no manual configuration)
  - [ ] Quarterly review: "Can we still migrate?"

#### 4. GitOps Workflow Breaks Existing Process
- **Risk**: Essential SAFe process doesn't fit GitOps branching strategy
- **Impact**: Confusion, workarounds, manual kubectl usage (security risk)
- **Mitigation**:
  - [ ] Map SAFe sprints to Git workflow (trunk-based vs. GitFlow)
  - [ ] Clear escalation path for hotfixes (bypass normal PR flow?)
  - [ ] Training for POs and functional management (not just engineers)
  - [ ] Pilot with 1 team first, then roll-out to other teams

### Medium Risk (Monitor & Plan)

#### 5. Observability Overwhelm
- **Risk**: Too many metrics, alerts, dashboards → alert fatigue
- **Impact**: Real problems are missed in the noise
- **Mitigation**:
  - [ ] Start with basics: uptime, error rate, response time
  - [ ] Iteratively add alerts (not everything day 1)
  - [ ] Alert review each sprint (disable irrelevant alerts)

#### 6. Costs Escalate
- **Risk**: Cloud costs higher than expected (storage, egress, compute)
- **Impact**: Budget overrun, management dissatisfaction
- **Mitigation**:
  - [ ] Cost monitoring from day 1 (OpenCost / Kubecost)
  - [ ] Resource limits per namespace (no unbounded growth)
  - [ ] Monthly cost review with management

#### 7. Security Gaps in Migration
- **Risk**: VM security model != Kubernetes security model
- **Impact**: Unintended attack surface, compliance issues
- **Mitigation**:
  - [ ] Security assessment of current VM setup (baseline)
  - [ ] Network policies from day 1 (deny-all default)
  - [ ] Image scanning in CI/CD (no known CVEs in prod)

### Low Risk (Acceptable)

#### 8. Multi-Region Latency (Southern Europe)
- **Risk**: Customers in Spain/Italy have slower experience
- **Impact**: Lower conversion, complaints
- **Acceptance**: Single region is conscious choice (complexity vs. business impact)
- **Future Plan**: CDN first, multi-region later (after 6-12 months Kubernetes experience)

---

## 1. Business Context & Impact

### 1.1 Business Model
- **Product**: Physical products sold via webshop
- **Distribution**: Own shipping throughout Europe
- **Revenue**: Directly dependent on webshop availability
- **Critical functionality**:
  - Product search (annoying if it doesn't work)
  - Order and payment (**business-critical** — direct revenue loss during downtime)

### 1.2 Business Impact of Downtime
- **Direct**: Revenue loss during downtime period
- **Indirect**: Customer trust damaged
- **Cumulative**: Repeated failures = customers don't return
- **Reputation**: Negative reviews, social media impact

**Conclusion**: Availability is **business-critical**, not just a technical metric.

---

## 2. Availability & Downtime Expectations

### 2.1 Current Situation (AS-IS)
- Releases only Monday nights
- Downtime is **expected** during releases
- Problems discovered reactively (via customers or chance)
- No distinction between planned and unplanned downtime

### 2.2 Target (TO-BE)
**Qualitative goals** (SLAs come in Layer 1):

1. **Releases without downtime**
   - Deploy when features are ready, not when "downtime is allowed"
   - Rolling updates as standard
   - Rollback capability within minutes

2. **Unplanned downtime minimized**
   - High availability (HA) for critical components
   - No single points of failure
   - Automatic failover where possible

3. **Planned maintenance without impact**
   - Apply updates and patches without customer impact
   - Node drain and pod migration as standard

### 2.3 Realistic Expectations

**What IS achievable** (with Kubernetes):
- Zero-downtime deployments for application layers
- Automatic restart of failed pods
- Rolling updates with health checks
- Gradual traffic shift (canary/blue-green possible in later phase)

**What is NOT achievable** (without extra investments):
- 100% uptime — accept that incidents can occur
- Zero-downtime for database schema migrations — requires application architecture changes
- Instant failover during datacenter failure — multi-region required (see section 8)

### 2.4 Acceptance Criteria

- [ ] Application can deploy without downtime (rolling update)
- [ ] Failed pods automatically restart within 30 seconds
- [ ] Database downtime is **not eliminated**, but **isolated** (application keeps running with fallback behavior)
- [ ] Maintenance windows are **no longer needed** for application updates

---

## 3. Data Criticality & Continuity

### 3.1 Biggest Fears (Customer Input)
1. **Downtime**: Webshop is not reachable → direct revenue loss
2. **Data loss**: Orders, customer information, transactions lost → irreparable

### 3.2 Current Backup Strategy
- Nightly SQL backups
- **Limitation**: Point-in-time recovery is not possible
- **Risk**: Loss of all transactions since last backup

### 3.3 Layer 0 Requirements

**Data Classification**:
| Data Type | Criticality | RPO (Recovery Point Objective) | RTO (Recovery Time Objective) |
|-----------|-------------|-------------------------------|-------------------------------|
| **Orders & Transactions** | Business-critical | Max 15 minutes | Max 30 minutes |
| **Customer Information** | High (GDPR) | Max 1 hour | Max 1 hour |
| **Product Catalog** | Medium | Max 24 hours | Max 2 hours |
| **Session Data** | Low (acceptable loss) | N/A | N/A |

**Backup Principles**:
- **Point-in-time recovery** is a hard requirement
- **Geographic distribution** of backups (not in same datacenter)
- **Tested restore process** — backups are worthless if restore doesn't work
- **Encryption at rest** for all backups (GDPR compliance)

**Database Continuity**:
- **Eliminate single point of failure**:
  - SQL database must be HA (replication, failover)
  - Read-replicas for query load distribution
- **Application architecture changes**:
  - Retry logic for temporary database failures
  - Circuit breaker pattern to prevent cascading failures
  - Caching layer (Redis/Valkey) to reduce database load

**What is NOT in Layer 0**:
- Specific backup tool choice (Velero, Kasten, etc.) → Layer 1
- Exact backup frequency (hourly, every 4 hours) → Layer 1
- Database technology choice (PostgreSQL HA, MySQL Cluster) → Layer 1

---

## 4. Security Baseline (Conceptual)

### 4.1 Current Situation
- Manual VM configuration → inconsistent security posture
- No systematic patching
- Access management poorly documented

### 4.2 Layer 0 Security Principles

**1. Least Privilege**
- Developers have **no** production access (unless explicitly needed)
- Operations has **namespace-scoped** access (not cluster-admin for everything)
- Service accounts have **minimal permissions** (not `cluster-admin` for applications)

**2. Defense in Depth**
- Security is **layered** (not dependent on one control)
- Network policies (limit pod-to-pod communication)
- Pod Security Standards (no privileged containers without good reason)
- Image scanning (detect vulnerabilities before deployment)

**3. Encryption**
- **In Transit**: TLS required for all external communication
- **At Rest**: Sensitive data encrypted in database and backups
- **Secrets Management**: No credentials in Git, environment variables, or plaintext ConfigMaps

**4. Audit & Compliance**
- **Who did what when**: All changes traceable (GitOps!)
- **GDPR compliance**: Data residency, right to be forgotten, data encryption
- **Audit logs**: Retained for at least 1 year

**5. Supply Chain Security**
- **Image provenance**: Know where container images come from
- **Vulnerability scanning**: Block known CVEs
- **Image signing**: Verify authenticity (optional in first phase, but architecture must allow it)

### 4.3 Security Ownership

| Responsibility | Owner | Support from |
|----------------|-------|--------------|
| **Platform security** (cluster hardening, RBAC, network policies) | Ops/Platform team | Security Officer |
| **Application security** (secure coding, dependency updates) | Development teams | Security Officer |
| **Incident response** | Ops team (first response) | Security Officer (escalation) |
| **Compliance audits** | Security Officer | Ops + Dev (documentation) |

---

## 5. Observability Expectations

### 5.1 Current Situation (Reactive)
- Problems discovered via:
  - Customers calling support
  - Employees "accidentally" noticing something
- No proactive monitoring
- No clear "single pane of glass"

### 5.2 Layer 0 Observability Requirements

**Proactive Detection**:
- **Before customers notice**: Alerts on critical metrics (response time, error rate, pod crashes)
- **Root cause analysis**: Be able to trace why something went wrong
- **Trend analysis**: Detect slow degradation before it becomes an incident

**Three Pillars**:
1. **Metrics**: "Is the system healthy?" (CPU, memory, request latency, error rates)
2. **Logs**: "What exactly happened?" (application logs, audit logs)
3. **Traces**: "Where is the bottleneck?" (request flow through microservices — not now, but architecture must allow it)

**Self-Service for Teams**:
- Developers can view **their own dashboards** (no dependency on Ops)
- Support team can do **basic troubleshooting** without involving ops

**Alerting Principles**:
- **Actionable**: Every alert must have a clear action (no alert fatigue)
- **Context**: Alert contains relevant info (which pod, which namespace, which customer impact)
- **Routing**: Critical alerts → PagerDuty/ops on-call, warnings → Slack/Teams

### 5.3 Realistic Scope

**What IS in Layer 0**:
- ✅ Observability is **non-optional** — must be present from day 1
- ✅ Metrics, logs, and dashboards for **all workloads**
- ✅ Alerts for **business-critical scenarios** (payment fails, webshop down)

**What is NOT in Layer 0**:
- ❌ Tool choice (Prometheus, Datadog, etc.) → Layer 1
- ❌ Exact metrics and alert thresholds → Layer 1
- ❌ Distributed tracing (nice to have, can come later) → Layer 2

---

## 6. Ownership Model: Dev / Ops / Support

### 6.1 Current Situation
- **Ops**: Owner of production, detects and resolves incidents
- **Dev**: Delivers code, limited involvement in production behavior
- **Support**: First line contact with customers, escalates to Ops

### 6.2 Layer 0 Ownership Principles

**Shared Responsibility Model**:

| Responsibility | Dev | Ops | Support |
|----------------|-----|-----|---------|
| **Code quality** | ✅ Owner | 🤝 Reviews (code review, security scan) | ❌ |
| **Deployment** | ✅ Triggers (via GitOps) | 🤝 Facilitates (platform available) | ❌ |
| **Monitoring & Alerts** | ✅ Defines application metrics | ✅ Defines platform metrics | 🤝 Views dashboards |
| **Incident Detection** | 🤝 Application alerts | ✅ Platform alerts | 🤝 Customer reports |
| **Incident Response** | 🤝 Application issues | ✅ Platform issues | ✅ First line triage |
| **Post-Mortem** | ✅ Application root cause | ✅ Platform root cause | 🤝 Customer impact analysis |

**Operational Model**:
1. **Self-service for Dev**:
   - Developers can deploy themselves (via GitOps)
   - Developers can view logs and metrics
   - Developers have **no** kubectl access to production (GitOps only)

2. **Ops as Platform Team**:
   - Ops builds and maintains the Kubernetes platform
   - Ops defines **guardrails** (resource limits, security policies)
   - Ops does **not** escalate all application issues back to Dev (clear ownership)

3. **Support as First Line**:
   - Support has **read-only** dashboards (is webshop reachable, are there errors)
   - Support escalates to Ops (platform issue) or Dev (application issue)
   - Support has **no** access to systems (only observability dashboards)

### 6.3 On-Call & Escalation

**Layer 0 Principle**: Clear escalation paths, not "everything to Ops"

| Scenario | First Responder | Escalation |
|---------|----------------|------------|
| **Webshop unreachable** | Ops (platform issue) | Dev (if application is the cause) |
| **Payment fails** | Dev (application logic) | Ops (if database is down) |
| **Slow performance** | Dev (query optimization) | Ops (if resource exhaustion) |
| **Security incident** | Ops (isolate threat) | Security Officer + Dev |

**On-Call Rotation** (outside Layer 0 scope, but establish principle):
- Ops on-call for **platform** (cluster down, node failures)
- Dev on-call for **application** (bug in code, payment service down) — consider this in later phase

---

## 7. Strategic Requirements: Portability & Vendor Lock-in

### 7.1 Explicit Customer Requirement
> "Vendor lock-in is an explicit concern. We want to be able to migrate to another infrastructure provider within one quarter without functional loss."

### 7.2 Layer 0 Portability Principles

**1. Cloud-Agnostic Architecture**
- **No dependency on cloud-specific services** (AWS ECS, Azure Container Apps, GCP Cloud Run)
- **Kubernetes as portability layer**: Workloads run on standard Kubernetes APIs
- **Open-source tooling preference**: No vendor SaaS where possible

**2. Infrastructure as Code**
- Complete cluster + tooling **reproducible** via IaC (Terraform, Pulumi, etc.)
- **No manual configuration** — everything in Git
- **Datacenter swap** is a `terraform apply` in another environment (in theory)

**3. Data Portability**
- **Backups cloud-agnostic**: S3-compatible API (not AWS S3 APIs that only work on AWS)
- **Database**: Open-source (PostgreSQL, MySQL) → no vendor-managed DB where migration is difficult
- **Object storage**: MinIO (self-hosted) or S3-compatible → no Azure Blob/GCS lock-in

**4. Network & Identity Portability**
- **CNI choice**: Open-source (Cilium, Calico) → no cloud-native only solutions
- **Identity provider**: Self-hosted (Keycloak) or cloud-agnostic → no AWS IAM / Azure AD exclusive integrations
- **Load balancing**: Kubernetes Ingress (not cloud-specific ALB/NLB configurations)

### 7.3 Realistic Limitations and Concessions

**What IS achievable**:
- ✅ Workloads run on any Kubernetes distribution (AKS, GKE, EKS, on-prem)
- ✅ IaC can reproduce cluster on another cloud within 1 week
- ✅ Backups are portable (S3-compatible API)

**What is NOT achievable** (without concessions):
- ❌ Instant migration without any adjustment (DNS, IPs, load balancers always change)
- ❌ Using zero cloud-native features (managed databases are sometimes the best choice for HA — make trade-off)

### 7.4 Tooling Lock-in Risk Matrix

| Tool Category | High Risk (Avoid) | Low Risk (Acceptable) |
|---------------|-------------------|-----------------------|
| **Compute** | AWS ECS, Azure Container Apps | Kubernetes (available everywhere) |
| **Database** | AWS Aurora (proprietary), Azure Cosmos | PostgreSQL HA, MySQL Cluster |
| **Object Storage** | AWS S3 APIs (without S3-compatible fallback) | MinIO, S3-compatible cloud storage |
| **Identity** | AWS IAM only, Azure AD only | Keycloak (self-hosted), OIDC providers |
| **Networking** | AWS VPC CNI (EKS-only) | Cilium, Calico (cloud-agnostic) |
| **GitOps** | Vendor SaaS (without export) | Argo CD, Flux (self-hosted) |

**Layer 0 Decision**: **Open-source and self-hosted preference**, unless managed service has clear advantage (and migration path exists).

---

## 8. Fundamental Architecture Decisions (Multi-Region, Networking, Identity)

### 8.1 Multi-Region / Multi-Cluster

**Current requirement**: Customers throughout Europe, website slow from Southern Europe.

**Layer 0 Question**: Do we want multi-region from day 1?

**Analysis**:
- **Advantage**: Lower latency, disaster recovery
- **Disadvantage**: Complexity (data replication, cross-region networking, costs)

**Layer 0 Decision**:
- ❌ **NOT multi-region from day 1** (too complex for organization without Kubernetes experience)
- ✅ **Architecture that allows multi-region** (no design decisions that block multi-region)
- ✅ **CDN for static assets** (first step for latency improvement) → Layer 1 decision

**Criteria for multi-region in future**:
- [ ] Single-region setup is stable (> 3 months without major incidents)
- [ ] Team has experience with Kubernetes operations
- [ ] Business case is clear (how much revenue do we gain with lower latency?)

### 8.2 Networking & CNI Considerations

**Layer 0 Question**: Which CNI fundamentals are unchangeable?

**Analysis**:
| CNI Choice | Changeability | Impact |
|-----------|--------------|--------|
| **CNI plugin** (Cilium, Calico, Flannel) | Very difficult (requires cluster rebuild or downtime) | ❗ Layer 0 decision |
| **Service Mesh** (Istio, Linkerd) | Difficult but possible (additive) | ⚠️ Layer 0/1 boundary — not needed from day 1 |
| **Network Policies** (enabled/disabled) | Easy to enable later | ✅ Layer 1 decision |

**Layer 0 Decisions**:
- ✅ **CNI must be multi-region capable** (no single-zone only solutions)
- ✅ **CNI must support Network Policies** (security requirement)
- ✅ **Performance is important** (webshop must be fast)
- ❌ **Service mesh is NOT a Layer 0 requirement** (can come later, with microservices architecture)

**Criteria for CNI choice** (tooling in Layer 1):
- Supports Network Policies (security)
- Cloud-agnostic (portability)
- Performance (eBPF preference over iptables)
- Community support (not single-vendor)

### 8.3 Identity & Access Management

**Layer 0 Question**: How do we authenticate people and machines?

**Fundamental Choices**:
1. **User Authentication**: How do developers/ops log in to cluster?
   - **Option A**: kubeconfig files (simple, but not scalable)
   - **Option B**: OIDC provider (Keycloak, cloud IdP) — scalable, audit trails
   - **Layer 0 Decision**: **OIDC is end state**, but kubeconfig files are acceptable for first months (team is small)

2. **Service Account Management**: How do applications authenticate?
   - **Principle**: Each application gets **its own service account** (no shared secrets)
   - **Principle**: Service accounts have **minimal permissions** (namespace-scoped)
   - **Layer 0 Decision**: **RBAC is mandatory** from day 1

3. **Secrets Management**: Where do we store credentials?
   - **Principle**: **Never in Git** (not even encrypted — rotation is too difficult)
   - **Principle**: **External secrets** preference (Vault, cloud secret managers)
   - **Layer 0 Decision**: **Secrets management is Layer 0** — must be right from day 1 (difficult to fix later)

**Identity Provider Decision**:
- ✅ **Self-hosted preference** (Keycloak) for vendor independence
- ⚠️ **Cloud IdP acceptable** if self-hosted is too complex (pragmatism)
- ❌ **No kubeconfig files long-term** (not scalable, no audit trail)

### 8.4 GitOps: Yes or No?

**Layer 0 Question**: Is GitOps a fundamental principle, or "nice to have"?

**Arguments for GitOps**:
- ✅ **Audit trail**: All changes in Git (compliance)
- ✅ **Rollback**: Git revert = rollback deployment
- ✅ **Declarative**: Desired state in Git, Kubernetes converges to it
- ✅ **Self-service**: Developers deploy via PR (no kubectl access needed)

**Arguments against GitOps**:
- ⚠️ **Learning curve**: Team must learn Git, PR workflows, and GitOps tool
- ⚠️ **Initial complexity**: Repo structure, branching strategy, environments

**Layer 0 Decision**: 
- ✅ **GitOps is Layer 0 principle** — too fundamental for workflow to add later
- ✅ **All deployments via Git** (no manual kubectl apply)
- ✅ **Architecture must support GitOps** from day 1

**Rationale**: Without GitOps there is no audit trail, no reproducible deployments, and too much kubectl access needed (security risk).

---

## 9. What Does NOT Belong in Layer 0

Layer 0 is **fundamental and strategic**, not tactical. The following do **not** belong in Layer 0:

### 9.1 Concrete Tool Choices
- ❌ "We use Cilium" → This is Layer 1 (after analysis of CNI requirements)
- ❌ "We use Argo CD" → This is Layer 1 (after analysis of GitOps requirements)
- ✅ "We need a CNI that supports Network Policies" → This is Layer 0

### 9.2 Operational Details
- ❌ Backup frequency (hourly, every 4 hours) → Layer 1
- ❌ Prometheus retention (15 days, 30 days) → Layer 1
- ✅ "Backups must support point-in-time recovery" → Layer 0

### 9.3 Implementation Specifications
- ❌ How many nodes, which instance types → Layer 1 (sizing)
- ❌ Which namespaces, which resource quotas → Layer 1 (multi-tenancy design)
- ✅ "Resources must be limited to prevent resource exhaustion" → Layer 0

### 9.4 Features That Can Come Later
- ❌ Service mesh (Istio, Linkerd) → Layer 2 (can come later, with microservices architecture)
- ❌ Chaos engineering (Chaos Mesh) → Layer 2 (valuable, but not foundational)
- ❌ Advanced observability (distributed tracing) → Layer 2 (metrics and logs first)
- ✅ "Observability must be proactive" → Layer 0

---

## 10. Assumptions That Must Be Validated (in Subsequent Layers)

Layer 0 makes **strategic choices**, but not everything is known now. The following assumptions must be validated in Layer 1 and beyond:

### 10.1 Application Architecture Assumptions

**Assumption**: Current MVC monolith can move to Kubernetes **without refactoring**.
- **Validation needed**: 
  - [ ] Is the application **stateless** (sessions in database/Redis, not in memory)?
  - [ ] Can the application **scale horizontally** (multiple replicas without problems)?
  - [ ] Are there **hardcoded localhost/IP dependencies** (database connection strings, etc.)?

**Assumption**: Database migration to Kubernetes is desired.
- **Validation needed**:
  - [ ] Is it better to keep database **outside Kubernetes** (managed cloud database)?
  - [ ] What is the effort of database HA configuration (replication, failover)?
  - [ ] Is StatefulSet sufficient, or do we need a Kubernetes Operator?

**Assumption**: No microservices architecture **now**, but must be possible **later**.
- **Validation needed**:
  - [ ] Which parts of the monolith can be extracted first (e.g., search, payment)?
  - [ ] Is async messaging needed (NATS, Kafka) or does everything stay synchronous?

### 10.2 Datacenter & Infrastructure Assumptions

**Assumption**: Dutch datacenter provider offers **Kubernetes-compatible infrastructure**.
- **Validation needed**:
  - [ ] Is managed Kubernetes available, or self-hosted (Kubeadm, RKE)?
  - [ ] Which storage options are available (block storage, NFS, object storage)?
  - [ ] Which network features are available (load balancers, VPC, etc.)?

**Assumption**: Multi-cloud is **not needed**, but vendor switch must be possible.
- **Validation needed**:
  - [ ] How easy is it to reproduce cluster with another provider?
  - [ ] Which datacenter-specific features do we use (and do we accept that lock-in)?

### 10.3 Team & Organization Assumptions

**Assumption**: Team has **no Kubernetes experience**, but wants to learn.
- **Validation needed**:
  - [ ] How much training is needed (1 week, 1 month)?
  - [ ] Can we engage external consultants for initial setup?
  - [ ] What is the ramp-up time for self-sufficiency?

**Assumption**: Essential SAFe process fits GitOps workflow.
- **Validation needed**:
  - [ ] How do we map sprints to Git branching strategy?
  - [ ] Who approves production deployments (PO, tech lead, ops)?
  - [ ] How do we handle hotfixes (direct to prod or via staging)?

### 10.4 Security & Compliance Assumptions

**Assumption**: GDPR compliance is sufficient, no additional compliance regimes (PCI-DSS, ISO 27001).
- **Validation needed**:
  - [ ] Are there payment details requiring PCI-DSS (or is payment external — Stripe/Mollie)?
  - [ ] Are there industry-specific compliance requirements (medical devices, financial services)?

**Assumption**: Current security posture is "good enough" for migration to Kubernetes.
- **Validation needed**:
  - [ ] Are there known vulnerabilities in current stack (OS patches, library updates)?
  - [ ] Should we do security audit **before** migration (establish baseline)?

---

## 11. Summary: Layer 0 Decision Tree

Before moving to Layer 1 (tool selection), these questions must be **clearly answered**:

### ✅ Availability
- [ ] **Zero-downtime deployments are a requirement** (rolling updates, health checks)
- [ ] **High availability for critical components** (database, load balancer)
- [ ] **Accept that 100% uptime is not achievable** (realistic)

### ✅ Data
- [ ] **Point-in-time recovery is mandatory** (not just nightly backups)
- [ ] **Geographic backup distribution** (not in same datacenter as production)
- [ ] **Tested restore process** (backups are worthless if restore doesn't work)

### ✅ Security
- [ ] **Least privilege principle** (developers no production access, service accounts minimal permissions)
- [ ] **Defense in depth** (security is layered, not single control)
- [ ] **Encryption in transit and at rest** (TLS, database encryption, backup encryption)
- [ ] **Secrets management from day 1** (not in Git, not in plaintext)

### ✅ Observability
- [ ] **Proactive monitoring** (not reactive via customers)
- [ ] **Metrics, logs, dashboards for all workloads** (no blind spots)
- [ ] **Self-service for teams** (developers can view own dashboards)

### ✅ Ownership
- [ ] **Shared responsibility model** (dev + ops, not "everything to ops")
- [ ] **Self-service deployment** (GitOps, no kubectl access)
- [ ] **Clear escalation paths** (not "everything to ops")

### ✅ Portability
- [ ] **Cloud-agnostic architecture** (no vendor lock-in)
- [ ] **Infrastructure as Code** (reproducible)
- [ ] **Open-source tooling preference** (unless managed service has clear advantage)

### ✅ Fundamental Architecture
- [ ] **GitOps is a principle** (all deployments via Git)
- [ ] **CNI must support Network Policies** (security)
- [ ] **RBAC is mandatory** (not cluster-admin for everyone)
- [ ] **Multi-region is future possibility** (not day 1, but architecture doesn't block it)

---

## 12. Targeted Follow-up Questions for Layer 1 Transition

Before you can start Layer 1 (concrete tool selection and platform capabilities), the following questions must be answered. These questions are **specific enough** to inform technical decisions, but **abstract enough** to not yet choose tools.

### 12.1 Application Architecture & Readiness

#### Database & Stateful Workloads
- **Q1**: Is the current MVC application **stateless**?
  - Are sessions stored in database/Redis, or in application memory?
  - Impact: Determines if horizontal scaling is possible without code changes

- **Q2**: Where does the SQL database run?
  - In the same VM as application, or dedicated database server?
  - Impact: Determines migration strategy (StatefulSet vs. external managed database)

- **Q3**: What is the current database size and load?
  - How many GB data, how many queries per second?
  - Impact: Storage sizing, HA strategy (read-replicas, sharding)

- **Q4**: Are database schema migrations backward compatible?
  - Can old application version work with new database schema?
  - Impact: Determines if blue-green deployments are possible

#### Application Dependencies
- **Q5**: Does the application use **hardcoded localhost references**?
  - Database connection strings, cache URLs, external API endpoints?
  - Impact: Must code be adapted for Kubernetes service discovery?

- **Q6**: What are the external dependencies?
  - Payment providers (Stripe, Mollie), shipping APIs, email services?
  - Impact: Network policies, egress filtering, secret management

- **Q7**: How many resources does the application use?
  - CPU, memory, disk I/O (metrics from current VM)?
  - Impact: Pod resource requests/limits, node sizing

### 12.2 Infrastructure & Datacenter Capabilities

#### Dutch Cloud Provider Capabilities
- **Q8**: Which Kubernetes distribution does the provider offer?
  - Managed Kubernetes (e.g., OpenShift, Rancher), or IaaS VMs (self Kubeadm)?
  - Impact: Operational complexity, upgrade strategy

- **Q9**: Which storage options are available?
  - Block storage (persistent volumes), NFS, object storage (S3-compatible)?
  - Impact: StorageClass choices, backup strategy

- **Q10**: Which network features are available?
  - Load balancers (Layer 4, Layer 7), floating IPs, private VPC?
  - Impact: Ingress controller choice, external-dns possibilities

- **Q11**: Is geographic replication possible?
  - Multiple datacenters within NL, or also other EU countries?
  - Impact: Multi-region strategy, backup georedundancy

- **Q12**: What is the infrastructure provider's SLA?
  - Uptime guarantees, support response times?
  - Impact: Realistic availability targets for application

#### Costs & Budgets
- **Q13**: What is the current monthly infrastructure budget?
  - VM costs, storage, bandwidth?
  - Impact: Cluster sizing, managed vs. self-hosted trade-offs

- **Q14**: What is the budget for tooling and SaaS?
  - Can we afford managed services (e.g., managed Prometheus, managed Vault)?
  - Impact: Open-source self-hosted vs. managed service choices

### 12.3 Team & Organization

#### Team Skills & Capacity
- **Q15**: How many FTE does the Ops team have?
  - Can they do platform maintenance alongside BAU work?
  - Impact: Managed Kubernetes vs. self-hosted, automation priorities

- **Q16**: What is the current Git workflow?
  - Trunk-based, GitFlow, feature branches?
  - Impact: GitOps branching strategy, environment promotions

- **Q17**: Are there dedicated security engineers?
  - Or is security part of Ops team?
  - Impact: Security tooling complexity (self-managed OPA vs. simpler alternatives)

#### Deployment & Release Process
- **Q18**: How often does the business want releases?
  - Daily, weekly, per sprint?
  - Impact: CI/CD pipeline design, deployment frequency targets

- **Q19**: Who approves production deployments?
  - PO, tech lead, ops team, or automated (after tests)?
  - Impact: GitOps approval workflows, manual gates

- **Q20**: How do we handle hotfixes?
  - Direct to prod, or via normal staging flow?
  - Impact: Emergency deployment procedures, GitOps bypass policies

### 12.4 Security & Compliance

#### Security Posture Baseline
- **Q21**: What security controls exist now?
  - Firewalls, IDS/IPS, antivirus, patching schedule?
  - Impact: Equivalent controls in Kubernetes (network policies, runtime security)

- **Q22**: Is PCI-DSS compliance needed?
  - Are credit card details stored, or is payment external (Stripe/Mollie)?
  - Impact: Stricter security controls, audit logging, encryption requirements

- **Q23**: Who has production access now?
  - Which teams, which people, what access level?
  - Impact: RBAC design, audit logging, break-glass procedures

#### Secrets & Credentials
- **Q24**: Where are secrets currently stored?
  - Environment variables, config files, dedicated secret store?
  - Impact: Kubernetes secrets management strategy

- **Q25**: How often must credentials be rotated?
  - Monthly, quarterly, ad-hoc?
  - Impact: Secret rotation automation, external secret store choice

### 12.5 Observability & Alerting

#### Current Monitoring
- **Q26**: What is currently monitored (if anything)?
  - Uptime checks, resource utilization, application metrics?
  - Impact: Baseline for new observability stack

- **Q27**: Which metrics are business-critical?
  - Checkout conversion rate, order processing time, payment success rate?
  - Impact: Custom application metrics, business dashboards

- **Q28**: Who should receive alerts?
  - Ops on-call, dev team, support team (for different alert types)?
  - Impact: Alerting routing rules, escalation policies

#### Incident Management
- **Q29**: What is the current incident response procedure?
  - Runbooks, escalation matrix, postmortem process?
  - Impact: Observability tool choices (must integrate with existing process)

- **Q30**: How is customer impact currently communicated?
  - Status page, email, support team calls customers?
  - Impact: Status page integration, automated incident detection

### 12.6 Data Protection & Backup

#### Backup Requirements
- **Q31**: What is the current backup retention policy?
  - Daily for 7 days, weekly for 1 month, etc.?
  - Impact: Backup storage sizing, retention automation

- **Q32**: Are backups encrypted?
  - At rest encryption, encryption key management?
  - Impact: Backup tool choice, KMS integration

- **Q33**: How often are restores tested?
  - Monthly, quarterly, never?
  - Impact: Disaster recovery testing procedures

#### Disaster Recovery
- **Q34**: What is acceptable data loss for different data types?
  - Orders (15 min), product catalog (24 hours), sessions (acceptable loss)?
  - Impact: Backup frequency, replication strategy

- **Q35**: What is the acceptable recovery time?
  - How many hours/days may it take to recover from disaster?
  - Impact: DR automation, documented recovery procedures

### 12.7 Migration & Cutover

#### Migration Strategy
- **Q36**: Is a staging environment available?
  - Can we migrate non-prod first to learn?
  - Impact: Phased migration vs. big bang

- **Q37**: Can we do blue-green deployment during cutover?
  - Old and new system run in parallel, traffic switch?
  - Impact: DNS strategy, rollback plan

- **Q38**: What is acceptable downtime during migration?
  - Zero downtime (complex), or planned maintenance window (simpler)?
  - Impact: Migration strategy complexity

#### Rollback Planning
- **Q39**: What is the rollback scenario if Kubernetes migration fails?
  - Back to old VMs (are they still available?)
  - Impact: Keep old infrastructure alive for X months

- **Q40**: How quickly must we be able to rollback?
  - Within 1 hour, within 1 day?
  - Impact: Automation level of rollback procedures

---

### Summary: Layer 0 → Layer 1 Readiness Checklist

✅ **Ready for Layer 1** if:
- [ ] All 40 questions above are answered (or explicitly marked as "TBD in Layer 1")
- [ ] Business context is clear (who are stakeholders, what are their pain points)
- [ ] Hard constraints are documented (vendor independence, GDPR, budget)
- [ ] Risks are identified with mitigation plans
- [ ] Team capabilities are realistically assessed (not over-optimistic)

❌ **NOT yet ready for Layer 1** if:
- [ ] There are conflicting requirements (e.g., "zero downtime" vs. "no budget for HA")
- [ ] Team has no time for training (Kubernetes knowledge is essential)
- [ ] Infrastructure provider capabilities are unknown (can block during implementation)
- [ ] Security baseline is unclear (risk of compliance issues later)

---

## 13. Next Steps: From Layer 0 to Layer 1

Now that Layer 0 is established, Layer 1 can begin:

### Layer 1 Scope (Within 1-2 Weeks)
- **Tool selection**: Which concrete tools (Cilium vs Calico, Argo CD vs Flux, etc.)
- **Cluster sizing**: How many nodes, which instance types
- **Network design**: Subnets, load balancers, DNS
- **Storage design**: Which StorageClasses, backup strategy
- **Security design**: RBAC roles, network policies, pod security standards

### Layer 1 Deliverables
- Architecture diagram (network, storage, observability)
- Tool selection matrix (with rationale per choice)
- Proof of Concept planning (which features do we test first)

### Layer 2 Scope (Month 2-3)
- Implementation of platform (cluster setup, tooling installation)
- Migration of first application (test workload)
- Team training (Kubernetes basics, GitOps workflow)
- Production cutover planning

---

## 14. Appendix: References to KubeCompass Framework

This Layer 0 document is based on the KubeCompass methodology:

- **[FRAMEWORK.md](FRAMEWORK.md)**: Decision layers explanation (Layer 0, 1, 2)
- **[METHODOLOGY.md](METHODOLOGY.md)**: Objectivity and scoring rubric
- **[SCENARIOS.md](SCENARIOS.md)**: Enterprise multi-tenant scenario (comparable to this case)
- **[PRODUCTION_READY.md](PRODUCTION_READY.md)**: Compliance and maturity progression

**Key difference with Enterprise Scenario**:
- Enterprise scenario: 200-500 employees, compliance (ISO 27001, SOC 2), 10-20 teams
- This case: Smaller team, no strict compliance, but business-critical

**Relevant KubeCompass Principles**:
- ✅ **Layer 0 first**: Establish fundamentals before choosing tools
- ✅ **Vendor neutrality**: Open-source preference, no lock-in
- ✅ **Pragmatism**: Not all enterprise features are needed (KISS)
- ✅ **Business impact**: Decisions based on business value, not tech hype

---

**Document Status**: ✅ Ready for review with engineers, architects, and management  
**Next Step**: Layer 1 tool selection and architecture design  
**Owner**: Platform Team / Lead Architect  
**Review Cycle**: After every 3 months (Layer 0 evolves with business needs)

---

## 15. Auto-Copilot Instructions & Validation

### For Engineers Using This Document

This Layer 0 document is specifically designed to serve as input for AI auto-copilots (ChatGPT, Claude, Gemini) when elaborating Layer 1 and beyond.

#### How to Use with Auto-Copilot

**Step 1: Layer 0 Validation**
Give the copilot this complete document and ask:
```
I have done a Layer 0 analysis for a Kubernetes migration.
Analyze this document and identify:
1. Which assumptions are not validated and pose risks
2. Which hard constraints can conflict
3. Which questions from section 12 are critical for Layer 1
4. Which risks from "Explicit Risks" section have insufficient mitigation
```

**Step 2: Layer 1 Tool Selection**
After validating Layer 0:
```
Based on this Layer 0 analysis, help me with Layer 1 tool selection.
Give "Use X unless Y" recommendations for:
1. CNI plugin (Cilium vs Calico vs Flannel)
2. GitOps tool (Argo CD vs Flux)
3. Observability stack (Prometheus/Grafana vs alternatives)
4. Backup solution (Velero vs alternatives)
5. Secrets management (External Secrets Operator vs Sealed Secrets vs Vault)

Use KubeCompass decision matrix principles (see MATRIX.md).
Respect the hard constraints: vendor independence, budget, team maturity.
```

**Step 3: Iterative Refinement**
For each tool category:
```
For [CNI plugin] choice:
- What are the trade-offs between Cilium and Calico?
- How do I measure these trade-offs against Layer 0 requirements?
  - Performance (webshop must be fast)
  - Network policies support (security requirement)
  - Multi-region capability (future requirement)
  - Operational complexity (team has no Kubernetes experience)
- What is the migration cost if we want to switch later?
```

### Validation Checklist for Layer 0 Completeness

This document is **complete** if:
- [x] **Explicit Goals** are documented (what we want to achieve)
- [x] **Explicit Non-Goals** are documented (what we are NOT doing)
- [x] **Hard Constraints** are clear (non-negotiable)
- [x] **Risks with mitigations** are identified (high/medium/low)
- [x] **Business context** is clear (who, what, why)
- [x] **Ownership model** is defined (Dev/Ops/Support roles)
- [x] **Assumptions are explicit** and marked for validation in Layer 1
- [x] **Follow-up questions for Layer 1** are structured and specific
- [x] **No tool names** in requirements (unless as example of what NOT to do)
- [x] **No vendor-specific** solutions as requirement

This document is **NOT complete** if:
- [ ] Tool choices are made without considering alternatives
- [ ] There are conflicting requirements without resolution
- [ ] Team capabilities are not realistically assessed
- [ ] Budget and time constraints are not documented
- [ ] Rollback scenarios are not defined

### Principles That Were Followed (Layer 0 Discipline)

✅ **No premature tool choices**: Document mentions Cilium/Calico/Flannel as *examples*, not as decisions  
✅ **Vendor neutrality**: Open-source preference is *principle*, not "we use tool X"  
✅ **Business driven**: Every requirement is linked to business impact (revenue loss, customer trust)  
✅ **Pragmatism**: Non-goals section prevents over-engineering (no microservices day 1, no multi-region day 1)  
✅ **Explicit about ignorance**: Section 10 "Assumptions" acknowledges what we DON'T know  
✅ **Iterative refinement**: Section 12 "Follow-up Questions" makes clear what Layer 1 must answer  

### Anti-Patterns That Were Avoided

❌ **Avoided: "We will use Cilium"** → Instead: "CNI must support Network Policies"  
❌ **Avoided: "We'll take Prometheus"** → Instead: "Observability must be proactive, not reactive"  
❌ **Avoided: "Multi-region from day 1"** → Instead: "Single region, but architecture doesn't block multi-region"  
❌ **Avoided: "100% uptime guarantee"** → Instead: "Realistic: minimize downtime, accept that incidents happen"  
❌ **Avoided: "Team will learn Kubernetes"** → Instead: "Team has no experience, external consultant + training needed"  

---

**Layer 0 Document Version**: 2.0  
**Last Update**: December 2024  
**Author**: KubeCompass Framework + Community Feedback  
**License**: MIT — free to use and adapt for your own situations
