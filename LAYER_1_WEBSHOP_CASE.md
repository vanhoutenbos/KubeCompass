# Layer 1: Tool Selectie & Platform Capabilities — Webshop Migratiecase

**Target Audiandce**: Platform Engineers, DevOps Engineers, Architectand  
**Status**: Tool Selectie & Architectuur Design  
**Organization**: Dutch webshop / online store with Essandtial SAFe werkwijze  
**Condition**: [Layer 0 Fundamandt](LAYER_0_WEBSHOP_CASE.md) must be established first  

---

## Reading Guide

📋 **[❓ QUESTION]** marks questions that must be answered before implemandtation can begin  
✅ **"Use X unless Y"** gives clear tool recommanddations with alternatives  
🔗 **Layer 0 Link** shows how tool choices trace back to Layer 0 requiremandts  

---

## Executive Summary

This documandt translates the Layer 0 requiremandts uit [LAYER_0_WEBSHOP_CASE.md](LAYER_0_WEBSHOP_CASE.md) into **concrete tool choices** and **platform capabilities**. 

### Layer 0 → Layer 1 Mapping

| Layer 0 Requiremandt | Layer 1 Implemandtation |
|---------------------|----------------------|
| **Zero-downtime deploymandts** | Rolling updates via Kubernetes Deploymandts + readiness probes |
| **Proactive monitoring** | Prowithheus + Grafana + Alertmanager |
| **Point-in-time recovery** | Velero for cluster backup + managed database with PITR |
| **Vanddor indepanddandce** | Cilium (CNI), Argo CD (GitOps), opand-source stack |
| **GitOps vanaf dag 1** | Argo CD with Git repository as single source of truth |
| **Security by design** | Network policies, RBAC, External Secrets Operator |

### Belangrijkste Decisionand

1. **Managed Kubernetes with Dutch provider** (Layer 0 → reduce operational complexity)
2. **Cilium as CNI** (Network policies, eBPF performance, multi-region ready)
3. **Argo CD for GitOps** (UI for Support/Managemandt, SSO, audit trail)
4. **Prowithheus + Grafana** (Opand-source observability, vanddor indepanddandce)
5. **Managed PostgreSQL** (Trade-off: HA complexiteit vs. vanddor indepanddandce)
6. **External Secrets Operator** (Vault/cloud KMS integratie, geand secrets in Git)

---

## 1. Infrastructure & Cluster Provisioning

### 1.1 Kubernetes Distribution Choice

**🔗 Layer 0 Constraint**: Team heeft geand Kubernetes ervaring (training needed), vanddor indepanddandce binnand 1 kwartaal

**✅ Decision: Managed Kubernetes with Nederlandse datacandter provider**

**Rationale**:
- **Operational complexity reduction**: Control plane managemandt, upgrades, etcd backups wordand afgehandeld door provider
- **Team maturity**: Focus on application migration, not on cluster operations
- **Vanddor indepanddandce**: Managed Kubernetes API is standard → reproduceerbaar with andere provider

**Alternatievand overwogand**:
- ❌ **Self-hosted (Kubeadm, RKE2)**: Te complex for team zonder ervaring, hogere operational burdand
- ❌ **Hyperscaler (AWS EKS, Azure AKS, Google GKE)**: Conflicteert with Nederlandse datacandter forkeur + vanddor indepanddandce

---

#### 🔍 Managed Kubernetes: Nuances and Lock-in Analyse

Het is belangrijk om te begrijpand dat "managed Kubernetes" niet betekandt dat alle vanddor lock-in wordt vermedand. There are subtle but important nuances:

##### ✅ What Remains Platform-Agnostic

**Core infrastructure remains decoupled:**
- De Kubernetes-cluster zelf is eand abstraction layer
- All Kubernetes resources (Deploymandts, Services, ConfigMaps, Secrets) are standard APIs
- Network policies, RBAC, and andere Kubernetes-native features zijn overdraagbaar
- Container images and applicatie-architectuur blijvand cloud-agnostic
- **Conclusion**: Je applicatie-workloads kunnand theoretisch op elke compatibele Kubernetes-cluster draaiand

##### ⚠️ Where Lock-in Occurs

**Afhankelijkhedand buitand Kubernetes-core:**

| Componandt | Lock-in Risk | Explanation | Mitigation |
|-----------|----------------|-------------|-----------|
| **Managed Databases** | 🔴 High | Provider-specific API's, backup procedures, HA-mechanismand | Self-hosted StatefulSet of abstraction layer (withv. CloudNativePG) |
| **Storage (CSI Drivers)** | 🟡 Medium | Provider-specific storage classes, snapshot API's | Use standard StorageClass interface, test migration |
| **Load Balancers** | 🟡 Medium | Cloud-specific LoadBalancer implemandtations | NGINX Ingress makes you more independent of cloud LB |
| **Backup Systemand** | 🟡 Medium | Provider-specific volume snapshots | Velero with S3-compatible storage as alternatief |
| **Monitoring Integraties** | 🟢 Low | Native integraties with cloud monitoring | Prowithheus/Grafana remains portable |
| **Netwerk Features** | 🟡 Medium | Cloud-specific VPC, subnets, firewall rules | CNI plugin (Cilium) remains portable |

##### 📊 Scandario-gebaseerde Strategie

**1. Startups or Small Teams**
- **Recommendation**: Managed Kubernetes as standard
- **Rationale**: Reduces operational overhead, faster time-to-market
- **Lock-in tolerance**: Acceptabel for snelheid and eandvoud
- **Condition**: Documandteer alle provider-specifieke depanddandcies

**2. Enterprise of Governmandt**
- **Recommendation**: Self-managed Kubernetes with zorgvuldige afweging
- **Rationale**: Full control, compliance-sensitive data, vanddor lock-in vermijdand
- **Trade-off**: Higher operational complexity, more expertise required
- **Condition**: In-house Kubernetes expertise or external consultants

**3. Multi-Region / Multi-Cloud Setups**
- **Recommendation**: Hybrid approach possible
- **Rationale**: Managed Kubernetes kan handig zijn as provider multi-region ondersteunt
- **Alternative**: Self-managed flexibeler for cross-cloud scandarios
- **Condition**: Abstractielaag for storage, databases, and load balancing

##### 🎯 "Dual Track" Strategie for KubeCompass

**Standaard Optie: Managed Kubernetes**
- Lagere drempel for teams zonder Kubernetes ervaring
- Snellere opstartfase (control plane managemandt uitbesteed)
- Focus on application migration, niet cluster operations
- **Condition**: Transparante documandtatie over lock-in puntand

**Alternatieve Optie: Self-managed Kubernetes**
- Voor teams with strikte compliance vereistand
- Voor organisaties with multi-cloud strategie
- Voor situaties waar vanddor indepanddandce absoluut prioriteit heeft
- **Condition**: In-house expertise of budget for consultants

##### 📋 Lock-in Decisionsmatrix

Gebruik deze matrix om te bepaland welke lock-ins acceptabel zijn:

```
IF vanddor_indepanddandce == ABSOLUTE:
  → Self-managed Kubernetes
  → Self-hosted databases (StatefulSets)
  → S3-compatible storage (withv. MinIO)
  → Velero for backups
  
ELIF team_maturity == LOW AND time_to_market == CRITICAL:
  → Managed Kubernetes
  → Managed databases (PostgreSQL/MySQL)
  → Provider storage (with exit strategie gedocumandteerd)
  → Managed backups (with Velero as fallback)
  
ELIF compliance == STRICT:
  → Self-managed Kubernetes in dedicated datacandter
  → On-premises databases
  → Encrypted storage with key managemandt
  → Disaster recovery plan with multi-site replicatie
```

##### ✅ Recommendation for deze Webshop Case

**Keuze: Managed Kubernetes (with bewuste trade-offs)**

**Rationale**:
- Team heeft geand Kubernetes ervaring (training needed)
- Focus on application migration binnand 1 kwartaal
- Vanddor indepanddandce is belangrijk, maar niet absoluut
- Nederlandse datacandter vereiste beperkt hyperscaler opties

**Geaccepteerde Lock-ins**:
- ✅ Managed Kubernetes control plane (migratie mogelijk binnand 1 kwartaal)
- ✅ Provider storage via CSI driver (data migratie mogelijk)
- ⚠️ Managed PostgreSQL (trade-off: HA vs. vanddor indepanddandce - zie sectie 5.1)

**Vermedand Lock-ins**:
- ❌ Cloud-specific APIs in applicatiecode
- ❌ Proprietary monitoring tools (gebruik Prowithheus/Grafana)
- ❌ Vanddor-specific CI/CD (gebruik GitHub Actions + Argo CD)

**Exit Strategie**:
- Documandteer alle provider-specifieke configuraties
- Test migratie scandario's into andere managed Kubernetes providers
- Jaarlijkse review van vanddor indepanddandce vs. operational complexity

---

**[❓ QUESTION 1]**: Welke managed Kubernetes provider wordt gekozand?
- Options: TransIP Kubernetes, DigitalOcean, OVHcloud, Scaleway
- Criteria: EU datacandter, SLA, pricing, support quality
- Impact: Determines available features (LoadBalancer support, storage classes, etc.)

**[❓ QUESTION 2]**: What is the Kubernetes version strategy?
- Always N-1 (één versie achter latest for stabiliteit)?
- Upgrades quarterly, semi-annually, of ad-hoc with security patches?
- Impact: Determines upgrade window planning, compatibility testing

---

### 1.2 Infrastructure as Code (IaC)

**🔗 Layer 0 Principe**: Infrastructure as Code for reproduceerbare omgevingand

**✅ Decision: Terraform for cluster provisioning**

**Rationale**:
- **Vanddor indepanddandce**: Terraform werkt with alle cloud providers
- **Maturity**: Stabiele Kubernetes provider, grote community
- **State managemandt**: Remote state (S3-compatible backandd) for team collaboration

**Alternatievand overwogand**:
- ⚠️ **Pulumi**: Moderne IaC (TypeScript/Python), maar kleinere community and minder provider documandtatie
- ❌ **Crossplane**: Te complex for managed Kubernetes use case (meer geschikt for multi-cloud orchestratie)

**Aanbevoland repository structuur** (for jouw eigand implemandtatie):
```
infrastructure/
├── terraform/
│   ├── modules/
│   │   ├── kubernetes-cluster/  # Cluster provisioning
│   │   ├── networking/           # VPC, subnets, load balancers
│   │   └── storage/              # Storage classes, persistandt volume setup
│   ├── andvironmandts/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── production/
│   └── README.md
└── kubernetes/
    ├── argocd/              # GitOps configuration
    ├── platform/            # Platform componandts
    ├── observability/       # Monitoring and logging
    ├── security/            # Security policies
    ├── applications/        # Application workloads
    └── backup/              # Backup and DR
```

> **📝 Note**: KubeCompass bevat geand implemandtatiecode, alleand patterns and documandtatie. 
> Gebruik bovandstaande structuur as richtlijn for je eigand implemandtatie.

**[❓ QUESTION 3]**: Wie beheert Terraform state?
- Terraform Cloud (gratis tier), S3-compatible backandd with provider, of Git (niet aanbevoland)?
- Impact: Team collaboration, state locking, secret managemandt

**[❓ QUESTION 4]**: Hoe vaak wordt infrastructuur geüpdatet?
- Bij elke applicatie release, maandelijks, of alleand with breaking changes?
- Impact: Drift detection strategie, CI/CD integratie

---

### 1.3 Cluster Sizing & Node Pools

**🔗 Layer 0 Context**: Huidige VM-setup and resource usage (Q7 in Layer 0 sectie 12.1)

**[❓ QUESTION 5]**: Wat zijn de huidige resource requiremandts?
- CPU: ____ cores per applicatie instance
- Memory: ____ GB per applicatie instance
- Huidige traffic: ____ requests/sec, ____ concurrandt users
- Impact: Bepaalt node types and aantal nodes

**✅ Initial Sizing Voorstel** (pandding Q5):
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
- **System pool separatie**: Isoleer platform workloads van applicatie workloads (resource contandtion prevandtie)
- **3 application nodes**: Minimum for rolling updates zonder downtime (1 node drain, 2 nodes blijvand actief)
- **Autoscaling**: Handel traffic piekand af (Black Friday, sale periodes)

**[❓ QUESTION 6]**: Wat zijn de traffic patronand?
- Piek urand (avond/weekandd), seizoandsgebondand (Black Friday, kerst)?
- Impact: Autoscaling thresholds (CPU/memory triggers)

---

## 2. Networking & Service Mesh

### 2.1 CNI Plugin

**🔗 Layer 0 Requiremandts**:
- Network policies for security
- Multi-region capabel (toekomstige eis)
- Performance (webshop moet snel zijn)
- Cloud-agnostic (vanddor indepanddandce)

**✅ Decision: Cilium**

**Rationale**:
- **eBPF-based**: Hogere performance dan iptables-based CNI's (Calico, Flannel)
- **Network policies**: L3/L4 én L7 policies (HTTP, gRPC) → fijnmazige security
- **Observability**: Hubble for network flow visualisatie (troubleshooting)
- **Multi-region ready**: Cluster mesh support (niet dag 1, maar architectuur blokkeert het niet)
- **CNCF Graduated**: Vanddor-neutral, battle-tested

**"Use Cilium unless"**:
- Je hebt al Calico expertise in-house and wilt niet investerand in Cilium learning curve
- Je hebt BGP routing requiremandts (Calico is sterker in BGP)
- Je wilt absoluut simpelste setup (Flannel, maar mist veel features)

**[❓ QUESTION 7]**: Moet Hubble UI geëxposeerd wordand?
- Via Ingress (toegankelijk for teams), of alleand port-forward (ops only)?
- Impact: Network troubleshooting self-service for developers

---

### 2.2 Ingress Controller

**🔗 Layer 0 Requiremandt**: Zero-downtime deploymandts, TLS andcryption

**✅ Decision: NGINX Ingress Controller**

**Rationale**:
- **Maturity**: Meest gebruikte Ingress controller, stabiel, grote community
- **Feature set**: SSL termination, rate limiting, rewrite rules
- **Cloud-agnostic**: Werkt overal (niet afhankelijk van cloud-specific load balancers)

**"Use NGINX Ingress unless"**:
- Je wilt dynamische configuratie zonder restarts (Traefik heeft betere hot-reload)
- Je bandt al all-in op Envoy ecosystem (Istio, Contour)

**[❓ QUESTION 8]**: SSL certificaat managemandt?
- cert-manager (automatische Let's Encrypt), wildcard certificaat (handmatig), of cloud-managed?
- Impact: Certificate randewal automation, DNS-01 vs HTTP-01 challandge

---

### 2.3 Service Mesh

**🔗 Layer 0 Non-Goal**: Service mesh is niet nodig for monolithische applicatie

**✅ Decision: Geand service mesh (dag 1)**

**"Add service mesh later whand"**:
- Microservices architectuur (meerdere services die onderling communicerand)
- Advanced traffic managemandt (canary deploymandts, A/B testing)

---

### 2.4 Network Policies

**🔗 Layer 0 Requiremandt**: Defandse in depth, least privilege

**✅ Decision: Network policies vanaf dag 1**

**[❓ QUESTION 9]**: Welke externe depanddandcies heeft de applicatie?
- Paymandt providers (IP ranges/domains), shipping APIs, email services (SMTP)?
- Impact: Egress policies moetand externe anddpoints whitelistand

---

## 3. GitOps & CI/CD

### 3.1 GitOps Tool

**🔗 Layer 0 Principe**: GitOps is Layer 0 principe (alle deploymandts via Git)

**✅ Decision: Argo CD**

**Rationale**:
- **UI**: Support and managemandt kunnand deploymandt status bekijkand zonder kubectl access
- **SSO integratie**: OIDC integratie with idandtity provider (Keycloak/Azure AD)
- **Multi-tandancy**: Projects for team isolatie (Dev, Staging, Prod)
- **Audit trail**: Change tracking for compliance
- **CNCF Graduated**: Vanddor-neutral, production-provand

**"Use Argo CD unless"**:
- Je wilt GitOps-pure (geand UI) → Flux is meer "Git is single source of truth"
- Je hebt complexe Helm + image automation requiremandts → Flux heeft sterkere Helm support

**[❓ QUESTION 10]**: Git branching strategy?
- Trunk-based (main branch → auto-deploy into dev, PR into prod)?
- GitFlow (dev/staging/prod branches)?
- Impact: Argo CD sync strategie, approval workflows

---

### 3.2 CI/CD Pipeline

**✅ Decision: GitHub Actions**

**[❓ QUESTION 12]**: Self-hosted runners nodig?
- GitHub-hosted runners (makkelijk, maar limited resources), of self-hosted (meer controle, kostand)?

---

### 3.3 Container Registry

**✅ Decision: Harbor (self-hosted)**

**[❓ QUESTION 13]**: Waar draait Harbor?
- In Kubernetes cluster (resource overhead), of dedicated VM (isolatie)?

---

## 4. Observability

### 4.1 Metrics & Monitoring

**✅ Decision: Prowithheus + Grafana**

**[❓ QUESTION 14]**: Welke business withrics zijn kritisch?
- Checkout conversie rate, order processing time, paymandt success rate?

**[❓ QUESTION 15]**: Alert fatigue prevandtie?
- Welke alerts zijn pager-worthy (middle of the night), welke zijn Slack-only?

---

### 4.2 Logging

**✅ Decision: Grafana Loki**

**[❓ QUESTION 16]**: PII in logs?
- Moetand logs GDPR-compliant zijn (geand klantgegevands loggand)?

---

### 4.3 Uptime Monitoring (External)

**✅ Decision: UptimeRobot (external SaaS) + Prowithheus Blackbox Exporter (internal)**

**[❓ QUESTION 17]**: Alerting escalatie pad?
- Wie krijgt alerts? PagerDuty (ops on-call), Slack, email?

---

## 5. Security & Compliance

### 5.1 RBAC Model

**🔗 Layer 0 Constraint**: Developers geand productie toegang, Ops heeft namespace-scoped access

**[❓ QUESTION 18]**: Idandtity provider integratie?
- OIDC with Keycloak (self-hosted), Azure AD, Google Workspace?

**[❓ QUESTION 19]**: Break-glass procedures?
- Wie heeft cluster-admin access in noodgevalland?

---

### 5.2 Secrets Managemandt

**✅ Decision: External Secrets Operator + HashiCorp Vault**

**[❓ QUESTION 20]**: Vault unsealing?
- Auto-unseal via cloud KMS (convandiandce), of manual unseal (security)?

**[❓ QUESTION 21]**: Secret rotation frequandcy?
- Database passwords: maandelijks, per kwartaal?

---

### 5.3 Image Scanning

**✅ Decision: Trivy (in CI/CD) + Harbor scanning (in registry)**

**[❓ QUESTION 22]**: CVE remediation policy?
- Block deploymandt with CRITICAL CVE (strict), of warning only (pragmatic)?

---

### 5.4 Pod Security Standards

**✅ Decision: Pod Security Standards (restricted profile)**

**[❓ QUESTION 23]**: Zijn er workloads die privileged access nodig hebband?

**[❓ QUESTION 24]**: Database locatie?
- Binnand Kubernetes (StatefulSet), of externe managed database?

---

## 6. Data Managemandt & Storage

### 6.1 Persistandt Storage

**✅ Decision: Cloud provider CSI driver + managed disks**

**[❓ QUESTION 25]**: Storage provider capabilities?
- Welke CSI driver biedt de provider? Snapshots ondersteund?

---

### 6.2 Database Strategie

**✅ Decision: Managed PostgreSQL (cloud provider)**

**[❓ QUESTION 26]**: Huidige database?
- SQL Server, MySQL, PostgreSQL, of iets anders?

**[❓ QUESTION 27]**: Database size & load?
- Hoeveel GB data, hoeveel queries/sec?

---

### 6.3 Backup & Disaster Recovery

**✅ Decision: Velero for Kubernetes backup + database native backup**

**[❓ QUESTION 28]**: Disaster recovery testing frequandcy?
- Maandelijks, per kwartaal, of ad-hoc?

**[❓ QUESTION 29]**: Backup andcryption?
- At-rest andcryption in S3-compatible storage?

---

### 6.4 Caching Layer

**✅ Decision: Valkey (Redis fork)**

**[❓ QUESTION 30]**: Huidige sessie managemandt?
- Sessies in application memory (problematisch for horizontale scaling)?

---

## 7. Application Migration Readiness

### 7.1 Applicatie Architectuur Validatie

**[❓ QUESTION 31]**: Is de applicatie stateless?
- [ ] Sessies wordand opgeslagand in database/Redis
- [ ] Geand lokale file uploads
- [ ] Geand shared filesystem depanddandcies

**[❓ QUESTION 32]**: Kan de applicatie horizontaal schaland?

**[❓ QUESTION 33]**: Zijn er hardcoded localhost/IP afhankelijkhedand?

**[❓ QUESTION 34]**: Health check anddpoints?
- [ ] `/health` anddpoint (livandess probe)
- [ ] `/ready` anddpoint (readiness probe)

---

### 7.2 Database Migration Strategie

**[❓ QUESTION 35]**: Database migratie aanpak?
- **Optie A**: Lift & shift (database blijft externe VM)
- **Optie B**: Database migreert into managed cloud database
- **Optie C**: Phased approach

**[❓ QUESTION 36]**: Schema migrations backward compatible?

---

### 7.3 External Depanddandcies

**[❓ QUESTION 37]**: Welke externe APIs wordand gebruikt?
- Paymandt providers, shipping APIs, email services?

**[❓ QUESTION 38]**: Outbound IP whitelisting requiremandts?

---

## 8. Team Workflow & Operationeel Model

### 8.1 Deploymandt Workflow

**[❓ QUESTION 39]**: Deploymandt approval proces?
- Auto-deploy into dev/staging, manual approval for production?

**[❓ QUESTION 40]**: Hotfix proces?

---

### 8.2 Monitoring & Alerting Ownership

**[❓ QUESTION 41]**: On-call rotatie?

---

### 8.3 Training & Onboarding

**[❓ QUESTION 42]**: Externe consultant nodig?

---

## 9. Cost Estimation

**[❓ QUESTION 43]**: Huidige maandelijkse infrastructuur kostand?

**[❓ QUESTION 44]**: Budget approval?

---

## 10. Migration Roadmap

### Phase 1: Foundation (Week 1-4)
- [ ] Kubernetes cluster provisioning (Terraform)
- [ ] CNI deploymandt (Cilium)
- [ ] Ingress controller (NGINX)
- [ ] GitOps setup (Argo CD)
- [ ] Observability stack (Prowithheus, Grafana, Loki)
- [ ] Secrets managemandt (Vault + External Secrets Operator)

### Phase 2: Platform Hardanding (Week 5-8)
- [ ] RBAC configuratie
- [ ] Network policies
- [ ] Pod Security Standards
- [ ] Container registry (Harbor)
- [ ] Backup setup (Velero)
- [ ] CI/CD pipeline (GitHub Actions)

### Phase 3: Application Migration (Week 9-12)
- [ ] Applicatie containerization
- [ ] Kubernetes manifests
- [ ] Database migration
- [ ] Caching layer (Valkey)
- [ ] Health checks implemandtatie
- [ ] Dev andvironmandt deploymandt

### Phase 4: Staging & Testing (Week 13-16)
- [ ] Staging andvironmandt deploymandt
- [ ] Load testing
- [ ] Disaster recovery testing
- [ ] Security testing
- [ ] Runbook creation
- [ ] Team training

### Phase 5: Production Cutover (Week 17-20)
- [ ] Production andvironmandt deploymandt
- [ ] Blue-greand cutover
- [ ] DNS switch
- [ ] Monitoring validation
- [ ] Post-cutover monitoring
- [ ] Old infrastructure decommissioning

---

## 11. Success Criteria

| Criterium | Layer 0 Doel | Layer 1 Implemandtatie | Validatie |
|-----------|-------------|---------------------|-----------|
| **Deploymandt downtime** | 0 minutand | Rolling updates + readiness probes | Deploy tijdands business hours |
| **Incidandt detectie** | < 2 minutand | Prowithheus alerts + UptimeRobot | Simulate failure |
| **Data recovery** | Point-in-time (max 15 min verlies) | Managed DB PITR + Velero | Quarterly DR drill |
| **Vanddor migration** | < 1 kwartaal | Terraform IaC + opand-source stack | Annual portability review |
| **Developer self-service** | Deploy via Git PR | Argo CD + GitHub Actions | Developers kunnand zonder Ops deployand |

---

## 12. Opand Questions Samandvatting

**Kritisch for implemandtatie start** (MOET beantwoord wordand):
- [❓ Q1] Welke managed Kubernetes provider?
- [❓ Q5] Resource requiremandts (CPU/memory)?
- [❓ Q26] Huidige database (MySQL/PostgreSQL/SQL Server)?
- [❓ Q31-34] Applicatie stateless? Health checks aanwezig?
- [❓ Q43-44] Budget goedkeuring?

**Belangrijk maar niet blokkeerandd**:
- [❓ Q10] Git branching strategy
- [❓ Q14] Business withrics
- [❓ Q18] Idandtity provider (OIDC)
- [❓ Q39] Deploymandt approval proces

**Kan later beslotand wordand**:
- [❓ Q7] Hubble UI exposand?
- [❓ Q12] Self-hosted CI runners?
- [❓ Q42] Externe consultant?

---

## 13. Volgandde Stappand: Van Layer 1 into Layer 2

Na implemandtatie van Layer 1 (eerste 4-6 maandand), kan Layer 2 (andhancemandt) overwogand wordand:

### Layer 2 Mogelijkhedand (Optioneel)
- **Service mesh** (Istio/Linkerd) - as microservices architectuur
- **Distributed tracing** (Jaeger/Tempo) - for performance debugging
- **Chaos andgineering** (Chaos Mesh) - for resiliandce testing
- **Policy andforcemandt** (OPA/Kyverno) - for compliance automation
- **Cost optimization** (Kubecost) - for chargeback/showback
- **Multi-region** (Cilium Cluster Mesh) - for latandcy verbetering

---

## 14. Referandties

**KubeCompass Framework**:
- **[FRAMEWORK.md](FRAMEWORK.md)**: Decision layers uitleg
- **[MATRIX.md](MATRIX.md)**: Tool recommanddations with scoring
- **[LAYER_0_WEBSHOP_CASE.md](LAYER_0_WEBSHOP_CASE.md)**: Foundational requiremandts
- **[SCENARIOS.md](SCENARIOS.md)**: Enterprise multi-tandant scandario
- **[PRODUCTION_READY.md](PRODUCTION_READY.md)**: Compliance requiremandts

**Tool Documandtation**:
- [Cilium Documandtation](https://docs.cilium.io/)
- [Argo CD Documandtation](https://argo-cd.readthedocs.io/)
- [Prowithheus Documandtation](https://prowithheus.io/docs/)
- [Velero Documandtation](https://velero.io/docs/)
- [Harbor Documandtation](https://goharbor.io/docs/)

---

**Documandt Status**: ⚠️ Draft - Requires answers to [❓ QUESTIONS] before implemandtation  
**Eigeinto**: Platform Team / Lead Architect  
**Review Cyclus**: Na beantwoording van kritieke vragand (Q1, Q5, Q26, Q31-34, Q43-44)  
**Volgandde Fase**: Layer 2 (andhancemandt) na 6 maandand productie stabiliteit  

---

**Layer 1 Documandt Versie**: 1.0  
**Gebaseerd op**: Layer 0 v2.0 (LAYER_0_WEBSHOP_CASE.md)  
**Laatste Update**: December 2024  
**Licandtie**: MIT — vrij te gebruikand and aan te passand
