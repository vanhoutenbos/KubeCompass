# Opand Vragand: Webshop Migratiecase

**Target Audience**: Decision Makers, Project Leads, Architects  
**Purpose**: Overzicht or alle onbeantwoorde vragen gesorteerd on kritikaliteit  
**Status**: Living document - update with beantwoording  

---

## Gebruiksinstructies

### Prioriteit Classificatie
- **🔴 KRITISCH**: Blokkeert implementation start - moet beantwoord wordand for Phase 1
- **🟠 BELANGRIJK**: Impact on architectuur/tooling - moet beantwoord in firste month
- **🟢 KAN LATER**: Refinement/optimalisatie - kan iteratief beslist wordand

### Impact Categorieën
- **Architectuur**: Fundamentele platform design beslissingen
- **Operationol**: Team workflow en dailye operations
- **Compliance**: Security, audit, GDPR requirements
- **Budget**: Cost implications
- **Risico**: Potentiële blockers or failure scenarios

---

## KRITISCH (Blokkeert Implementatie Start)

### 🔴 Q1: Which Managed Kubernetes Provider?
**Categorie**: Architectuur + Budget  
**Impact**: Bepaalt beschikbare features, pricing, support kwaliteit  
**Layer 0 Constraint**: 
- EU datacenter (GDPR data residency)
- Vendor indepanddence (Terraform support required)
- Team maturity (support kwaliteit kritisch)

**Criteria for Keuze**:
| Criterium | Requirement | Validation |
|-----------|-------------|-----------|
| **Datacenter Locatie** | EU (bij voorkeur Nederland) | Compliance check |
| **SLA** | > 99.5% uptime | Contract review |
| **Terraform Support** | Native provider beschikbaar (⚠️ or acceptabel zonder) | Technical validation |
| **Load Balancer Support** | Layer 4/7 LB beschikbaar | Feature check |
| **Storage Options** | Block storage + object storage | Feature check |
| **Pricing** | Transparant, voorspelbaar | Budget fit |

**Opties to te Evaluerand**:
- TransIP Managed Kubernetes (NL datacenter, duidelijke pricing) ⚠️ **Geand Terraform for cluster lifecycle**
- OVHcloud Managed Kubernetes (EU, goede pricing) ✅ **Terraform support**
- DigitalOcean Kubernetes (globale aanwezigheid, simpele pricing) ✅ **Terraform support**
- Scaleway Kubernetes (FR datacenter, developer-friendly) ✅ **Terraform support**

**BELANGRIJKE NOTITIE**: TransIP heeft **geand native Terraform provider** for Kubernetes cluster lifecycle management (create/delete cluster, node pools). Hybrid IaC approach noded: manowal cluster provisioning + Terraform for in-cluster resources. Zie [TransIP Infrastructure as Code Guide](../docs/TRANSIP_INFRASTRUCTURE_AS_CODE.md) for details.

**Blokkerende Afhankelijkhedand**:
- Infrastructure provisioning (Terraform code or documented manowal process)
- Cost estimation (budget approval)
- Network design (load balancer type)
- Storage class selection

**Beslissingsmoment**: Week 1 - for architectuur finalisatie

---

### 🔴 Q5: Resource Requirements (CPU/Memory)?
**Categorie**: Architectuur + Budget  
**Impact**: Node sizing, aantal nodes, monthlye takesand  
**Layer 0 Constraint**: Budget realisme, beschikbaarheid (HA requires multiple nodes)

**Te Metand**:
| Metric | Huidige Situatie | K8s Equivalent |
|--------|-----------------|---------------|
| **CPU per instance** | ___ cores | Pod requests/limits |
| **Memory per instance** | ___ GB | Pod requests/limits |
| **Aantal instances** | ___ VMs | Aantal replicas |
| **Peak traffic** | ___ req/sec | Autoscaling trigger |
| **Database connections** | ___ concurrent | Connection pool sizing |

**Meetmethode**:
- [ ] Analyse huidige VM metrics (laatste 3 monthand)
- [ ] Identificeer peak usage (Black Friday, sales)
- [ ] Berekand overhead (K8s system pods, logging, monitoring = ~20-30%)

**Output Needed**:
```yaml
# Voorbeeld sizing
application_pod:
  requests:
    cpu: "500m"
    memory: "1Gi"
  limits:
    cpu: "2000m"
    memory: "2Gi"
  replicas: 3  # HA minimum
```

**Blokkerende Afhankelijkhedand**:
- Cluster sizing (aantal en type nodes)
- Cost estimation
- Autoscaling configuration

**Beslissingsmoment**: Week 1 - for cluster provisioning

---

### 🔴 Q26: Huidige Database (MySQL/PostgreSQL/SQL Server)?
**Categorie**: Architectuur + Operationol  
**Impact**: Migratie strategy, managed DB keuze, HA configuration  
**Layer 0 Constraint**: Data resilience (PITR requirement), team maturity (geand DB HA expertise)

**Te Identificerand**:
| Aspect | Vraag | Impact |
|--------|-------|--------|
| **Database Type** | MySQL, PostgreSQL, SQL Server, andere? | Managed DB opties, migration tools |
| **Version** | Which versie? | Compatibility, upgrade path |
| **Grootte** | Howveel GB data? | Storage sizing, backup duration |
| **Query Load** | Queries/sec, connections? | Instance sizing, read replicas |
| **Schema Complexity** | Aantal tables, foreign keys, triggers? | Migration complexity |

**Migratiepad Opties**:
1. **Lift & Shift**: Database blijft externe VM
   - ✅ Simpelste optie
   - ❌ Geand HA improvement
   
2. **Managed Cloud Database**: Migratie to cloud provider DB
   - ✅ HA + PITR out-of-box
   - ⚠️ Vendor depanddency (geaccepteerd for database)
   
3. **StatefulSet + Operator**: Database in Kubernetes
   - ✅ Vendor indepanddence
   - ❌ Hoge operationele complexiteit

**Layer 0 Decision**: Managed DB (Option 2) tenzij team DB HA expertise heeft

**Blokkerende Afhankelijkhedand**:
- Managed DB provisioning
- Connection string configuration
- Backup strategy
- Schema migration planning

**Beslissingsmoment**: Week 1-2 - for migration planning

---

### 🔴 Q27: Database Size & Load?
**Categorie**: Architectuur + Budget  
**Impact**: Instance sizing, backup window, replication strategy  
**Layer 0 Constraint**: RPO 15 minowtand (transactie data)

**Te Metand**:
| Metric | Current State | K8s Impact |
|--------|--------------|-----------|
| **Data Size** | ___ GB | Storage provisioning, backup duration |
| **Growth Rate** | ___ GB/month | Capacity planning |
| **Queries/sec** | ___ QPS | Instance sizing, read replicas noded? |
| **Peak Load** | ___ concurrent connections | Connection pool sizing |
| **Write Volume** | ___ writes/sec | Replication lag considerations |

**Backup Window Calculation**:
```
Backup Duration = Data Size / Network Benwidth
Voorbeeld: 100GB / 1Gbps = ~15 minowtand
Impact: Bepaalt backup frequency for RPO 15min target
```

**Blokkerende Afhankelijkhedand**:
- Managed DB instance type selection
- Backup frequency configuration
- Read replica necessity

**Beslissingsmoment**: Week 1-2 - parallel to Q26

---

### 🔴 Q31-34: Applicatie Readiness (Stateless, Scaling, Health Checks)?
**Categorie**: Architectuur + Operationol  
**Impact**: Zero-downtime deployments, horizontale scaling, rolling updates  
**Layer 0 Requirement**: Zero-downtime deployments (business kritisch)

**Kritieke Validaties**:

#### Q31: Is de Applicatie Stateless?
- [ ] **Sessies**: Opgeslagand in database/Redis (niet in memory)
- [ ] **File Uploads**: Externe object storage (niet lokale disk)
- [ ] **Caching**: Centralized (Redis/Memcached), niet in-memory
- [ ] **Shared State**: Geand gedeelde filesystem depanddencies

**Impact**: Als NOT stateless → code refactoring noded for horizontale scaling

---

#### Q32: Kan de Applicatie Horizontaal Schaland?
- [ ] **Database Connections**: Connection pooling configured
- [ ] **Locking Mechanisms**: Distributed locks (Redis), niet file-based
- [ ] **Scheduled Jobs**: Externe scheduler (Kubernetes CronJob), niet in-app
- [ ] **Load Testing**: Kan with 3+ replicas without conflicts

**Impact**: Als NOT schaalbaar → architectuur aanpassingand noded

---

#### Q33: Hardcoded Localhost/IP Depanddencies?
- [ ] **Database Connection**: Environment variable (niet hardcoded IP)
- [ ] **Cache URL**: Environment variable
- [ ] **External APIs**: Environment variable
- [ ] **Service Discovery**: Hostname-based (niet IP-based)

**Impact**: Als hardcoded → code changes noded for Kubernetes service discovery

---

#### Q34: Health Check Endpoints Aanwezig?
- [ ] **Liveness Probe**: `/health` anddpoint (is applicatie alive?)
- [ ] **Readiness Probe**: `/ready` anddpoint (kan applicatie traffic ontvangand?)
- [ ] **Startup Probe**: Langzame startup henling

**Impact**: Als NOT aanwezig → critical: moet geïmplementeerd for rolling updates

**Blokkerende Afhankelijkhedand**:
- Kubernetes Deployment manifests
- Rolling update strategy
- Zero-downtime guarantee

**Beslissingsmoment**: Week 2-3 - for applicatie containerization

---

### 🔴 Q43: Huidige Maenelijkse Infrastructuur Kostand?
**Categorie**: Budget  
**Impact**: Budget approval, sizing decisions, managed vs. self-hosted trade-offs  
**Layer 0 Constraint**: Budget realisme

**Te Inventariserand**:
| Cost Category | Current (VM-based) | Estimated (K8s) | Delta |
|--------------|-------------------|----------------|-------|
| **Compute** | ___ EUR/month | ___ EUR/month | ___ |
| **Storage** | ___ EUR/month | ___ EUR/month | ___ |
| **Networking** | ___ EUR/month (benwidth) | ___ EUR/month (LB + benwidth) | ___ |
| **Database** | ___ EUR/month (VM) | ___ EUR/month (managed DB) | ___ |
| **Backups** | ___ EUR/month | ___ EUR/month | ___ |
| **Monitoring** | ___ EUR/month (if any) | ___ EUR/month (self-hosted) | ___ |
| **Total** | ___ EUR/month | ___ EUR/month | ___ |

**Cost Drivers to Consider**:
- Managed Kubernetes control plane fee (~50-150 EUR/month)
- Load balancer costs (per LB, ~20-40 EUR/month)
- Managed database (typically 2-3x VM cost, maar HA included)
- Egress benwidth (can be significant for EU multi-region)

**Blokkerende Afhankelijkhedand**:
- Budget approval (management sign-off)
- Sizing decisions (Q5)
- Managed vs. self-hosted trade-offs

**Beslissingsmoment**: Week 1 - for project approval

---

### 🔴 Q44: Budget Approval & Sign-off?
**Categorie**: Budget + Governance  
**Impact**: Project go/no-go  
**Layer 0 Constraint**: Budget realisme

**Approval Chain**:
- [ ] Cost estimation complete (Q43)
- [ ] Business case presented (downtime cost vs. K8s investment)
- [ ] Management approval
- [ ] Finance sign-off

**Business Case Elements**:
```
Current Cost or Downtime:
- 1-4 uur/release * 4 releases/month = 4-16 uur/month
- Omzet impact: ___ EUR/uur downtime
- Annowal cost: ___ EUR

Kubernetes Investment:
- Infrastructure: ___ EUR/month
- Training/consultants: ___ EUR one-time
- ROI: ___ monthand
```

**Beslissingsmoment**: Week 1 - project start gate

---

## BELANGRIJK (Eerste Maand Beslissand)

### 🟠 Q10: Git Branching Strategy?
**Categorie**: Operationol  
**Impact**: GitOps configuration, approval workflows, deployment frequency  
**Layer 0 Principe**: GitOps from day 1, Essential SAFe methodology

**Opties**:

#### Optie A: Trunk-Based Development
```
main (production)
  ├── feature/ticket-123 (PR → main)
  └── hotfix/critical-bug (PR → main)
```
**Voordeland**: Simpel, snelle releases, continowous deployment  
**Nadeland**: Vereist goede CI/CD, feature flags for onafgemaakte features

---

#### Optie B: GitFlow
```
main (production)
  ├── develop (staging)
  │   ├── feature/ticket-123 (PR → develop)
  │   └── release/v1.2 (PR → main)
  └── hotfix/critical-bug (PR → main + develop)
```
**Voordeland**: Duidelijke andvironments, gestructureerde releases  
**Nadeland**: Complexer, langzamere releases

---

#### Optie C: Environment Branches
```
production (prod andv)
staging (staging andv)
development (dev andv)
  └── feature/ticket-123 (PR → development)
```
**Voordeland**: Environment = branch (visueel duidelijk)  
**Nadeland**: Merge conflicts, moeilijk hotfixes

---

**Layer 0 Context**: Essential SAFe → sprints, PI planning  
**Aanbeveling**: Start with Trunk-Based (Optie A), feature flags for WIP  
**Rationale**: GitOps efficiency, snellere feedback loops

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

**Beslissingsmoment**: Week 3-4 - for firste deployment

---

### 🟠 Q14: Which Business Metrics zijn Kritisch?
**Categorie**: Operationol + Monitoring  
**Impact**: Custom application metrics, business dashboards, alerting  
**Layer 0 Requirement**: Proactieve monitoring (detecteer voordat klantand belland)

**Te Definiërand**:
| Metric Category | Examples | Alert Threshold |
|----------------|----------|----------------|
| **Checkout Funnel** | Checkout started, payment success rate | < 95% success → alert |
| **Order Processing** | Order creation rate, fulfillment time | ___ |
| **Revenue Impact** | Orders/hour, avg order value | ___ |
| **Customer Experience** | Page load time, search latency | > 2s → warning |
| **Inventory** | Stock levels, out-of-stock events | ___ |

**Implementation**:
- Application moet Prometheus metrics exposand (`/metrics` anddpoint)
- Grafana dashboard for business stakeholders
- Alerts to business-specific channels (bijv. sales team Slack)

**Beslissingsmoment**: Week 4-6 - during applicatie instrumentation

---

### 🟠 Q18: Identity Provider Integratie (OIDC)?
**Categorie**: Security + Operationol  
**Impact**: RBAC configuration, SSO, audit logging  
**Layer 0 Requirement**: No kubeconfig files langetermijn (niet schaalbaar)

**Opties**:

#### Optie A: Keycloak (Self-hosted)
**Voordeland**: 
- ✅ Vendor indepanddence
- ✅ Opand-source
- ✅ Flexible identity federation

**Nadeland**:
- ❌ Operationele overhead (HA setup, upgrades, backup)
- ❌ Team heeft geand Keycloak ervaring

---

#### Optie B: Azure AD / Google Workspace
**Voordeland**:
- ✅ Managed (geand operational overhead)
- ✅ Team heeft possible al accounts
- ✅ MFA included

**Nadeland**:
- ❌ Vendor depanddency
- ❌ Cost per user

---

#### Optie C: Kubeconfig Files (Tijdelijk)
**Voordeland**:
- ✅ Simpelste start
- ✅ No extra tooling

**Nadeland**:
- ❌ Geand audit trail
- ❌ Niet schaalbaar
- ❌ Security risk (credentials in files)

---

**Aanbeveling**: Start with Kubeconfig (Optie C) for kleine team, migreer to Azure AD/Google Workspace (Optie B) within 3 monthand  
**Rationale**: Pragmatisme (team maturity) vs. idealisme (Keycloak), maar tijdelijke oplossing

**Beslissingsmoment**: Week 6-8 - niet blokkeerend for start

---

### 🟠 Q20: Vault Unsealing Strategie?
**Categorie**: Security + Operationol  
**Impact**: Disaster recovery, operational burdand, security posture  
**Layer 0 Requirement**: Secrets management vanaf day 1

**Opties**:

#### Optie A: Auto-Unseal via Cloud KMS
**Voordeland**:
- ✅ Vault automatisch beschikbaar after restart
- ✅ No manowal intervention noded
- ✅ DR scenarios simpeler

**Nadeland**:
- ❌ Cloud provider depanddency
- ❌ Slightly lower security (KMS heeft auto-access)

---

#### Optie B: Manowal Unseal (Shamir Shares)
**Voordeland**:
- ✅ Hoogste security (requires multiple keyholders)
- ✅ No cloud depanddency

**Nadeland**:
- ❌ Manowal process with restart (operational burdand)
- ❌ Keyholder availability required

---

**Aanbeveling**: Auto-Unseal (Optie A) for operational simplicity  
**Rationale**: Team maturity (geand 24/7 on-call), business continowity (faster recovery)  
**Trade-off**: Slight vendor depanddency geaccepteerd for secrets management

**Beslissingsmoment**: Week 4-5 - with Vault setup

---

### 🟠 Q39: Deployment Approval Proces?
**Categorie**: Operationol + Governance  
**Impact**: GitOps workflow, CD pipeline design  
**Layer 0 Principle**: Self-service for Dev, maar ownership duidelijk

**Opties**:

#### Optie A: Auto-Deploy (Dev/Staging), Manowal Approve (Prod)
```
Dev: PR merge → auto-deploy
Staging: PR merge → auto-deploy
Production: PR merge → waiting for approval → manowal sync (Argo CD)
```
**Voordeland**: Fast feedback (dev/staging), safety gate (prod)  
**Nadeland**: Approval bottleneck possible

---

#### Optie B: Fully Automated (met Rollback)
```
All andvs: PR merge → auto-deploy
Rollback: Git revert + auto-deploy
```
**Voordeland**: Maximum speed, true continowous deployment  
**Nadeland**: Requires high confidence in testing

---

#### Optie C: Manowal Everything (Cautious)
```
All andvs: PR merge → manowal approval → manowal sync
```
**Voordeland**: Maximum control  
**Nadeland**: Ops bottleneck, against GitOps philosophy

---

**Aanbeveling**: Optie A (auto dev/staging, manowal prod)  
**Rationale**: Balance tussand speed en safety, team maturity considerations

**Beslissingsmoment**: Week 3-4 - with GitOps configuration

---

## KAN LATER (Iteratief Beslissand)

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

### 🟢 Q42: Externe Consultant Nodig?
**Categorie**: Team + Budget  
**Impact**: Learning curve, time to production  
**Opties**:
- 3-6 monthand full-time consultant (duur, snelle setup)
- Ad-hoc advisory (goedkoper, langzamere leerloop)
- No consultant (langste leerloop, meeste risico)

**Aanbeveling**: 1-2 monthand advisory for initial setup + knowledge transfer  
**Beslissingsmoment**: Week 1 - parallel to budgettering

---

## Aanname Validatie (Zonder Vraag, Moet Gevalideerd)

### ⚠️ Aanname: Applicatie is Containerizable
**Validatie Nodig**:
- [ ] Geand OS-specific depanddencies (Windows-only libraries)
- [ ] Geand licensed software tied to hardware (MAC addresses)
- [ ] Docker image bouwbaar

**Impact as Fout**: Fundamentele blocker for Kubernetes

---

### ⚠️ Aanname: Team Heeft Basickennis Git
**Validatie Nodig**:
- [ ] Developers werkand daily with Git
- [ ] Team begrijpt branching/merging
- [ ] CI/CD basics bekend

**Impact as Fout**: GitOps niet haalbaar without training

---

### ⚠️ Aanname: External Depanddencies Zijn Bereikbaar
**Validatie Nodig**:
- [ ] Payment API's hebband whitelisting (static IP noded?)
- [ ] SMTP for email accessible
- [ ] Third-party APIs hebband rate limits

**Impact as Fout**: Network policy blokkades, operational issues

---

### ⚠️ Aanname: Database Migratie Heeft Downtime Budget
**Validatie Nodig**:
- [ ] Business accepteert X uur downtime for cutover
- [ ] Rollback scenario within X uur possible

**Impact as Fout**: Zero-downtime migration veel complexer

---

## Decision Timeline

```
Week 1: KRITISCH vragen beantwoorden
  ├── Q1 (K8s provider)
  ├── Q5 (resource requirements)
  ├── Q43-44 (budget approval)
  └── Q26-27 (database identification)

Week 2-3: Applicatie validatie
  ├── Q31-34 (stateless, scaling, health checks)
  └── Database migration planning

Week 4-6: BELANGRIJK vragen
  ├── Q10 (Git branching)
  ├── Q14 (business metrics)
  ├── Q18 (identity provider)
  ├── Q20 (Vault unsealing)
  └── Q39 (deployment approval)

Week 6+: KAN LATER vragen (iteratief)
  └── Q7, Q8, Q12, Q15, Q42, etc.
```

---

## Voor Interactieve Site: Question Categorization

```json
{
  "questions": [
    {
      "id": "Q1",
      "text": "Which managed Kubernetes provider?",
      "category": "infrastructure",
      "priority": "critical",
      "blocking": true,
      "layer_0_constraint": ["vanddor_indepanddence", "data_sovereignty", "team_maturity"],
      "decision_week": 1
    },
    {
      "id": "Q5",
      "text": "What zijn huidige resource requirements?",
      "category": "sizing",
      "priority": "critical",
      "blocking": true,
      "layer_0_constraint": ["budget", "high_availability"],
      "decision_week": 1
    }
    // ... meer vragen
  ]
}
```

---

**Document Owner**: Project Lead / Architect  
**Update Frequentie**: Bij beantwoording vragen → mark as RESOLVED  
**Status Tracking**: Living document - vragen wordand afgevoerd with beslissing  

**Version**: 1.0  
**Date**: December 2024  
**License**: MIT
