# Open Vragen: Webshop Migratiecase

**Doelgroep**: Decision Makers, Project Leads, Architects  
**Doel**: Overzicht van alle onbeantwoorde vragen gesorteerd op kritikaliteit  
**Status**: Living document - update bij beantwoording  

---

## Gebruiksinstructies

### Prioriteit Classificatie
- **🔴 KRITISCH**: Blokkeert implementatie start - moet beantwoord worden voor Phase 1
- **🟠 BELANGRIJK**: Impact op architectuur/tooling - moet beantwoord in eerste maand
- **🟢 KAN LATER**: Refinement/optimalisatie - kan iteratief beslist worden

### Impact Categorieën
- **Architectuur**: Fundamentele platform design beslissingen
- **Operationeel**: Team workflow en dagelijkse operations
- **Compliance**: Security, audit, GDPR requirements
- **Budget**: Cost implications
- **Risico**: Potentiële blockers of failure scenarios

---

## KRITISCH (Blokkeert Implementatie Start)

### 🔴 Q1: Welke Managed Kubernetes Provider?
**Categorie**: Architectuur + Budget  
**Impact**: Bepaalt beschikbare features, pricing, support kwaliteit  
**Layer 0 Constraint**: 
- EU datacenter (GDPR data residency)
- Vendor independence (Terraform support required)
- Team maturity (support kwaliteit kritisch)

**Criteria voor Keuze**:
| Criterium | Requirement | Validation |
|-----------|-------------|-----------|
| **Datacenter Locatie** | EU (bij voorkeur Nederland) | Compliance check |
| **SLA** | > 99.5% uptime | Contract review |
| **Terraform Support** | Native provider beschikbaar | Technical validation |
| **Load Balancer Support** | Layer 4/7 LB beschikbaar | Feature check |
| **Storage Options** | Block storage + object storage | Feature check |
| **Pricing** | Transparant, voorspelbaar | Budget fit |

**Opties om te Evalueren**:
- TransIP Managed Kubernetes (NL datacenter, duidelijke pricing)
- OVHcloud Managed Kubernetes (EU, goede pricing)
- DigitalOcean Kubernetes (globale aanwezigheid, simpele pricing)
- Scaleway Kubernetes (FR datacenter, developer-friendly)

**Blokkerende Afhankelijkheden**:
- Infrastructure provisioning (Terraform code)
- Cost estimation (budget approval)
- Network design (load balancer type)
- Storage class selection

**Beslissingsmoment**: Week 1 - voor architectuur finalisatie

---

### 🔴 Q5: Resource Requirements (CPU/Memory)?
**Categorie**: Architectuur + Budget  
**Impact**: Node sizing, aantal nodes, maandelijkse kosten  
**Layer 0 Constraint**: Budget realisme, beschikbaarheid (HA requires multiple nodes)

**Te Meten**:
| Metric | Huidige Situatie | K8s Equivalent |
|--------|-----------------|---------------|
| **CPU per instance** | ___ cores | Pod requests/limits |
| **Memory per instance** | ___ GB | Pod requests/limits |
| **Aantal instances** | ___ VMs | Aantal replicas |
| **Peak traffic** | ___ req/sec | Autoscaling trigger |
| **Database connections** | ___ concurrent | Connection pool sizing |

**Meetmethode**:
- [ ] Analyse huidige VM metrics (laatste 3 maanden)
- [ ] Identificeer peak usage (Black Friday, sales)
- [ ] Bereken overhead (K8s system pods, logging, monitoring = ~20-30%)

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

**Blokkerende Afhankelijkheden**:
- Cluster sizing (aantal en type nodes)
- Cost estimation
- Autoscaling configuration

**Beslissingsmoment**: Week 1 - voor cluster provisioning

---

### 🔴 Q26: Huidige Database (MySQL/PostgreSQL/SQL Server)?
**Categorie**: Architectuur + Operationeel  
**Impact**: Migratie strategie, managed DB keuze, HA configuratie  
**Layer 0 Constraint**: Data resilience (PITR requirement), team maturity (geen DB HA expertise)

**Te Identificeren**:
| Aspect | Vraag | Impact |
|--------|-------|--------|
| **Database Type** | MySQL, PostgreSQL, SQL Server, andere? | Managed DB opties, migration tools |
| **Versie** | Welke versie? | Compatibility, upgrade path |
| **Grootte** | Hoeveel GB data? | Storage sizing, backup duration |
| **Query Load** | Queries/sec, connections? | Instance sizing, read replicas |
| **Schema Complexity** | Aantal tables, foreign keys, triggers? | Migration complexity |

**Migratiepad Opties**:
1. **Lift & Shift**: Database blijft externe VM
   - ✅ Simpelste optie
   - ❌ Geen HA improvement
   
2. **Managed Cloud Database**: Migratie naar cloud provider DB
   - ✅ HA + PITR out-of-box
   - ⚠️ Vendor dependency (geaccepteerd voor database)
   
3. **StatefulSet + Operator**: Database in Kubernetes
   - ✅ Vendor independence
   - ❌ Hoge operationele complexiteit

**Layer 0 Decision**: Managed DB (Option 2) tenzij team DB HA expertise heeft

**Blokkerende Afhankelijkheden**:
- Managed DB provisioning
- Connection string configuration
- Backup strategie
- Schema migration planning

**Beslissingsmoment**: Week 1-2 - voor migratie planning

---

### 🔴 Q27: Database Size & Load?
**Categorie**: Architectuur + Budget  
**Impact**: Instance sizing, backup window, replication strategy  
**Layer 0 Constraint**: RPO 15 minuten (transactie data)

**Te Meten**:
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
Voorbeeld: 100GB / 1Gbps = ~15 minuten
Impact: Bepaalt backup frequency voor RPO 15min target
```

**Blokkerende Afhankelijkheden**:
- Managed DB instance type selection
- Backup frequency configuration
- Read replica necessity

**Beslissingsmoment**: Week 1-2 - parallel aan Q26

---

### 🔴 Q31-34: Applicatie Readiness (Stateless, Scaling, Health Checks)?
**Categorie**: Architectuur + Operationeel  
**Impact**: Zero-downtime deployments, horizontale scaling, rolling updates  
**Layer 0 Requirement**: Zero-downtime deployments (business kritisch)

**Kritieke Validaties**:

#### Q31: Is de Applicatie Stateless?
- [ ] **Sessies**: Opgeslagen in database/Redis (niet in memory)
- [ ] **File Uploads**: Externe object storage (niet lokale disk)
- [ ] **Caching**: Centralized (Redis/Memcached), niet in-memory
- [ ] **Shared State**: Geen gedeelde filesystem dependencies

**Impact**: Als NIET stateless → code refactoring nodig voor horizontale scaling

---

#### Q32: Kan de Applicatie Horizontaal Schalen?
- [ ] **Database Connections**: Connection pooling configured
- [ ] **Locking Mechanisms**: Distributed locks (Redis), niet file-based
- [ ] **Scheduled Jobs**: Externe scheduler (Kubernetes CronJob), niet in-app
- [ ] **Load Testing**: Kan met 3+ replicas zonder conflicts

**Impact**: Als NIET schaalbaar → architectuur aanpassingen nodig

---

#### Q33: Hardcoded Localhost/IP Dependencies?
- [ ] **Database Connection**: Environment variable (niet hardcoded IP)
- [ ] **Cache URL**: Environment variable
- [ ] **External APIs**: Environment variable
- [ ] **Service Discovery**: Hostname-based (niet IP-based)

**Impact**: Als hardcoded → code changes nodig voor Kubernetes service discovery

---

#### Q34: Health Check Endpoints Aanwezig?
- [ ] **Liveness Probe**: `/health` endpoint (is applicatie alive?)
- [ ] **Readiness Probe**: `/ready` endpoint (kan applicatie traffic ontvangen?)
- [ ] **Startup Probe**: Langzame startup handling

**Impact**: Als NIET aanwezig → critical: moet geïmplementeerd voor rolling updates

**Blokkerende Afhankelijkheden**:
- Kubernetes Deployment manifests
- Rolling update strategie
- Zero-downtime guarantee

**Beslissingsmoment**: Week 2-3 - voor applicatie containerization

---

### 🔴 Q43: Huidige Maandelijkse Infrastructuur Kosten?
**Categorie**: Budget  
**Impact**: Budget approval, sizing decisions, managed vs. self-hosted trade-offs  
**Layer 0 Constraint**: Budget realisme

**Te Inventariseren**:
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
- Managed database (typically 2-3x VM cost, maar HA included)
- Egress bandwidth (can be significant for EU multi-region)

**Blokkerende Afhankelijkheden**:
- Budget approval (management sign-off)
- Sizing decisions (Q5)
- Managed vs. self-hosted trade-offs

**Beslissingsmoment**: Week 1 - voor project approval

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
Current Cost of Downtime:
- 1-4 uur/release * 4 releases/maand = 4-16 uur/maand
- Omzet impact: ___ EUR/uur downtime
- Annual cost: ___ EUR

Kubernetes Investment:
- Infrastructure: ___ EUR/maand
- Training/consultants: ___ EUR one-time
- ROI: ___ maanden
```

**Beslissingsmoment**: Week 1 - project start gate

---

## BELANGRIJK (Eerste Maand Beslissen)

### 🟠 Q10: Git Branching Strategy?
**Categorie**: Operationeel  
**Impact**: GitOps configuratie, approval workflows, deployment frequency  
**Layer 0 Principe**: GitOps vanaf dag 1, Essential SAFe werkwijze

**Opties**:

#### Optie A: Trunk-Based Development
```
main (production)
  ├── feature/ticket-123 (PR → main)
  └── hotfix/critical-bug (PR → main)
```
**Voordelen**: Simpel, snelle releases, continuous deployment  
**Nadelen**: Vereist goede CI/CD, feature flags voor onafgemaakte features

---

#### Optie B: GitFlow
```
main (production)
  ├── develop (staging)
  │   ├── feature/ticket-123 (PR → develop)
  │   └── release/v1.2 (PR → main)
  └── hotfix/critical-bug (PR → main + develop)
```
**Voordelen**: Duidelijke environments, gestructureerde releases  
**Nadelen**: Complexer, langzamere releases

---

#### Optie C: Environment Branches
```
production (prod env)
staging (staging env)
development (dev env)
  └── feature/ticket-123 (PR → development)
```
**Voordelen**: Environment = branch (visueel duidelijk)  
**Nadelen**: Merge conflicts, moeilijk hotfixes

---

**Layer 0 Context**: Essential SAFe → sprints, PI planning  
**Aanbeveling**: Start met Trunk-Based (Optie A), feature flags voor WIP  
**Rationale**: GitOps efficiency, snellere feedback loops

**Impact op Argo CD**:
```yaml
# Trunk-based
applications:
  - name: webshop-prod
    source:
      repoURL: https://github.com/org/webshop
      targetRevision: main  # auto-sync
      path: k8s/overlays/production
```

**Beslissingsmoment**: Week 3-4 - voor eerste deployment

---

### 🟠 Q14: Welke Business Metrics zijn Kritisch?
**Categorie**: Operationeel + Monitoring  
**Impact**: Custom application metrics, business dashboards, alerting  
**Layer 0 Requirement**: Proactieve monitoring (detecteer voordat klanten bellen)

**Te Definiëren**:
| Metric Category | Examples | Alert Threshold |
|----------------|----------|----------------|
| **Checkout Funnel** | Checkout started, payment success rate | < 95% success → alert |
| **Order Processing** | Order creation rate, fulfillment time | ___ |
| **Revenue Impact** | Orders/hour, avg order value | ___ |
| **Customer Experience** | Page load time, search latency | > 2s → warning |
| **Inventory** | Stock levels, out-of-stock events | ___ |

**Implementation**:
- Application moet Prometheus metrics exposen (`/metrics` endpoint)
- Grafana dashboard voor business stakeholders
- Alerts naar business-specific channels (bijv. sales team Slack)

**Beslissingsmoment**: Week 4-6 - tijdens applicatie instrumentation

---

### 🟠 Q18: Identity Provider Integratie (OIDC)?
**Categorie**: Security + Operationeel  
**Impact**: RBAC configuratie, SSO, audit logging  
**Layer 0 Requirement**: No kubeconfig files langetermijn (niet schaalbaar)

**Opties**:

#### Optie A: Keycloak (Self-hosted)
**Voordelen**: 
- ✅ Vendor independence
- ✅ Open-source
- ✅ Flexible identity federation

**Nadelen**:
- ❌ Operationele overhead (HA setup, upgrades, backup)
- ❌ Team heeft geen Keycloak ervaring

---

#### Optie B: Azure AD / Google Workspace
**Voordelen**:
- ✅ Managed (geen operational overhead)
- ✅ Team heeft mogelijk al accounts
- ✅ MFA included

**Nadelen**:
- ❌ Vendor dependency
- ❌ Cost per user

---

#### Optie C: Kubeconfig Files (Tijdelijk)
**Voordelen**:
- ✅ Simpelste start
- ✅ No extra tooling

**Nadelen**:
- ❌ Geen audit trail
- ❌ Niet schaalbaar
- ❌ Security risk (credentials in files)

---

**Aanbeveling**: Start met Kubeconfig (Optie C) voor kleine team, migreer naar Azure AD/Google Workspace (Optie B) binnen 3 maanden  
**Rationale**: Pragmatisme (team maturity) vs. idealisme (Keycloak), maar tijdelijke oplossing

**Beslissingsmoment**: Week 6-8 - niet blokkeerend voor start

---

### 🟠 Q20: Vault Unsealing Strategie?
**Categorie**: Security + Operationeel  
**Impact**: Disaster recovery, operational burden, security posture  
**Layer 0 Requirement**: Secrets management vanaf dag 1

**Opties**:

#### Optie A: Auto-Unseal via Cloud KMS
**Voordelen**:
- ✅ Vault automatisch beschikbaar na restart
- ✅ No manual intervention needed
- ✅ DR scenarios simpeler

**Nadelen**:
- ❌ Cloud provider dependency
- ❌ Slightly lower security (KMS heeft auto-access)

---

#### Optie B: Manual Unseal (Shamir Shares)
**Voordelen**:
- ✅ Hoogste security (requires multiple keyholders)
- ✅ No cloud dependency

**Nadelen**:
- ❌ Manual process bij restart (operational burden)
- ❌ Keyholder availability required

---

**Aanbeveling**: Auto-Unseal (Optie A) voor operational simplicity  
**Rationale**: Team maturity (geen 24/7 on-call), business continuity (faster recovery)  
**Trade-off**: Slight vendor dependency geaccepteerd voor secrets management

**Beslissingsmoment**: Week 4-5 - bij Vault setup

---

### 🟠 Q39: Deployment Approval Proces?
**Categorie**: Operationeel + Governance  
**Impact**: GitOps workflow, CD pipeline design  
**Layer 0 Principle**: Self-service voor Dev, maar ownership duidelijk

**Opties**:

#### Optie A: Auto-Deploy (Dev/Staging), Manual Approve (Prod)
```
Dev: PR merge → auto-deploy
Staging: PR merge → auto-deploy
Production: PR merge → waiting for approval → manual sync (Argo CD)
```
**Voordelen**: Fast feedback (dev/staging), safety gate (prod)  
**Nadelen**: Approval bottleneck mogelijk

---

#### Optie B: Fully Automated (met Rollback)
```
All envs: PR merge → auto-deploy
Rollback: Git revert + auto-deploy
```
**Voordelen**: Maximum speed, true continuous deployment  
**Nadelen**: Requires high confidence in testing

---

#### Optie C: Manual Everything (Cautious)
```
All envs: PR merge → manual approval → manual sync
```
**Voordelen**: Maximum control  
**Nadelen**: Ops bottleneck, tegen GitOps philosophy

---

**Aanbeveling**: Optie A (auto dev/staging, manual prod)  
**Rationale**: Balance tussen speed en safety, team maturity considerations

**Beslissingsmoment**: Week 3-4 - bij GitOps configuratie

---

## KAN LATER (Iteratief Beslissen)

### 🟢 Q7: Hubble UI Exposeren?
**Categorie**: Operationeel + Developer Experience  
**Impact**: Network troubleshooting self-service  
**Default**: Port-forward only (ops team)  
**Later**: Ingress + RBAC (developer self-service)

**Beslissingsmoment**: Na 2-3 maanden, als network debugging behoefte ontstaat

---

### 🟢 Q8: SSL Certificaat Management?
**Categorie**: Operationeel  
**Opties**: cert-manager (auto), wildcard cert (manual), cloud-managed  
**Default**: Start met cert-manager + Let's Encrypt (gratis, automated)  
**Later**: Wildcard cert als DNS challenge niet mogelijk

**Beslissingsmoment**: Week 5-6 - bij ingress configuratie

---

### 🟢 Q12: Self-hosted CI Runners?
**Categorie**: Operationeel + Budget  
**Default**: GitHub-hosted runners (simpel)  
**Later**: Self-hosted als resource limits probleem worden  
**Impact**: Build times, concurrent job limits

**Beslissingsmoment**: Na 1-2 maanden, als CI bottleneck wordt

---

### 🟢 Q15: Alert Fatigue Preventie?
**Categorie**: Operationeel  
**Strategie**: Start met minimale alerts, iteratief toevoegen  
**Review**: Sprint retrospectives (enable/disable alerts)  
**Anti-pattern**: Alles alerten dag 1

**Beslissingsmoment**: Ongoing - iteratieve refinement

---

### 🟢 Q42: Externe Consultant Nodig?
**Categorie**: Team + Budget  
**Impact**: Learning curve, time to production  
**Opties**:
- 3-6 maanden full-time consultant (duur, snelle setup)
- Ad-hoc advisory (goedkoper, langzamere leerloop)
- No consultant (langste leerloop, meeste risico)

**Aanbeveling**: 1-2 maanden advisory voor initial setup + knowledge transfer  
**Beslissingsmoment**: Week 1 - parallel aan budgettering

---

## Aanname Validatie (Zonder Vraag, Moet Gevalideerd)

### ⚠️ Aanname: Applicatie is Containerizable
**Validatie Nodig**:
- [ ] Geen OS-specific dependencies (Windows-only libraries)
- [ ] Geen licensed software tied to hardware (MAC addresses)
- [ ] Docker image bouwbaar

**Impact als Fout**: Fundamentele blocker voor Kubernetes

---

### ⚠️ Aanname: Team Heeft Basiskennis Git
**Validatie Nodig**:
- [ ] Developers werken dagelijks met Git
- [ ] Team begrijpt branching/merging
- [ ] CI/CD basics bekend

**Impact als Fout**: GitOps niet haalbaar zonder training

---

### ⚠️ Aanname: External Dependencies Zijn Bereikbaar
**Validatie Nodig**:
- [ ] Payment API's hebben whitelisting (static IP needed?)
- [ ] SMTP voor email accessible
- [ ] Third-party APIs hebben rate limits

**Impact als Fout**: Network policy blokkades, operational issues

---

### ⚠️ Aanname: Database Migratie Heeft Downtime Budget
**Validatie Nodig**:
- [ ] Business accepteert X uur downtime voor cutover
- [ ] Rollback scenario binnen X uur mogelijk

**Impact als Fout**: Zero-downtime migratie veel complexer

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
      "text": "Welke managed Kubernetes provider?",
      "category": "infrastructure",
      "priority": "critical",
      "blocking": true,
      "layer_0_constraint": ["vendor_independence", "data_sovereignty", "team_maturity"],
      "decision_week": 1
    },
    {
      "id": "Q5",
      "text": "Wat zijn huidige resource requirements?",
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

**Document Eigenaar**: Project Lead / Architect  
**Update Frequentie**: Bij beantwoording vragen → mark als RESOLVED  
**Status Tracking**: Living document - vragen worden afgevoerd bij beslissing  

**Versie**: 1.0  
**Datum**: December 2024  
**Licentie**: MIT
