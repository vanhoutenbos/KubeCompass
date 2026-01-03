# Open Questions: Webshop Migration Case

**Target Audience**: Decision Makers, Project Leads, Architects  
**Purpose**: Overview of all unanswered questions sorted by criticality  
**Status**: Living document - update with answers  

---

## Usage Instructions

### Priority Classification
- **🔴 CRITICAL**: Blocks implementation start - must be answered before Phase 1
- **🟠 IMPORTANT**: Impact on architecture/tooling - must be answered in first month
- **🟢 CAN BE LATER**: Refinement/optimization - can be decided iteratively

### Impact Categories
- **Architecture**: Fundamental platform design decisions
- **Operational**: Team workflow and daily operations
- **Compliance**: Security, audit, GDPR requirements
- **Budget**: Cost implications
- **Risk**: Potential blockers or failure scenarios

---

## CRITICAL (Blocks Implementation Start)

### 🔴 Q1: Which Managed Kubernetes Provider?
**Category**: Architecture + Budget  
**Impact**: Determines available features, pricing, support quality  
**Priority 0 Constraint**: 
- EU datacenter (GDPR data residency)
- Vendor independence (Terraform support required)
- Team maturity (support quality critical)

**Selection Criteria**:
| Criterion | Requirement | Validation |
|-----------|-------------|-----------|
| **Datacenter Location** | EU (preferably Netherlands) | Compliance check |
| **SLA** | > 99.5% uptime | Contract review |
| **Terraform Support** | Native provider available (⚠️ or acceptable without) | Technical validation |
| **Load Balancer Support** | Layer 4/7 LB available | Feature check |
| **Storage Options** | Block storage + object storage | Feature check |
| **Pricing** | Transparent, predictable | Budget fit |

**Options to Evaluate**:
- TransIP Managed Kubernetes (NL datacenter, clear pricing) ⚠️ **No Terraform for cluster lifecycle**
- OVHcloud Managed Kubernetes (EU, good pricing) ✅ **Terraform support**
- DigitalOcean Kubernetes (global presence, simple pricing) ✅ **Terraform support**
- Scaleway Kubernetes (FR datacenter, developer-friendly) ✅ **Terraform support**

**IMPORTANT NOTE**: TransIP has **no native Terraform provider** for Kubernetes cluster lifecycle management (create/delete cluster, node pools). Hybrid IaC approach needed: manual cluster provisioning + Terraform for in-cluster resources. See [TransIP Infrastructure as Code Guide](../docs/TRANSIP_INFRASTRUCTURE_AS_CODE.md) for details.

**Blocking Dependencies**:
- Infrastructure provisioning (Terraform code or documented manual process)
- Cost estimation (budget approval)
- Network design (load balancer type)
- Storage class selection

**Decision Point**: Week 1 - for architecture finalization

---

### 🔴 Q5: Resource Requirements (CPU/Memory)?
**Category**: Architecture + Budget  
**Impact**: Node sizing, number of nodes, monthly costs  
**Priority 0 Constraint**: Budget realism, availability (HA requires multiple nodes)

**To Measure**:
| Metric | Current Situation | K8s Equivalent |
|--------|-----------------|---------------|
| **CPU per instance** | ___ cores | Pod requests/limits |
| **Memory per instance** | ___ GB | Pod requests/limits |
| **Number of instances** | ___ VMs | Number of replicas |
| **Peak traffic** | ___ req/sec | Autoscaling trigger |
| **Database connections** | ___ concurrent | Connection pool sizing |

**Measurement Method**:
- [ ] Analyze current VM metrics (last 3 months)
- [ ] Identify peak usage (Black Friday, sales)
- [ ] Calculate overhead (K8s system pods, logging, monitoring = ~20-30%)

**Output Needed**:
```yaml
# Example sizing
application_pod:
  requests:
    cpu: "500m"
    memory: "1Gi"
  limits:
    cpu: "2000m"
    memory: "2Gi"
  replicas: 3  # HA minimum
```

**Blocking Dependencies**:
- Cluster sizing (number and type of nodes)
- Cost estimation
- Autoscaling configuration

**Decision Point**: Week 1 - for cluster provisioning

---

### 🔴 Q26: Current Database (MySQL/PostgreSQL/SQL Server)?
**Category**: Architecture + Operational  
**Impact**: Migration strategy, managed DB choice, HA configuration  
**Priority 0 Constraint**: Data resilience (PITR requirement), team maturity (no DB HA expertise)

**To Identify**:
| Aspect | Question | Impact |
|--------|-------|--------|
| **Database Type** | MySQL, PostgreSQL, SQL Server, other? | Managed DB options, migration tools |
| **Version** | Which version? | Compatibility, upgrade path |
| **Size** | How many GB data? | Storage sizing, backup duration |
| **Query Load** | Queries/sec, connections? | Instance sizing, read replicas |
| **Schema Complexity** | Number of tables, foreign keys, triggers? | Migration complexity |

**Migration Path Options**:
1. **Lift & Shift**: Database remains external VM
   - ✅ Simplest option
   - ❌ No HA improvement
   
2. **Managed Cloud Database**: Migration to cloud provider DB
   - ✅ HA + PITR out-of-box
   - ⚠️ Vendor dependency (accepted for database)
   
3. **StatefulSet + Operator**: Database in Kubernetes
   - ✅ Vendor independence
   - ❌ High operational complexity

**Priority 0 Decision**: Managed DB (Option 2) unless team has DB HA expertise

**Blocking Dependencies**:
- Managed DB provisioning
- Connection string configuration
- Backup strategy
- Schema migration planning

**Decision Point**: Week 1-2 - for migration planning

---

### 🔴 Q27: Database Size & Load?
**Category**: Architecture + Budget  
**Impact**: Instance sizing, backup window, replication strategy  
**Priority 0 Constraint**: RPO 15 minutes (transaction data)

**To Measure**:
| Metric | Current State | K8s Impact |
|--------|--------------|-----------|
| **Data Size** | ___ GB | Storage provisioning, backup duration |
| **Growth Rate** | ___ GB/month | Capacity planning |
| **Queries/sec** | ___ QPS | Instance sizing, read replicas needed? |
| **Peak Load** | ___ concurrent connections | Connection pool sizing |
| **Write Volume** | ___ writes/sec | Replication lag considerations |

**Backup Window Calculation**:
```
Backup Duration = Data Size / Network Bandwidth
Example: 100GB / 1Gbps = ~15 minutes
Impact: Determines backup frequency for RPO 15min target
```

**Blocking Dependencies**:
- Managed DB instance type selection
- Backup frequency configuration
- Read replica necessity

**Decision Point**: Week 1-2 - parallel to Q26

---

### 🔴 Q31-34: Application Readiness (Stateless, Scaling, Health Checks)?
**Category**: Architecture + Operational  
**Impact**: Zero-downtime deployments, horizontal scaling, rolling updates  
**Priority 0 Requirement**: Zero-downtime deployments (business critical)

**Critical Validations**:

#### Q31: Is the Application Stateless?
- [ ] **Sessions**: Stored in database/Redis (not in memory)
- [ ] **File Uploads**: External object storage (not local disk)
- [ ] **Caching**: Centralized (Redis/Memcached), not in-memory
- [ ] **Shared State**: No shared filesystem dependencies

**Impact**: If NOT stateless → code refactoring needed for horizontal scaling

---

#### Q32: Can the Application Scale Horizontally?
- [ ] **Database Connections**: Connection pooling configured
- [ ] **Locking Mechanisms**: Distributed locks (Redis), not file-based
- [ ] **Scheduled Jobs**: External scheduler (Kubernetes CronJob), not in-app
- [ ] **Load Testing**: Works with 3+ replicas without conflicts

**Impact**: If NOT scalable → architecture changes needed

---

#### Q33: Hardcoded Localhost/IP Dependencies?
- [ ] **Database Connection**: Environment variable (not hardcoded IP)
- [ ] **Cache URL**: Environment variable
- [ ] **External APIs**: Environment variable
- [ ] **Service Discovery**: Hostname-based (not IP-based)

**Impact**: If hardcoded → code changes needed for Kubernetes service discovery

---

#### Q34: Health Check Endpoints Present?
- [ ] **Liveness Probe**: `/health` endpoint (is application alive?)
- [ ] **Readiness Probe**: `/ready` endpoint (can application receive traffic?)
- [ ] **Startup Probe**: Slow startup handling

**Impact**: If NOT present → critical: must be implemented for rolling updates

**Blocking Dependencies**:
- Kubernetes Deployment manifests
- Rolling update strategy
- Zero-downtime guarantee

**Decision Point**: Week 2-3 - for application containerization

---

### 🔴 Q43: Current Monthly Infrastructure Costs?
**Category**: Budget  
**Impact**: Budget approval, sizing decisions, managed vs. self-hosted trade-offs  
**Priority 0 Constraint**: Budget realism

**To Inventory**:
| Cost Category | Current (VM-based) | Estimated (K8s) | Delta |
|--------------|-------------------|----------------|-------|
| **Compute** | ___ EUR/month | ___ EUR/month | ___ |
| **Storage** | ___ EUR/month | ___ EUR/month | ___ |
| **Networking** | ___ EUR/month (bandwidth) | ___ EUR/month (LB + bandwidth) | ___ |
| **Database** | ___ EUR/month (VM) | ___ EUR/month (managed DB) | ___ |
| **Backups** | ___ EUR/month | ___ EUR/month | ___ |
| **Monitoring** | ___ EUR/month (if any) | ___ EUR/month (self-hosted) | ___ |
| **Total** | ___ EUR/month | ___ EUR/month | ___ |

**Cost Drivers to Consider**:
- Managed Kubernetes control plane fee (~50-150 EUR/month)
- Load balancer costs (per LB, ~20-40 EUR/month)
- Managed database (typically 2-3x VM cost, but HA included)
- Egress bandwidth (can be significant for EU multi-region)

**Blocking Dependencies**:
- Budget approval (management sign-off)
- Sizing decisions (Q5)
- Managed vs. self-hosted trade-offs

**Decision Point**: Week 1 - for project approval

---

### 🔴 Q44: Budget Approval & Sign-off?
**Category**: Budget + Governance  
**Impact**: Project go/no-go  
**Priority 0 Constraint**: Budget realism

**Approval Chain**:
- [ ] Cost estimation complete (Q43)
- [ ] Business case presented (downtime cost vs. K8s investment)
- [ ] Management approval
- [ ] Finance sign-off

**Business Case Elements**:
```
Current Cost of Downtime:
- 1-4 hours/release * 4 releases/month = 4-16 hours/month
- Revenue impact: ___ EUR/hour downtime
- Annual cost: ___ EUR

Kubernetes Investment:
- Infrastructure: ___ EUR/month
- Training/consultants: ___ EUR one-time
- ROI: ___ months
```

**Decision Point**: Week 1 - project start gate

---

## IMPORTANT (First Month Decisions)

### 🟠 Q10: Git Branching Strategy?
**Category**: Operational  
**Impact**: GitOps configuration, approval workflows, deployment frequency  
**Priority 0 Principle**: GitOps from day 1, Essential SAFe methodology

**Options**:

#### Option A: Trunk-Based Development
```
main (production)
  ├── feature/ticket-123 (PR → main)
  └── hotfix/critical-bug (PR → main)
```
**Advantages**: Simple, fast releases, continuous deployment  
**Disadvantages**: Requires good CI/CD, feature flags for unfinished features

---

#### Option B: GitFlow
```
main (production)
  ├── develop (staging)
  │   ├── feature/ticket-123 (PR → develop)
  │   └── release/v1.2 (PR → main)
  └── hotfix/critical-bug (PR → main + develop)
```
**Advantages**: Clear environments, structured releases  
**Disadvantages**: More complex, slower releases

---

#### Option C: Environment Branches
```
production (prod env)
staging (staging env)
development (dev env)
  └── feature/ticket-123 (PR → development)
```
**Advantages**: Environment = branch (visually clear)  
**Disadvantages**: Merge conflicts, difficult hotfixes

---

**Priority 0 Context**: Essential SAFe → sprints, PI planning  
**Recommendation**: Start with Trunk-Based (Option A), feature flags for WIP  
**Rationale**: GitOps efficiency, faster feedback loops

**Impact on Argo CD**:
```yaml
# Trunk-based
applications:
  - name: webshop-prod
    source:
      repoURL: https://github.com/org/webshop
      targetRevision: main  # auto-sync
      path: k8s/overlays/production
```

**Decision Point**: Week 3-4 - for first deployment

---

### 🟠 Q14: Which Business Metrics are Critical?
**Category**: Operational + Monitoring  
**Impact**: Custom application metrics, business dashboards, alerting  
**Priority 0 Requirement**: Proactive monitoring (detect before customers call)

**To Define**:
| Metric Category | Examples | Alert Threshold |
|----------------|----------|----------------|
| **Checkout Funnel** | Checkout started, payment success rate | < 95% success → alert |
| **Order Processing** | Order creation rate, fulfillment time | ___ |
| **Revenue Impact** | Orders/hour, avg order value | ___ |
| **Customer Experience** | Page load time, search latency | > 2s → warning |
| **Inventory** | Stock levels, out-of-stock events | ___ |

**Implementation**:
- Application must expose Prometheus metrics (`/metrics` endpoint)
- Grafana dashboard for business stakeholders
- Alerts to business-specific channels (e.g., sales team Slack)

**Decision Point**: Week 4-6 - during application instrumentation

---

### 🟠 Q18: Identity Provider Integration (OIDC)?
**Category**: Security + Operational  
**Impact**: RBAC configuration, SSO, audit logging  
**Priority 0 Requirement**: No kubeconfig files long-term (not scalable)

**Options**:

#### Option A: Keycloak (Self-hosted)
**Advantages**: 
- ✅ Vendor independence
- ✅ Open-source
- ✅ Flexible identity federation

**Disadvantages**:
- ❌ Operational overhead (HA setup, upgrades, backup)
- ❌ Team has no Keycloak experience

---

#### Option B: Azure AD / Google Workspace
**Advantages**:
- ✅ Managed (no operational overhead)
- ✅ Team possibly already has accounts
- ✅ MFA included

**Disadvantages**:
- ❌ Vendor dependency
- ❌ Cost per user

---

#### Option C: Kubeconfig Files (Temporary)
**Advantages**:
- ✅ Simplest start
- ✅ No extra tooling

**Disadvantages**:
- ❌ No audit trail
- ❌ Not scalable
- ❌ Security risk (credentials in files)

---

**Recommendation**: Start with Kubeconfig (Option C) for small team, migrate to Azure AD/Google Workspace (Option B) within 3 months  
**Rationale**: Pragmatism (team maturity) vs. idealism (Keycloak), but temporary solution

**Decision Point**: Week 6-8 - not blocking for start

---

### 🟠 Q20: Vault Unsealing Strategy?
**Category**: Security + Operational  
**Impact**: Disaster recovery, operational burden, security posture  
**Priority 0 Requirement**: Secrets management from day 1

**Options**:

#### Option A: Auto-Unseal via Cloud KMS
**Advantages**:
- ✅ Vault automatically available after restart
- ✅ No manual intervention needed
- ✅ DR scenarios simpler

**Disadvantages**:
- ❌ Cloud provider dependency
- ❌ Slightly lower security (KMS has auto-access)

---

#### Option B: Manual Unseal (Shamir Shares)
**Advantages**:
- ✅ Highest security (requires multiple keyholders)
- ✅ No cloud dependency

**Disadvantages**:
- ❌ Manual process with restart (operational burden)
- ❌ Keyholder availability required

---

**Recommendation**: Auto-Unseal (Option A) for operational simplicity  
**Rationale**: Team maturity (no 24/7 on-call), business continuity (faster recovery)  
**Trade-off**: Slight vendor dependency accepted for secrets management

**Decision Point**: Week 4-5 - with Vault setup

---

### 🟠 Q39: Deployment Approval Process?
**Category**: Operational + Governance  
**Impact**: GitOps workflow, CD pipeline design  
**Priority 0 Principle**: Self-service for Dev, but ownership clear

**Options**:

#### Option A: Auto-Deploy (Dev/Staging), Manual Approve (Prod)
```
Dev: PR merge → auto-deploy
Staging: PR merge → auto-deploy
Production: PR merge → waiting for approval → manual sync (Argo CD)
```
**Advantages**: Fast feedback (dev/staging), safety gate (prod)  
**Disadvantages**: Approval bottleneck possible

---

#### Option B: Fully Automated (with Rollback)
```
All envs: PR merge → auto-deploy
Rollback: Git revert + auto-deploy
```
**Advantages**: Maximum speed, true continuous deployment  
**Disadvantages**: Requires high confidence in testing

---

#### Option C: Manual Everything (Cautious)
```
All envs: PR merge → manual approval → manual sync
```
**Advantages**: Maximum control  
**Disadvantages**: Ops bottleneck, against GitOps philosophy

---

**Recommendation**: Option A (auto dev/staging, manual prod)  
**Rationale**: Balance between speed and safety, team maturity considerations

**Decision Point**: Week 3-4 - with GitOps configuration

---

## CAN BE LATER (Iterative Decisions)

### 🟢 Q7: Hubble UI Exposerand?
**Categorie**: Operationol + Developer Experience  
**Impact**: Network troubleshooting self-service  
**Default**: Port-forward only (ops team)  
**Later**: Ingress + RBAC (developer self-service)

**Beslissingsmoment**: Na 2-3 monthand, as network debugging behoefte ontstaat

---

### 🟢 Q8: SSL Certificaat Management?
**Categorie**: Operationol  
**Opties**: cert-manager (auto), wildcard cert (manowal), cloud-managed  
**Default**: Start with cert-manager + Let's Encrypt (gratis, automated)  
**Later**: Wildcard cert as DNS challenge niet possible

**Beslissingsmoment**: Week 5-6 - with ingress configuration

---

### 🟢 Q12: Self-hosted CI Runners?
**Categorie**: Operationol + Budget  
**Default**: GitHub-hosted runners (simpel)  
**Later**: Self-hosted as resource limits probleem wordand  
**Impact**: Build times, concurrent job limits

**Beslissingsmoment**: Na 1-2 monthand, as CI bottleneck wordt

---

### 🟢 Q15: Alert Fatigue Preventie?
**Categorie**: Operationol  
**Strategie**: Start with minimale alerts, iteratief addvoegand  
**Review**: Sprint retrospectives (andable/disable alerts)  
**Anti-pattern**: Alles alertand day 1

**Beslissingsmoment**: Ongoing - iteratieve refinement

---

### 🟢 Q42: External Consultant Needed?
**Category**: Team + Budget  
**Impact**: Learning curve, time to production  
**Options**:
- 3-6 months full-time consultant (expensive, fast setup)
- Ad-hoc advisory (cheaper, slower learning)
- No consultant (longest learning, most risk)

**Recommendation**: 1-2 months advisory for initial setup + knowledge transfer  
**Decision Point**: Week 1 - parallel to budgeting

---

## Assumption Validation (No Question, Must Be Validated)

### ⚠️ Assumption: Application is Containerizable
**Validation Needed**:
- [ ] No OS-specific dependencies (Windows-only libraries)
- [ ] No licensed software tied to hardware (MAC addresses)
- [ ] Docker image buildable

**Impact if Wrong**: Fundamental blocker for Kubernetes

---

### ⚠️ Assumption: Team Has Basic Git Knowledge
**Validation Needed**:
- [ ] Developers work daily with Git
- [ ] Team understands branching/merging
- [ ] CI/CD basics known

**Impact if Wrong**: GitOps not feasible without training

---

### ⚠️ Assumption: External Dependencies Are Accessible
**Validation Needed**:
- [ ] Payment APIs have whitelisting (static IP needed?)
- [ ] SMTP for email accessible
- [ ] Third-party APIs have rate limits

**Impact if Wrong**: Network policy blockages, operational issues

---

### ⚠️ Assumption: Database Migration Has Downtime Budget
**Validation Needed**:
- [ ] Business accepts X hours downtime for cutover
- [ ] Rollback scenario within X hours possible

**Impact if Wrong**: Zero-downtime migration much more complex

---

## Decision Timeline

```
Week 1: CRITICAL questions to answer
  ├── Q1 (K8s provider)
  ├── Q5 (resource requirements)
  ├── Q43-44 (budget approval)
  └── Q26-27 (database identification)

Week 2-3: Application validation
  ├── Q31-34 (stateless, scaling, health checks)
  └── Database migration planning

Week 4-6: IMPORTANT questions
  ├── Q10 (Git branching)
  ├── Q14 (business metrics)
  ├── Q18 (identity provider)
  ├── Q20 (Vault unsealing)
  └── Q39 (deployment approval)

Week 6+: CAN BE LATER questions (iterative)
  └── Q7, Q8, Q12, Q15, Q42, etc.
```

---

## For Interactive Site: Question Categorization

```json
{
  "questions": [
    {
      "id": "Q1",
      "text": "Which managed Kubernetes provider?",
      "category": "infrastructure",
      "priority": "critical",
      "blocking": true,
      "layer_0_constraint": ["vendor_independence", "data_sovereignty", "team_maturity"],
      "decision_week": 1
    },
    {
      "id": "Q5",
      "text": "What are current resource requirements?",
      "category": "sizing",
      "priority": "critical",
      "blocking": true,
      "layer_0_constraint": ["budget", "high_availability"],
      "decision_week": 1
    }
    // ... more questions
  ]
}
```

---

**Document Owner**: Project Lead / Architect  
**Update Frequency**: When answering questions → mark as RESOLVED  
**Status Tracking**: Living document - questions removed with decision  

**Version**: 1.0  
**Date**: December 2024  
**License**: MIT
