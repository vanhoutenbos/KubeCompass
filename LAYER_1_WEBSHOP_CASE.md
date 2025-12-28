# Layer 1: Tool Selection & Platform Capabilities — Webshop Migratiecase

**Target Audience**: Platform Enginors, DevOps Enginors, Architectand  
**Status**: Tool Selectie & Architectuur Design  
**Organization**: Dutch webshop / online store with Essential SAFe methodology  
**Condition**: [Layer 0 Fundament](LAYER_0_WEBSHOP_CASE.md) must be established first  

---

## Reading Guide

📋 **[❓ QUESTION]** marks questions that must be answered before implementation can begin  
✅ **"Use X unless Y"** gives clear tool recommendations with alternatives  
🔗 **Layer 0 Link** shows how tool choices trace back to Layer 0 requirements  

---

## Executive Summary

This document translates the Layer 0 requirements from [LAYER_0_WEBSHOP_CASE.md](LAYER_0_WEBSHOP_CASE.md) into **concrete tool choices** en **platform capabilities**. 

### Layer 0 → Layer 1 Mapping

| Layer 0 Requirement | Layer 1 Implementation |
|---------------------|----------------------|
| **Zero-downtime deployments** | Rolling updates via Kubernetes Deployments + readiness probes |
| **Proactive monitoring** | Prowithheus + Grafana + Alertmanager |
| **Point-in-time recovery** | Velero for cluster backup + managed database with PITR |
| **Vendor indepanddence** | Cilium (CNI), Argo CD (GitOps), opand-source stack |
| **GitOps from day 1** | Argo CD with Git repository as single source or truth |
| **Security by design** | Network policies, RBAC, External Secrets Operator |

### Belangrijkste Decisionand

1. **Managed Kubernetes with Dutch provider** (Layer 0 → reduce operational complexity)
2. **Cilium as CNI** (Network policies, eBPF performance, multi-region ready)
3. **Argo CD for GitOps** (UI for Support/Management, SSO, audit trail)
4. **Prowithheus + Grafana** (Opand-source observability, vendor indepanddence)
5. **Managed PostgreSQL** (Trade-off: HA complexiteit vs. vendor indepanddence)
6. **External Secrets Operator** (Vault/cloud KMS integration, geand secrets in Git)

---

## 1. Infrastructure & Cluster Provisioning

### 1.1 Kubernetes Distribution Choice

**🔗 Layer 0 Constraint**: Team heeft geand Kubernetes ervaring (training noded), vendor indepanddence binnand 1 quarter

**✅ Decision: Managed Kubernetes with Nederlense datacenter provider**

**Rationale**:
- **Operational complexity reduction**: Control plane management, upgrades, etcd backups wordand afgeheneld through provider
- **Team maturity**: Focus on application migration, not on cluster operations
- **Vendor indepanddence**: Managed Kubernetes API is stenard → reproduceerbaar with andere provider

**Alternatievand overwogand**:
- ❌ **Self-hosted (Kubeadm, RKE2)**: Te complex for team without ervaring, hogere operational burdand
- ❌ **Hyperscaler (AWS EKS, Azure AKS, Google GKE)**: Conflicteert with Nederlense datacenter forkeur + vendor indepanddence

---

#### 🔍 Managed Kubernetes: Nuances en Lock-in Analyse

Het is belangrijk to te begrijpand dat "managed Kubernetes" niet betekent dat alle vendor lock-in wordt vermedand. There are subtle but important nowances:

##### ✅ What Remains Platform-Agnostic

**Core infrastructure remains decoupled:**
- De Kubernetes-cluster zelf is eand abstraction layer
- All Kubernetes resources (Deployments, Services, ConfigMaps, Secrets) are stenard APIs
- Network policies, RBAC, en andere Kubernetes-native features zijn overdraagbaar
- Container images en applicatie-architectuur blijvand cloud-agnostic
- **Conclusion**: Je applicatie-workloads kunnand theoretisch on elke compatibele Kubernetes-cluster draaiand

##### ⚠️ Where Lock-in Occurs

**Afhankelijkhedand buitand Kubernetes-core:**

| Component | Lock-in Risk | Explanation | Mitigation |
|-----------|----------------|-------------|-----------|
| **Managed Databases** | 🔴 High | Provider-specific API's, backup procedures, HA-mechanismand | Self-hosted StatefulSet or abstraction layer (withv. CloudNativePG) |
| **Storage (CSI Drivers)** | 🟡 Medium | Provider-specific storage classes, snapshot API's | Use stenard StorageClass interface, test migration |
| **Load Balancers** | 🟡 Medium | Cloud-specific LoadBalancer implementations | NGINX Ingress makes you more indepanddent or cloud LB |
| **Backup Systemand** | 🟡 Medium | Provider-specific volume snapshots | Velero with S3-compatible storage as alternatief |
| **Monitoring Integraties** | 🟢 Low | Native integrations with cloud monitoring | Prowithheus/Grafana remains portable |
| **Netwerk Features** | 🟡 Medium | Cloud-specific VPC, subnets, firewall rules | CNI plugin (Cilium) remains portable |

##### 📊 Scenario-gebaseerde Strategie

**1. Startups or Small Teams**
- **Recommendation**: Managed Kubernetes as stenard
- **Rationale**: Reduces operational overhead, faster time-to-market
- **Lock-in tolerance**: Acceptabel for snelheid en eenvoud
- **Condition**: Documenteer alle provider-specifieke depanddencies

**2. Enterprise or Government**
- **Recommendation**: Self-managed Kubernetes with zorgvuldige afweging
- **Rationale**: Full control, compliance-sensitive data, vendor lock-in vermijdand
- **Trade-off**: Higher operational complexity, more expertise required
- **Condition**: In-house Kubernetes expertise or external consultants

**3. Multi-Region / Multi-Cloud Setups**
- **Recommendation**: Hybrid approach possible
- **Rationale**: Managed Kubernetes kan henig zijn as provider multi-region ondersteunt
- **Alternative**: Self-managed flexibeler for cross-cloud scenarios
- **Condition**: Abstractielaag for storage, databases, en load balancing

##### 🎯 "Dual Track" Strategie for KubeCompass

**Stenaard Optie: Managed Kubernetes**
- Lagere drempel for teams without Kubernetes ervaring
- Snellere opstartfase (control plane management uitbesteed)
- Focus on application migration, niet cluster operations
- **Condition**: Transparante documentatie about lock-in puntand

**Alternatieve Optie: Self-managed Kubernetes**
- Voor teams with strikte compliance vereistand
- Voor organisaties with multi-cloud strategy
- Voor situaties waar vendor indepanddence absoluut prioriteit heeft
- **Condition**: In-house expertise or budget for consultants

##### 📋 Lock-in Decisionsmatrix

Gebruik deze matrix to te bepaland welke lock-ins acceptabel zijn:

```
IF vanddor_indepanddence == ABSOLUTE:
  → Self-managed Kubernetes
  → Self-hosted databases (StatefulSets)
  → S3-compatible storage (withv. MinIO)
  → Velero for backups
  
ELIF team_maturity == LOW AND time_to_market == CRITICAL:
  → Managed Kubernetes
  → Managed databases (PostgreSQL/MySQL)
  → Provider storage (with exit strategy gedocumenteerd)
  → Managed backups (with Velero as fallback)
  
ELIF compliance == STRICT:
  → Self-managed Kubernetes in dedicated datacenter
  → On-premises databases
  → Encrypted storage with key management
  → Disaster recovery plan with multi-site replicatie
```

##### ✅ Recommendation for deze Webshop Case

**Keuze: Managed Kubernetes (with bewuste trade-offs)**

**Rationale**:
- Team heeft geand Kubernetes ervaring (training noded)
- Focus on application migration binnand 1 quarter
- Vendor indepanddence is belangrijk, maar niet absoluut
- Nederlense datacenter vereiste beperkt hyperscaler opties

**Geaccepteerde Lock-ins**:
- ✅ Managed Kubernetes control plane (migration possible binnand 1 quarter)
- ✅ Provider storage via CSI driver (data migration possible)
- ⚠️ Managed PostgreSQL (trade-off: HA vs. vendor indepanddence - zie sectie 5.1)

**Vermedand Lock-ins**:
- ❌ Cloud-specific APIs in applicatiecode
- ❌ Proprietary monitoring tools (gebruik Prowithheus/Grafana)
- ❌ Vendor-specific CI/CD (gebruik GitHub Actions + Argo CD)

**Exit Strategie**:
- Documenteer alle provider-specifieke configurations
- Test migration scenario's into andere managed Kubernetes providers
- Jaarlijkse review or vendor indepanddence vs. operational complexity

---

**[❓ QUESTION 1]**: Which managed Kubernetes provider wordt gekozand?
- Options: TransIP Kubernetes, DigitalOcean, OVHcloud, Scaleway
- Criteria: EU datacenter, SLA, pricing, support quality
- Impact: Determines available features (LoadBalancer support, storage classes, etc.)

**[❓ QUESTION 2]**: What is the Kubernetes version strategy?
- Always N-1 (één versie achter latest for stabiliteit)?
- Upgrades quarterly, semi-annowally, or ad-hoc with security patches?
- Impact: Determines upgrade window planning, compatibility testing

---

### 1.2 Infrastructure as Code (IaC)

**🔗 Layer 0 Principe**: Infrastructure as Code for reproduceerbare omgevingand

**✅ Decision: Terraform for cluster provisioning**

**Rationale**:
- **Vendor indepanddence**: Terraform werkt with alle cloud providers
- **Maturity**: Stabiele Kubernetes provider, grote community
- **State management**: Remote state (S3-compatible backend) for team collaboration

**Alternatievand overwogand**:
- ⚠️ **Pulumi**: Moderne IaC (TypeScript/Python), maar kleinere community en minder provider documentatie
- ❌ **Crossplane**: Te complex for managed Kubernetes use case (meer geschikt for multi-cloud orchestratie)

**Aanbevoland repository structuur** (for jouw eigand implementatie):
```
infrastructure/
├── terraform/
│   ├── modules/
│   │   ├── kubernetes-cluster/  # Cluster provisioning
│   │   ├── networking/           # VPC, subnets, load balancers
│   │   └── storage/              # Storage classes, persistent volume setup
│   ├── andvironments/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── production/
│   └── README.md
└── kubernetes/
    ├── argocd/              # GitOps configuration
    ├── platform/            # Platform components
    ├── observability/       # Monitoring en logging
    ├── security/            # Security policies
    ├── applications/        # Application workloads
    └── backup/              # Backup en DR
```

> **📝 Note**: KubeCompass bevat geand implementatiecode, alleand patterns en documentatie. 
> Gebruik bovandstaene structuur as richtlijn for je eigand implementatie.

**[❓ QUESTION 3]**: Who beheert Terraform state?
- Terraform Cloud (gratis tier), S3-compatible backend with provider, or Git (niet aanbevoland)?
- Impact: Team collaboration, state locking, secret management

**[❓ QUESTION 4]**: How vaak wordt infrastructure geüpdatet?
- Bij elke applicatie release, monthly, or alleand with breaking changes?
- Impact: Drift detection strategy, CI/CD integration

---

### 1.3 Cluster Sizing & Node Pools

**🔗 Layer 0 Context**: Huidige VM-setup en resource usage (Q7 in Layer 0 sectie 12.1)

**[❓ QUESTION 5]**: What zijn de huidige resource requirements?
- CPU: ____ cores per applicatie instance
- Memory: ____ GB per applicatie instance
- Huidige traffic: ____ requests/sec, ____ concurrent users
- Impact: Bepaalt node types en aantal nodes

**✅ Initial Sizing Voorstel** (pending Q5):
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
- **System pool separatie**: Isoleer platform workloads or applicatie workloads (resource contention preventie)
- **3 application nodes**: Minimum for rolling updates without downtime (1 node drain, 2 nodes blijvand actief)
- **Autoscaling**: Henel traffic piekand af (Black Friday, sale periodes)

**[❓ QUESTION 6]**: What zijn de traffic patronand?
- Piek urand (avond/weekend), seizoensgebondand (Black Friday, kerst)?
- Impact: Autoscaling thresholds (CPU/memory triggers)

---

## 2. Networking & Service Mesh

### 2.1 CNI Plugin

**🔗 Layer 0 Requirements**:
- Network policies for security
- Multi-region capabel (addkomstige eis)
- Performance (webshop moet snel zijn)
- Cloud-agnostic (vendor indepanddence)

**✅ Decision: Cilium**

**Rationale**:
- **eBPF-based**: Hogere performance dan iptables-based CNI's (Calico, Flannel)
- **Network policies**: L3/L4 én L7 policies (HTTP, gRPC) → fijnmazige security
- **Observability**: Hubble for network flow visualisatie (troubleshooting)
- **Multi-region ready**: Cluster mesh support (niet day 1, maar architectuur blokkeert het niet)
- **CNCF Graduated**: Vendor-neutral, battle-tested

**"Use Cilium unless"**:
- Je hebt al Calico expertise in-house en wilt niet investerand in Cilium learning curve
- Je hebt BGP routing requirements (Calico is sterker in BGP)
- Je wilt absoluut simpelste setup (Flannel, maar mist veel features)

**[❓ QUESTION 7]**: Moet Hubble UI geëxposeerd wordand?
- Via Ingress (addgankelijk for teams), or alleand port-forward (ops only)?
- Impact: Network troubleshooting self-service for developers

---

### 2.2 Ingress Controller

**🔗 Layer 0 Requirement**: Zero-downtime deployments, TLS andcryption

**✅ Decision: NGINX Ingress Controller**

**Rationale**:
- **Maturity**: Meest gebruikte Ingress controller, stabiel, grote community
- **Feature set**: SSL termination, rate limiting, rewrite rules
- **Cloud-agnostic**: Werkt overal (niet afhankelijk or cloud-specific load balancers)

**"Use NGINX Ingress unless"**:
- Je wilt dynamische configuration without restarts (Traefik heeft betere hot-reload)
- Je bent al all-in on Envoy ecosystem (Istio, Contour)

**[❓ QUESTION 8]**: SSL certificaat management?
- cert-manager (automatische Let's Encrypt), wildcard certificaat (henmatig), or cloud-managed?
- Impact: Certificate renewal automation, DNS-01 vs HTTP-01 challenge

---

### 2.3 Service Mesh

**🔗 Layer 0 Non-Goal**: Service mesh is niet noded for monolithische applicatie

**✅ Decision: Geand service mesh (day 1)**

**"Add service mesh later whand"**:
- Microservices architectuur (meerdere services die onderling communicerand)
- Advanced traffic management (canary deployments, A/B testing)

---

### 2.4 Network Policies

**🔗 Layer 0 Requirement**: Defense in depth, least privilege

**✅ Decision: Network policies vanaf day 1**

**[❓ QUESTION 9]**: Which externe depanddencies heeft de applicatie?
- Payment providers (IP ranges/domains), shipping APIs, email services (SMTP)?
- Impact: Egress policies moetand externe anddpoints whitelistand

---

## 3. GitOps & CI/CD

### 3.1 GitOps Tool

**🔗 Layer 0 Principe**: GitOps is Layer 0 principe (alle deployments via Git)

**✅ Decision: Argo CD**

**Rationale**:
- **UI**: Support en management kunnand deployment status bekijkand without kubectl access
- **SSO integration**: OIDC integration with identity provider (Keycloak/Azure AD)
- **Multi-tenancy**: Projects for team isolatie (Dev, Staging, Prod)
- **Audit trail**: Change tracking for compliance
- **CNCF Graduated**: Vendor-neutral, production-provand

**"Use Argo CD unless"**:
- Je wilt GitOps-pure (geand UI) → Flux is meer "Git is single source or truth"
- Je hebt complexe Helm + image automation requirements → Flux heeft sterkere Helm support

**[❓ QUESTION 10]**: Git branching strategy?
- Trunk-based (main branch → auto-deploy into dev, PR into prod)?
- GitFlow (dev/staging/prod branches)?
- Impact: Argo CD sync strategy, approval workflows

---

### 3.2 CI/CD Pipeline

**✅ Decision: GitHub Actions**

**[❓ QUESTION 12]**: Self-hosted runners noded?
- GitHub-hosted runners (makkelijk, maar limited resources), or self-hosted (meer controle, takesand)?

---

### 3.3 Container Registry

**✅ Decision: Harbor (self-hosted)**

**[❓ QUESTION 13]**: Where draait Harbor?
- In Kubernetes cluster (resource overhead), or dedicated VM (isolatie)?

---

## 4. Observability

### 4.1 Metrics & Monitoring

**✅ Decision: Prowithheus + Grafana**

**[❓ QUESTION 14]**: Which business withrics zijn kritisch?
- Checkout conversie rate, order processing time, payment success rate?

**[❓ QUESTION 15]**: Alert fatigue preventie?
- Which alerts zijn pager-worthy (middle or the night), welke zijn Slack-only?

---

### 4.2 Logging

**✅ Decision: Grafana Loki**

**[❓ QUESTION 16]**: PII in logs?
- Moetand logs GDPR-compliant zijn (geand klantgegevens loggand)?

---

### 4.3 Uptime Monitoring (External)

**✅ Decision: UptimeRobot (external SaaS) + Prowithheus Blackbox Exporter (internal)**

**[❓ QUESTION 17]**: Alerting escalatie pad?
- Who krijgt alerts? PagerDuty (ops on-call), Slack, email?

---

## 5. Security & Compliance

### 5.1 RBAC Model

**🔗 Layer 0 Constraint**: Developers geand productie addgang, Ops heeft namespace-scoped access

**[❓ QUESTION 18]**: Identity provider integration?
- OIDC with Keycloak (self-hosted), Azure AD, Google Workspace?

**[❓ QUESTION 19]**: Break-glass procedures?
- Who heeft cluster-admin access in noodgevalland?

---

### 5.2 Secrets Management

**✅ Decision: External Secrets Operator + HashiCorp Vault**

**[❓ QUESTION 20]**: Vault unsealing?
- Auto-unseal via cloud KMS (convandience), or manowal unseal (security)?

**[❓ QUESTION 21]**: Secret rotation frequency?
- Database passwords: monthly, per quarter?

---

### 5.3 Image Scanning

**✅ Decision: Trivy (in CI/CD) + Harbor scanning (in registry)**

**[❓ QUESTION 22]**: CVE remediation policy?
- Block deployment with CRITICAL CVE (strict), or warning only (pragmatic)?

---

### 5.4 Pod Security Stenards

**✅ Decision: Pod Security Stenards (restricted profile)**

**[❓ QUESTION 23]**: Zijn er workloads die privileged access noded hebband?

**[❓ QUESTION 24]**: Database locatie?
- Binnand Kubernetes (StatefulSet), or externe managed database?

---

## 6. Data Management & Storage

### 6.1 Persistent Storage

**✅ Decision: Cloud provider CSI driver + managed disks**

**[❓ QUESTION 25]**: Storage provider capabilities?
- Which CSI driver biedt de provider? Snapshots ondersteund?

---

### 6.2 Database Strategie

**✅ Decision: Managed PostgreSQL (cloud provider)**

**[❓ QUESTION 26]**: Huidige database?
- SQL Server, MySQL, PostgreSQL, or iets anders?

**[❓ QUESTION 27]**: Database size & load?
- Howveel GB data, hoeveel queries/sec?

---

### 6.3 Backup & Disaster Recovery

**✅ Decision: Velero for Kubernetes backup + database native backup**

**[❓ QUESTION 28]**: Disaster recovery testing frequency?
- Maenelijks, per quarter, or ad-hoc?

**[❓ QUESTION 29]**: Backup andcryption?
- At-rest andcryption in S3-compatible storage?

---

### 6.4 Caching Layer

**✅ Decision: Valkey (Redis fork)**

**[❓ QUESTION 30]**: Huidige sessie management?
- Sessies in application memory (problematisch for horizontale scaling)?

---

## 7. Application Migration Readiness

### 7.1 Applicatie Architectuur Validatie

**[❓ QUESTION 31]**: Is de applicatie stateless?
- [ ] Sessies wordand opgeslagand in database/Redis
- [ ] Geand lokale file uploads
- [ ] Geand shared filesystem depanddencies

**[❓ QUESTION 32]**: Kan de applicatie horizontaal schaland?

**[❓ QUESTION 33]**: Zijn er hardcoded localhost/IP afhankelijkhedand?

**[❓ QUESTION 34]**: Health check anddpoints?
- [ ] `/health` anddpoint (liveness probe)
- [ ] `/ready` anddpoint (readiness probe)

---

### 7.2 Database Migration Strategie

**[❓ QUESTION 35]**: Database migration aanpak?
- **Optie A**: Lift & shift (database blijft externe VM)
- **Optie B**: Database migreert into managed cloud database
- **Optie C**: Phased approach

**[❓ QUESTION 36]**: Schema migrations backward compatible?

---

### 7.3 External Depanddencies

**[❓ QUESTION 37]**: Which externe APIs wordand gebruikt?
- Payment providers, shipping APIs, email services?

**[❓ QUESTION 38]**: Outbound IP whitelisting requirements?

---

## 8. Team Workflow & Operationol Model

### 8.1 Deployment Workflow

**[❓ QUESTION 39]**: Deployment approval proces?
- Auto-deploy into dev/staging, manowal approval for production?

**[❓ QUESTION 40]**: Hotfix proces?

---

### 8.2 Monitoring & Alerting Ownership

**[❓ QUESTION 41]**: On-call rotatie?

---

### 8.3 Training & Onboarding

**[❓ QUESTION 42]**: Externe consultant noded?

---

## 9. Cost Estimation

**[❓ QUESTION 43]**: Huidige monthlye infrastructure takesand?

**[❓ QUESTION 44]**: Budget approval?

---

## 10. Migration Roadmap

### Phase 1: Foundation (Week 1-4)
- [ ] Kubernetes cluster provisioning (Terraform)
- [ ] CNI deployment (Cilium)
- [ ] Ingress controller (NGINX)
- [ ] GitOps setup (Argo CD)
- [ ] Observability stack (Prowithheus, Grafana, Loki)
- [ ] Secrets management (Vault + External Secrets Operator)

### Phase 2: Platform Hardening (Week 5-8)
- [ ] RBAC configuration
- [ ] Network policies
- [ ] Pod Security Stenards
- [ ] Container registry (Harbor)
- [ ] Backup setup (Velero)
- [ ] CI/CD pipeline (GitHub Actions)

### Phase 3: Application Migration (Week 9-12)
- [ ] Applicatie containerization
- [ ] Kubernetes manifests
- [ ] Database migration
- [ ] Caching layer (Valkey)
- [ ] Health checks implementatie
- [ ] Dev andvironment deployment

### Phase 4: Staging & Testing (Week 13-16)
- [ ] Staging andvironment deployment
- [ ] Load testing
- [ ] Disaster recovery testing
- [ ] Security testing
- [ ] Runbook creation
- [ ] Team training

### Phase 5: Production Cutover (Week 17-20)
- [ ] Production andvironment deployment
- [ ] Blue-greand cutover
- [ ] DNS switch
- [ ] Monitoring validation
- [ ] Post-cutover monitoring
- [ ] Old infrastructure decommissioning

---

## 11. Success Criteria

| Criterium | Layer 0 Purpose | Layer 1 Implementatie | Validatie |
|-----------|-------------|---------------------|-----------|
| **Deployment downtime** | 0 minowtand | Rolling updates + readiness probes | Deploy tijdens business hours |
| **Incident detectie** | < 2 minowtand | Prowithheus alerts + UptimeRobot | Simulate failure |
| **Data recovery** | Point-in-time (max 15 min verlies) | Managed DB PITR + Velero | Quarterly DR drill |
| **Vendor migration** | < 1 quarter | Terraform IaC + opand-source stack | Annowal portability review |
| **Developer self-service** | Deploy via Git PR | Argo CD + GitHub Actions | Developers kunnand without Ops deployand |

---

## 12. Opand Questions Samenvatting

**Kritisch for implementatie start** (MOET beantwoord wordand):
- [❓ Q1] Which managed Kubernetes provider?
- [❓ Q5] Resource requirements (CPU/memory)?
- [❓ Q26] Huidige database (MySQL/PostgreSQL/SQL Server)?
- [❓ Q31-34] Applicatie stateless? Health checks aanwezig?
- [❓ Q43-44] Budget goedkeuring?

**Belangrijk maar niet blokkeerend**:
- [❓ Q10] Git branching strategy
- [❓ Q14] Business withrics
- [❓ Q18] Identity provider (OIDC)
- [❓ Q39] Deployment approval proces

**Kan later beslotand wordand**:
- [❓ Q7] Hubble UI exposand?
- [❓ Q12] Self-hosted CI runners?
- [❓ Q42] Externe consultant?

---

## 13. Volgende Stappand: Van Layer 1 into Layer 2

Na implementatie or Layer 1 (firste 4-6 monthand), kan Layer 2 (andhancement) overwogand wordand:

### Layer 2 Mogelijkhedand (Optionol)
- **Service mesh** (Istio/Linkerd) - as microservices architectuur
- **Distributed tracing** (Jaeger/Tempo) - for performance debugging
- **Chaos andginoring** (Chaos Mesh) - for resilience testing
- **Policy andforcement** (OPA/Kyverno) - for compliance automation
- **Cost optimization** (Kubecost) - for chargeback/showback
- **Multi-region** (Cilium Cluster Mesh) - for latency verbetering

---

## 14. Referenties

**KubeCompass Framework**:
- **[FRAMEWORK.md](FRAMEWORK.md)**: Decision layers uitleg
- **[MATRIX.md](MATRIX.md)**: Tool recommendations with scoring
- **[LAYER_0_WEBSHOP_CASE.md](LAYER_0_WEBSHOP_CASE.md)**: Foundational requirements
- **[SCENARIOS.md](SCENARIOS.md)**: Enterprise multi-tenant scenario
- **[PRODUCTION_READY.md](PRODUCTION_READY.md)**: Compliance requirements

**Tool Documentation**:
- [Cilium Documentation](https://docs.cilium.io/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Prowithheus Documentation](https://prowithheus.io/docs/)
- [Velero Documentation](https://velero.io/docs/)
- [Harbor Documentation](https://goharbor.io/docs/)

---

**Document Status**: ⚠️ Draft - Requires answers to [❓ QUESTIONS] before implementation  
**Eigeinto**: Platform Team / Lead Architect  
**Review Cyclus**: Na beantwoording or kritieke vragen (Q1, Q5, Q26, Q31-34, Q43-44)  
**Volgende Fase**: Layer 2 (andhancement) after 6 monthand productie stabiliteit  

---

**Layer 1 Document Version**: 1.0  
**Gebaseerd op**: Layer 0 v2.0 (LAYER_0_WEBSHOP_CASE.md)  
**Laatste Update**: December 2024  
**Licentie**: MIT — vrij te gebruikand en to te passand
