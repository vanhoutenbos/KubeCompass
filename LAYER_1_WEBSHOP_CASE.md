# Layer 1: Tool Selectie & Platform Capabilities — Webshop Migratiecase

**Doelgroep**: Platform Engineers, DevOps Engineers, Architecten  
**Status**: Tool Selectie & Architectuur Design  
**Organisatie**: Nederlandse webshop / online warenhuis met Essential SAFe werkwijze  
**Voorwaarde**: [Layer 0 Fundament](LAYER_0_WEBSHOP_CASE.md) moet eerst zijn vastgesteld  

---

## Leeswijzer

📋 **[❓ QUESTION]** markeert vragen die moeten worden beantwoord voordat implementatie kan beginnen  
✅ **"Use X unless Y"** geeft duidelijke tool aanbevelingen met alternatieven  
🔗 **Layer 0 Link** toont hoe tool keuzes terug te leiden zijn naar Layer 0 requirements  

---

## Executive Summary

Dit document vertaalt de Layer 0 requirements uit [LAYER_0_WEBSHOP_CASE.md](LAYER_0_WEBSHOP_CASE.md) naar **concrete tool keuzes** en **platform capabilities**. 

### Layer 0 → Layer 1 Mapping

| Layer 0 Requirement | Layer 1 Implementation |
|---------------------|----------------------|
| **Zero-downtime deployments** | Rolling updates via Kubernetes Deployments + readiness probes |
| **Proactieve monitoring** | Prometheus + Grafana + Alertmanager |
| **Point-in-time recovery** | Velero voor cluster backup + managed database met PITR |
| **Vendor independence** | Cilium (CNI), Argo CD (GitOps), open-source stack |
| **GitOps vanaf dag 1** | Argo CD met Git repository als single source of truth |
| **Security by design** | Network policies, RBAC, External Secrets Operator |

### Belangrijkste Beslissingen

1. **Managed Kubernetes bij Nederlandse provider** (Layer 0 → reduce operational complexity)
2. **Cilium als CNI** (Network policies, eBPF performance, multi-region ready)
3. **Argo CD voor GitOps** (UI voor Support/Management, SSO, audit trail)
4. **Prometheus + Grafana** (Open-source observability, vendor independence)
5. **Managed PostgreSQL** (Trade-off: HA complexiteit vs. vendor independence)
6. **External Secrets Operator** (Vault/cloud KMS integratie, geen secrets in Git)

---

## 1. Infrastructuur & Cluster Provisioning

### 1.1 Kubernetes Distributie Keuze

**🔗 Layer 0 Constraint**: Team heeft geen Kubernetes ervaring (training nodig), vendor independence binnen 1 kwartaal

**✅ Beslissing: Managed Kubernetes bij Nederlandse datacenter provider**

**Rationale**:
- **Operational complexity reductie**: Control plane management, upgrades, etcd backups worden afgehandeld door provider
- **Team maturity**: Focus op applicatie migratie, niet op cluster operations
- **Vendor independence**: Managed Kubernetes API is standaard → reproduceerbaar bij andere provider

**Alternatieven overwogen**:
- ❌ **Self-hosted (Kubeadm, RKE2)**: Te complex voor team zonder ervaring, hogere operational burden
- ❌ **Hyperscaler (AWS EKS, Azure AKS, Google GKE)**: Conflicteert met Nederlandse datacenter voorkeur + vendor independence

**[❓ QUESTION 1]**: Welke managed Kubernetes provider wordt gekozen?
- Opties: TransIP Kubernetes, DigitalOcean, OVHcloud, Scaleway
- Criteria: EU datacenter, SLA, pricing, support kwaliteit
- Impact: Bepaalt beschikbare features (LoadBalancer support, storage classes, etc.)

**[❓ QUESTION 2]**: Wat is de Kubernetes versie strategie?
- Altijd N-1 (één versie achter latest voor stabiliteit)?
- Upgrades elk kwartaal, half jaar, of ad-hoc bij security patches?
- Impact: Bepaalt upgrade window planning, compatibility testing

---

### 1.2 Infrastructure as Code (IaC)

**🔗 Layer 0 Principe**: Infrastructure as Code voor reproduceerbare omgevingen

**✅ Beslissing: Terraform voor cluster provisioning**

**Rationale**:
- **Vendor independence**: Terraform werkt bij alle cloud providers
- **Maturity**: Stabiele Kubernetes provider, grote community
- **State management**: Remote state (S3-compatible backend) voor team collaboration

**Alternatieven overwogen**:
- ⚠️ **Pulumi**: Moderne IaC (TypeScript/Python), maar kleinere community en minder provider documentatie
- ❌ **Crossplane**: Te complex voor managed Kubernetes use case (meer geschikt voor multi-cloud orchestratie)

**Repository structuur**:
```
terraform/
├── modules/
│   ├── kubernetes-cluster/  # Cluster provisioning
│   ├── networking/           # VPC, subnets, load balancers
│   └── storage/              # Storage classes, persistent volume setup
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
└── README.md
```

**[❓ QUESTION 3]**: Wie beheert Terraform state?
- Terraform Cloud (gratis tier), S3-compatible backend bij provider, of Git (niet aanbevolen)?
- Impact: Team collaboration, state locking, secret management

**[❓ QUESTION 4]**: Hoe vaak wordt infrastructuur geüpdatet?
- Bij elke applicatie release, maandelijks, of alleen bij breaking changes?
- Impact: Drift detection strategie, CI/CD integratie

---

### 1.3 Cluster Sizing & Node Pools

**🔗 Layer 0 Context**: Huidige VM-setup en resource usage (Q7 in Layer 0 sectie 12.1)

**[❓ QUESTION 5]**: Wat zijn de huidige resource requirements?
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
- **System pool separatie**: Isoleer platform workloads van applicatie workloads (resource contention preventie)
- **3 application nodes**: Minimum voor rolling updates zonder downtime (1 node drain, 2 nodes blijven actief)
- **Autoscaling**: Handel traffic pieken af (Black Friday, sale periodes)

**[❓ QUESTION 6]**: Wat zijn de traffic patronen?
- Piek uren (avond/weekend), seizoensgebonden (Black Friday, kerst)?
- Impact: Autoscaling thresholds (CPU/memory triggers)

---

## 2. Networking & Service Mesh

### 2.1 CNI Plugin

**🔗 Layer 0 Requirements**:
- Network policies voor security
- Multi-region capabel (toekomstige eis)
- Performance (webshop moet snel zijn)
- Cloud-agnostic (vendor independence)

**✅ Beslissing: Cilium**

**Rationale**:
- **eBPF-based**: Hogere performance dan iptables-based CNI's (Calico, Flannel)
- **Network policies**: L3/L4 én L7 policies (HTTP, gRPC) → fijnmazige security
- **Observability**: Hubble voor network flow visualisatie (troubleshooting)
- **Multi-region ready**: Cluster mesh support (niet dag 1, maar architectuur blokkeert het niet)
- **CNCF Graduated**: Vendor-neutral, battle-tested

**"Use Cilium unless"**:
- Je hebt al Calico expertise in-house en wilt niet investeren in Cilium learning curve
- Je hebt BGP routing requirements (Calico is sterker in BGP)
- Je wilt absoluut simpelste setup (Flannel, maar mist veel features)

**[❓ QUESTION 7]**: Moet Hubble UI geëxposeerd worden?
- Via Ingress (toegankelijk voor teams), of alleen port-forward (ops only)?
- Impact: Network troubleshooting self-service voor developers

---

### 2.2 Ingress Controller

**🔗 Layer 0 Requirement**: Zero-downtime deployments, TLS encryption

**✅ Beslissing: NGINX Ingress Controller**

**Rationale**:
- **Maturity**: Meest gebruikte Ingress controller, stabiel, grote community
- **Feature set**: SSL termination, rate limiting, rewrite rules
- **Cloud-agnostic**: Werkt overal (niet afhankelijk van cloud-specific load balancers)

**"Use NGINX Ingress unless"**:
- Je wilt dynamische configuratie zonder restarts (Traefik heeft betere hot-reload)
- Je bent al all-in op Envoy ecosystem (Istio, Contour)

**[❓ QUESTION 8]**: SSL certificaat management?
- cert-manager (automatische Let's Encrypt), wildcard certificaat (handmatig), of cloud-managed?
- Impact: Certificate renewal automation, DNS-01 vs HTTP-01 challenge

---

### 2.3 Service Mesh

**🔗 Layer 0 Non-Goal**: Service mesh is niet nodig voor monolithische applicatie

**✅ Beslissing: Geen service mesh (dag 1)**

**"Add service mesh later when"**:
- Microservices architectuur (meerdere services die onderling communiceren)
- Advanced traffic management (canary deployments, A/B testing)

---

### 2.4 Network Policies

**🔗 Layer 0 Requirement**: Defense in depth, least privilege

**✅ Beslissing: Network policies vanaf dag 1**

**[❓ QUESTION 9]**: Welke externe dependencies heeft de applicatie?
- Payment providers (IP ranges/domains), shipping APIs, email services (SMTP)?
- Impact: Egress policies moeten externe endpoints whitelisten

---

## 3. GitOps & CI/CD

### 3.1 GitOps Tool

**🔗 Layer 0 Principe**: GitOps is Layer 0 principe (alle deployments via Git)

**✅ Beslissing: Argo CD**

**Rationale**:
- **UI**: Support en management kunnen deployment status bekijken zonder kubectl access
- **SSO integratie**: OIDC integratie met identity provider (Keycloak/Azure AD)
- **Multi-tenancy**: Projects voor team isolatie (Dev, Staging, Prod)
- **Audit trail**: Change tracking voor compliance
- **CNCF Graduated**: Vendor-neutral, production-proven

**"Use Argo CD unless"**:
- Je wilt GitOps-pure (geen UI) → Flux is meer "Git is single source of truth"
- Je hebt complexe Helm + image automation requirements → Flux heeft sterkere Helm support

**[❓ QUESTION 10]**: Git branching strategy?
- Trunk-based (main branch → auto-deploy naar dev, PR naar prod)?
- GitFlow (dev/staging/prod branches)?
- Impact: Argo CD sync strategie, approval workflows

---

### 3.2 CI/CD Pipeline

**✅ Beslissing: GitHub Actions**

**[❓ QUESTION 12]**: Self-hosted runners nodig?
- GitHub-hosted runners (makkelijk, maar limited resources), of self-hosted (meer controle, kosten)?

---

### 3.3 Container Registry

**✅ Beslissing: Harbor (self-hosted)**

**[❓ QUESTION 13]**: Waar draait Harbor?
- In Kubernetes cluster (resource overhead), of dedicated VM (isolatie)?

---

## 4. Observability

### 4.1 Metrics & Monitoring

**✅ Beslissing: Prometheus + Grafana**

**[❓ QUESTION 14]**: Welke business metrics zijn kritisch?
- Checkout conversie rate, order processing time, payment success rate?

**[❓ QUESTION 15]**: Alert fatigue preventie?
- Welke alerts zijn pager-worthy (middle of the night), welke zijn Slack-only?

---

### 4.2 Logging

**✅ Beslissing: Grafana Loki**

**[❓ QUESTION 16]**: PII in logs?
- Moeten logs GDPR-compliant zijn (geen klantgegevens loggen)?

---

### 4.3 Uptime Monitoring (External)

**✅ Beslissing: UptimeRobot (external SaaS) + Prometheus Blackbox Exporter (internal)**

**[❓ QUESTION 17]**: Alerting escalatie pad?
- Wie krijgt alerts? PagerDuty (ops on-call), Slack, email?

---

## 5. Security & Compliance

### 5.1 RBAC Model

**🔗 Layer 0 Constraint**: Developers geen productie toegang, Ops heeft namespace-scoped access

**[❓ QUESTION 18]**: Identity provider integratie?
- OIDC met Keycloak (self-hosted), Azure AD, Google Workspace?

**[❓ QUESTION 19]**: Break-glass procedures?
- Wie heeft cluster-admin access in noodgevallen?

---

### 5.2 Secrets Management

**✅ Beslissing: External Secrets Operator + HashiCorp Vault**

**[❓ QUESTION 20]**: Vault unsealing?
- Auto-unseal via cloud KMS (convenience), of manual unseal (security)?

**[❓ QUESTION 21]**: Secret rotation frequency?
- Database passwords: maandelijks, per kwartaal?

---

### 5.3 Image Scanning

**✅ Beslissing: Trivy (in CI/CD) + Harbor scanning (in registry)**

**[❓ QUESTION 22]**: CVE remediation policy?
- Block deployment bij CRITICAL CVE (strict), of warning only (pragmatic)?

---

### 5.4 Pod Security Standards

**✅ Beslissing: Pod Security Standards (restricted profile)**

**[❓ QUESTION 23]**: Zijn er workloads die privileged access nodig hebben?

**[❓ QUESTION 24]**: Database locatie?
- Binnen Kubernetes (StatefulSet), of externe managed database?

---

## 6. Data Management & Storage

### 6.1 Persistent Storage

**✅ Beslissing: Cloud provider CSI driver + managed disks**

**[❓ QUESTION 25]**: Storage provider capabilities?
- Welke CSI driver biedt de provider? Snapshots ondersteund?

---

### 6.2 Database Strategie

**✅ Beslissing: Managed PostgreSQL (cloud provider)**

**[❓ QUESTION 26]**: Huidige database?
- SQL Server, MySQL, PostgreSQL, of iets anders?

**[❓ QUESTION 27]**: Database size & load?
- Hoeveel GB data, hoeveel queries/sec?

---

### 6.3 Backup & Disaster Recovery

**✅ Beslissing: Velero voor Kubernetes backup + database native backup**

**[❓ QUESTION 28]**: Disaster recovery testing frequency?
- Maandelijks, per kwartaal, of ad-hoc?

**[❓ QUESTION 29]**: Backup encryption?
- At-rest encryption in S3-compatible storage?

---

### 6.4 Caching Layer

**✅ Beslissing: Valkey (Redis fork)**

**[❓ QUESTION 30]**: Huidige sessie management?
- Sessies in application memory (problematisch voor horizontale scaling)?

---

## 7. Application Migration Readiness

### 7.1 Applicatie Architectuur Validatie

**[❓ QUESTION 31]**: Is de applicatie stateless?
- [ ] Sessies worden opgeslagen in database/Redis
- [ ] Geen lokale file uploads
- [ ] Geen shared filesystem dependencies

**[❓ QUESTION 32]**: Kan de applicatie horizontaal schalen?

**[❓ QUESTION 33]**: Zijn er hardcoded localhost/IP afhankelijkheden?

**[❓ QUESTION 34]**: Health check endpoints?
- [ ] `/health` endpoint (liveness probe)
- [ ] `/ready` endpoint (readiness probe)

---

### 7.2 Database Migration Strategie

**[❓ QUESTION 35]**: Database migratie aanpak?
- **Optie A**: Lift & shift (database blijft externe VM)
- **Optie B**: Database migreert naar managed cloud database
- **Optie C**: Phased approach

**[❓ QUESTION 36]**: Schema migrations backward compatible?

---

### 7.3 External Dependencies

**[❓ QUESTION 37]**: Welke externe APIs worden gebruikt?
- Payment providers, shipping APIs, email services?

**[❓ QUESTION 38]**: Outbound IP whitelisting requirements?

---

## 8. Team Workflow & Operationeel Model

### 8.1 Deployment Workflow

**[❓ QUESTION 39]**: Deployment approval proces?
- Auto-deploy naar dev/staging, manual approval voor production?

**[❓ QUESTION 40]**: Hotfix proces?

---

### 8.2 Monitoring & Alerting Ownership

**[❓ QUESTION 41]**: On-call rotatie?

---

### 8.3 Training & Onboarding

**[❓ QUESTION 42]**: Externe consultant nodig?

---

## 9. Cost Estimation

**[❓ QUESTION 43]**: Huidige maandelijkse infrastructuur kosten?

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
- [ ] Health checks implementatie
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

| Criterium | Layer 0 Doel | Layer 1 Implementatie | Validatie |
|-----------|-------------|---------------------|-----------|
| **Deployment downtime** | 0 minuten | Rolling updates + readiness probes | Deploy tijdens business hours |
| **Incident detectie** | < 2 minuten | Prometheus alerts + UptimeRobot | Simulate failure |
| **Data recovery** | Point-in-time (max 15 min verlies) | Managed DB PITR + Velero | Quarterly DR drill |
| **Vendor migration** | < 1 kwartaal | Terraform IaC + open-source stack | Annual portability review |
| **Developer self-service** | Deploy via Git PR | Argo CD + GitHub Actions | Developers kunnen zonder Ops deployen |

---

## 12. Open Questions Samenvatting

**Kritisch voor implementatie start** (MOET beantwoord worden):
- [❓ Q1] Welke managed Kubernetes provider?
- [❓ Q5] Resource requirements (CPU/memory)?
- [❓ Q26] Huidige database (MySQL/PostgreSQL/SQL Server)?
- [❓ Q31-34] Applicatie stateless? Health checks aanwezig?
- [❓ Q43-44] Budget goedkeuring?

**Belangrijk maar niet blokkeerend**:
- [❓ Q10] Git branching strategy
- [❓ Q14] Business metrics
- [❓ Q18] Identity provider (OIDC)
- [❓ Q39] Deployment approval proces

**Kan later besloten worden**:
- [❓ Q7] Hubble UI exposen?
- [❓ Q12] Self-hosted CI runners?
- [❓ Q42] Externe consultant?

---

## 13. Volgende Stappen: Van Layer 1 naar Layer 2

Na implementatie van Layer 1 (eerste 4-6 maanden), kan Layer 2 (enhancement) overwogen worden:

### Layer 2 Mogelijkheden (Optioneel)
- **Service mesh** (Istio/Linkerd) - als microservices architectuur
- **Distributed tracing** (Jaeger/Tempo) - voor performance debugging
- **Chaos engineering** (Chaos Mesh) - voor resilience testing
- **Policy enforcement** (OPA/Kyverno) - voor compliance automation
- **Cost optimization** (Kubecost) - voor chargeback/showback
- **Multi-region** (Cilium Cluster Mesh) - voor latency verbetering

---

## 14. Referenties

**KubeCompass Framework**:
- **[FRAMEWORK.md](FRAMEWORK.md)**: Decision layers uitleg
- **[MATRIX.md](MATRIX.md)**: Tool recommendations met scoring
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
**Eigenaar**: Platform Team / Lead Architect  
**Review Cyclus**: Na beantwoording van kritieke vragen (Q1, Q5, Q26, Q31-34, Q43-44)  
**Volgende Fase**: Layer 2 (enhancement) na 6 maanden productie stabiliteit  

---

**Layer 1 Document Versie**: 1.0  
**Gebaseerd op**: Layer 0 v2.0 (LAYER_0_WEBSHOP_CASE.md)  
**Laatste Update**: December 2024  
**Licentie**: MIT — vrij te gebruiken en aan te passen
