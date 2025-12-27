# Layer 0 → Layer 1 Mapping: Webshop Migratiecase

**Doelgroep**: Architecten, Decision Makers, AI Agents  
**Doel**: Traceerbaarheid van alle Layer 1 beslissingen naar Layer 0 principes  
**Status**: Audit-proof decision framework  

---

## Executive Summary

Dit document toont de **volledige traceerbaarheid** tussen Layer 0 requirements en Layer 1 implementatiekeuzes. Elke Layer 1 beslissing is direct terug te leiden naar één of meerdere Layer 0 principes, constraints of requirements.

**Kernprincipe**: Geen technische keuze zonder business/architectuur rationale.

---

## 1. Zero-Downtime Deployments

### Layer 0 Requirement
- **Primair Doel**: Eliminate Deployment Downtime (Section 2: Beschikbaarheid)
- **Business Impact**: Downtime = direct omzetverlies tijdens checkout
- **Huidige Pijnpunt**: 1-4 uur downtime per release (alleen maandagnacht)
- **Target**: 0 minuten deployment downtime (rolling updates)

### Layer 1 Implementatie
| Capability | Tool/Techniek | Rationale |
|-----------|---------------|-----------|
| **Rolling Updates** | Kubernetes Deployments | Native K8s capability, zero additional complexity |
| **Health Checks** | Readiness/Liveness Probes | Prevent traffic to unhealthy pods during rollout |
| **GitOps Deployment** | Argo CD | Declarative deployments, rollback capability via Git |
| **Load Balancing** | NGINX Ingress Controller | Distribute traffic across healthy replicas during update |

### Dependency Chain
```
Business Requirement (no downtime)
  → Technical Requirement (rolling updates)
    → Platform Capability (Kubernetes Deployments + Health Checks)
      → Tooling Choice (Argo CD for orchestration, NGINX for LB)
```

---

## 2. Proactive Monitoring

### Layer 0 Requirement
- **Primair Doel**: Proactive Operations (Section 5: Observability)
- **Huidige Pijnpunt**: Reactieve incident detectie (klanten bellen)
- **Target**: < 2 minuten incident detectie via alerts
- **Stakeholders**: Dev, Ops, Support (ieder eigen dashboards)

### Layer 1 Implementatie
| Capability | Tool/Techniek | Rationale |
|-----------|---------------|-----------|
| **Metrics** | Prometheus | Open-source, vendor independence, CNCF graduated |
| **Dashboards** | Grafana | Self-service voor teams, integratie met Prometheus |
| **Alerting** | Alertmanager | Actionable alerts, routing naar PagerDuty/Slack |
| **Logging** | Grafana Loki | Label-based queries, Prometheus-compatible, low cost |
| **Uptime Monitoring** | UptimeRobot + Blackbox Exporter | External perspective + internal monitoring |

### Dependency Chain
```
Business Requirement (detect before customers notice)
  → Technical Requirement (proactive alerting)
    → Platform Capability (metrics, logs, external monitoring)
      → Tooling Choice (Prometheus/Grafana stack, open-source)
```

### Layer 0 Constraint Impact
- **Budget Realisme** → Open-source tools (Prometheus/Grafana) vs. SaaS (Datadog/New Relic)
- **Team Maturity** → Start simpel (metrics + logs), geen distributed tracing (Layer 2)
- **Vendor Independence** → Self-hosted observability stack

---

## 3. Data Resilience & Recovery

### Layer 0 Requirement
- **Primair Doel**: Data Protection & Recovery (Section 3: Data-Kritikaliteit)
- **Huidige Pijnpunt**: Nachtelijke backups, geen point-in-time recovery
- **Target**: RPO 15 minuten (orders), RTO 30 minuten (kritieke systemen)
- **Compliance**: GDPR (data residency EU, encryption at rest)

### Layer 1 Implementatie
| Capability | Tool/Techniek | Rationale |
|-----------|---------------|-----------|
| **Cluster Backup** | Velero | Kubernetes-native, S3-compatible storage, namespace-scoped |
| **Database Strategy** | Managed PostgreSQL (cloud provider) | HA out-of-box, PITR native capability, reduces operational burden |
| **Backup Storage** | S3-compatible object storage (EU region) | Vendor independence, GDPR compliant |
| **Backup Encryption** | At-rest encryption (cloud KMS) | GDPR compliance, secure key management |

### Dependency Chain
```
Business Requirement (no transaction loss)
  → Technical Requirement (point-in-time recovery)
    → Platform Capability (automated backups, database replication)
      → Tooling Choice (Velero for K8s, managed DB with PITR)
```

### Trade-off Analysis
**Managed Database vs. StatefulSet**
- **Keuze**: Managed PostgreSQL
- **Layer 0 Conflicts**:
  - ✅ **Data Resilience** (higher priority) → HA, PITR, automated backups
  - ⚠️ **Vendor Independence** (lower priority for database) → Migration path exists via pg_dump
- **Rationale**: Team maturity (geen database HA expertise) + critical data (business impact > portability concerns)

---

## 4. Vendor Independence

### Layer 0 Requirement
- **Hard Constraint**: Migratie naar andere provider binnen 1 kwartaal mogelijk (Section 7)
- **Principe**: Open-source voorkeur, cloud-agnostic architectuur
- **Validatie**: Infrastructure as Code moet reproduceerbaar zijn

### Layer 1 Implementatie
| Capability | Tool/Techniek | Rationale |
|-----------|---------------|-----------|
| **Compute** | Managed Kubernetes (niet cloud-specific ECS/AKS/EKS) | Standaard K8s API, reproduceerbaar overal |
| **CNI** | Cilium | CNCF graduated, cloud-agnostic, geen vendor lock-in |
| **GitOps** | Argo CD | Open-source, self-hosted, geen vendor SaaS |
| **Observability** | Prometheus/Grafana/Loki | Open-source stack, geen SaaS dependency |
| **Container Registry** | Harbor (self-hosted) | Vendor independence, image scanning included |
| **IaC** | Terraform | Multi-cloud support, reproducible infrastructure |

### Dependency Chain
```
Business Constraint (1 kwartaal migratie tijd)
  → Technical Requirement (cloud-agnostic tooling)
    → Platform Capability (open-source, standardized APIs)
      → Tooling Choice (CNCF projects, Terraform IaC)
```

### Portability Validation Checklist
- [ ] Kubernetes API is standaard (geen cloud-specific CRDs)
- [ ] CNI is cloud-agnostic (Cilium werkt op elke K8s distributie)
- [ ] Storage is S3-compatible (niet AWS S3-only APIs)
- [ ] IaC is reproduceerbaar (Terraform modules voor andere clouds)
- [ ] Secrets management heeft export capability (Vault backup/restore)

---

## 5. Security by Design

### Layer 0 Requirement
- **Principe**: Least Privilege, Defense in Depth, Encryption (Section 4: Security Baseline)
- **Constraint**: Developers geen productie toegang (compliance)
- **Requirement**: Secrets nooit in Git, encryption at rest/in transit

### Layer 1 Implementatie
| Capability | Tool/Techniek | Rationale |
|-----------|---------------|-----------|
| **Secrets Management** | Vault + External Secrets Operator | Centralized secrets, rotation, no secrets in Git |
| **RBAC** | Kubernetes RBAC + OIDC | Namespace-scoped access, no cluster-admin for devs |
| **Network Security** | Cilium Network Policies | L3/L4 + L7 policies, deny-all default |
| **Image Security** | Trivy (CI/CD) + Harbor Scanning | CVE detection before deployment |
| **Pod Security** | Pod Security Standards (restricted) | No privileged containers, seccomp enabled |
| **TLS** | cert-manager + Let's Encrypt | Automated certificate lifecycle, TLS everywhere |

### Dependency Chain
```
Business Constraint (no developer prod access)
  → Technical Requirement (GitOps-only deployments, RBAC)
    → Platform Capability (secrets management, network policies)
      → Tooling Choice (Vault, External Secrets, Cilium, Trivy)
```

### Layer 0 Principle Mapping
| Layer 0 Principe | Layer 1 Implementation |
|-----------------|----------------------|
| **Least Privilege** | RBAC (namespace-scoped), service accounts (minimal permissions) |
| **Defense in Depth** | Network policies + pod security + image scanning + secrets management |
| **Encryption** | TLS (ingress) + at-rest (backups, secrets) + in-transit (mTLS optioneel Layer 2) |
| **Audit Trail** | GitOps (all changes in Git), Kubernetes audit logs |

---

## 6. GitOps vanaf Dag 1

### Layer 0 Requirement
- **Principe**: GitOps is Layer 0 principe (Section 8.4)
- **Rationale**: Audit trail, rollback capability, self-service deployments
- **Constraint**: No kubectl apply handmatig (security + reproducibility)

### Layer 1 Implementatie
| Capability | Tool/Techniek | Rationale |
|-----------|---------------|-----------|
| **GitOps Engine** | Argo CD | UI voor Support/Management, SSO, RBAC, audit trail |
| **Git Repository** | Git (mono-repo of multi-repo) | Single source of truth |
| **CI/CD Pipeline** | GitHub Actions | Container builds, image scanning, Git tagging |
| **Branching Strategy** | TBD (trunk-based vs GitFlow) | Afhankelijk van SAFe proces mapping |

### Dependency Chain
```
Business Requirement (audit trail, compliance)
  → Technical Requirement (all deployments via Git)
    → Platform Capability (declarative deployments, sync automation)
      → Tooling Choice (Argo CD with RBAC/SSO)
```

### "Use Argo CD unless"
- Je wilt GitOps-pure zonder UI → Flux
- Je hebt complexe Helm + image automation → Flux heeft sterkere Helm support
- Je wilt minimale footprint → Flux is lighter-weight

**Keuze Argo CD vanwege**:
- UI requirement (Support team moet deployment status zien zonder kubectl)
- SSO/RBAC native (Layer 0 security requirement)
- Audit trail out-of-box (compliance requirement)

---

## 7. Shared Responsibility Model

### Layer 0 Requirement
- **Principe**: Dev + Ops samenwerking, niet "alles naar Ops" (Section 6: Ownership)
- **Ownership Model**: Self-service voor Dev, Ops faciliteert platform
- **Stakeholders**: Dev, Ops, Support (duidelijke escalatie paden)

### Layer 1 Implementatie
| Responsibility | Owner | Layer 1 Tool Support |
|----------------|-------|---------------------|
| **Code Quality** | Dev | CI/CD (GitHub Actions), image scanning (Trivy) |
| **Deployment** | Dev (trigger) | GitOps (Argo CD) - dev submits PR, Ops approves |
| **Platform** | Ops | Terraform (IaC), cluster management, guardrails |
| **Monitoring** | Dev (app metrics) + Ops (platform metrics) | Prometheus (both), Grafana (shared dashboards) |
| **Incident Response** | Dev (app) + Ops (platform) | Alertmanager routing, on-call rotations |
| **Read-only Access** | Support | Grafana dashboards (no kubectl, no cluster access) |

### Dependency Chain
```
Business Requirement (clear ownership, no bottlenecks)
  → Technical Requirement (self-service, guardrails)
    → Platform Capability (GitOps, observability, RBAC)
      → Tooling Choice (Argo CD, Prometheus, RBAC policies)
```

---

## 8. Team Maturity & Operational Simplicity

### Layer 0 Constraint
- **Team Constraint**: No Kubernetes ervaring (Section "Harde Randvoorwaarden")
- **Implication**: Start simpel, managed services voorkeur, training nodig
- **Validatie**: Platform moet opereerbaar zijn voor team van ~10 mensen

### Layer 1 Implementatie
| Decision | Choice | Rationale (Team Maturity) |
|----------|--------|--------------------------|
| **Kubernetes** | Managed K8s (Nederlandse provider) | Reduce operational burden, control plane managed |
| **Database** | Managed PostgreSQL | No StatefulSet complexity, HA out-of-box |
| **Observability** | Prometheus/Grafana (populair, grote community) | Veel documentatie, community support |
| **CNI** | Cilium (eBPF, moderne tech) | Investment in future, maar training nodig |
| **Service Mesh** | Geen (Layer 2) | Te complex voor team zonder K8s ervaring |
| **Distributed Tracing** | Geen (Layer 2) | Start met metrics/logs, tracing later |

### Dependency Chain
```
Team Constraint (no K8s experience)
  → Technical Requirement (managed services, simple tooling)
    → Platform Capability (reduce operational overhead)
      → Tooling Choice (managed K8s, managed DB, standard CNCF tools)
```

### Layer 0 Trade-off
**Managed vs. Self-hosted**
- **Managed K8s**: ✅ Lower ops burden → **Team maturity constraint**
- **Self-hosted K8s**: ❌ Higher control → Conflicts with **team capabilities**
- **Keuze**: Managed K8s prioriteert team maturity boven absolute control

---

## 9. Budget & Cost Constraints

### Layer 0 Constraint
- **Budget Realisme**: Geen enterprise SaaS budgets (Section "Harde Randvoorwaarden")
- **Implication**: Open-source tooling voorkeur
- **Validatie**: Cost monitoring vanaf dag 1

### Layer 1 Implementatie
| Capability | Tool/Techniek | Cost Consideration |
|-----------|---------------|-------------------|
| **Observability** | Prometheus/Grafana/Loki (open-source) | Free vs. Datadog/New Relic ($$$) |
| **Container Registry** | Harbor (self-hosted) | Free vs. Quay.io/Docker Hub (paid tiers) |
| **Secrets Management** | Vault (self-hosted) | Free vs. AWS Secrets Manager/Azure Key Vault ($) |
| **GitOps** | Argo CD (self-hosted) | Free vs. GitLab Ultimate/GitHub Enterprise ($) |
| **Cost Monitoring** | OpenCost / Kubecost (open-source tier) | Visibility without cost |

### Dependency Chain
```
Budget Constraint (no enterprise SaaS)
  → Technical Requirement (self-hosted, open-source)
    → Platform Capability (manage tooling ourselves)
      → Tooling Choice (CNCF projects, community support)
```

### Trade-off: Self-hosted vs. Managed Tooling
**Self-hosted**: ✅ Lower cost, vendor independence ❌ Higher operational burden  
**Managed SaaS**: ✅ Lower ops burden ❌ Higher cost, vendor lock-in  
**Keuze**: Self-hosted prioritizes budget constraint over operational simplicity

---

## 10. Multi-Region Readiness (Toekomst)

### Layer 0 Non-Goal
- **Expliciete Non-Goal**: Multi-region deployment (Section "Non-Goals")
- **Rationale**: Te complex voor team zonder K8s ervaring
- **Architectuur Requirement**: Wel multi-region mogelijk maken (niet blokkeren)

### Layer 1 Implementatie
| Decision | Choice | Multi-Region Readiness |
|----------|--------|----------------------|
| **CNI** | Cilium | ✅ Cluster Mesh capability (Layer 2) |
| **GitOps** | Argo CD | ✅ Multi-cluster support |
| **Observability** | Prometheus/Grafana | ✅ Federation possible |
| **Database** | Managed PostgreSQL | ⚠️ Read replicas cross-region (provider dependent) |

### Dependency Chain
```
Business Non-Goal (no multi-region now)
  → Technical Requirement (don't block future multi-region)
    → Platform Capability (select multi-region capable tools)
      → Tooling Choice (Cilium, Argo CD - multi-cluster ready)
```

---

## 11. Compliance & Audit Requirements

### Layer 0 Requirement
- **Compliance**: GDPR (data residency EU, encryption, audit logging)
- **Audit Trail**: Wie deed wat wanneer (GitOps!)
- **Retention**: Audit logs voor minimaal 1 jaar

### Layer 1 Implementatie
| Requirement | Implementation | Audit Capability |
|------------|----------------|-----------------|
| **Data Residency** | EU datacenter, EU backup storage | Infrastructure location validation |
| **Encryption at Rest** | Cloud KMS (backups), database encryption | Key management audit trail |
| **Encryption in Transit** | TLS (ingress), optional mTLS (service mesh Layer 2) | Certificate lifecycle logs |
| **Change Audit** | GitOps (all changes in Git) | Git commit history = audit log |
| **Access Audit** | Kubernetes audit logs + OIDC | Who accessed what when |

### Dependency Chain
```
Compliance Requirement (GDPR)
  → Technical Requirement (data residency, encryption, audit logs)
    → Platform Capability (EU infrastructure, GitOps, K8s audit)
      → Tooling Choice (EU provider, Argo CD, OIDC integration)
```

---

## 12. Decision Rules Summary ("Choose X unless Y")

### CNI Plugin
**Use Cilium unless**:
- Je hebt al Calico expertise in-house en wilt niet investeren in Cilium learning curve
- Je hebt BGP routing requirements (Calico is sterker in BGP)
- Je wilt absoluut simpelste setup (Flannel, maar mist veel features)

**Layer 0 Rationale**: Network policies (security), performance (eBPF), multi-region ready (toekomst)

---

### GitOps Tool
**Use Argo CD unless**:
- Je wilt GitOps-pure zonder UI → Flux
- Je hebt complexe Helm + image automation → Flux heeft sterkere Helm support
- Je wilt minimale footprint → Flux is lighter-weight

**Layer 0 Rationale**: Audit trail (compliance), UI voor Support, self-service deployments

---

### Observability Stack
**Use Prometheus + Grafana + Loki unless**:
- Je hebt enterprise SaaS budget → Datadog/New Relic (minder operationele overhead)
- Je wilt vendor-managed → Cloud provider observability (CloudWatch, Azure Monitor)

**Layer 0 Rationale**: Budget constraint (open-source), vendor independence, team maturity (grote community)

---

### Secrets Management
**Use Vault + External Secrets Operator unless**:
- Je bent all-in op cloud provider → Cloud KMS + External Secrets (AWS Secrets Manager, Azure Key Vault)
- Je wilt absolute simpelheid → Sealed Secrets (maar geen centralized management)

**Layer 0 Rationale**: No secrets in Git, vendor independence (Vault is portable), rotation capability

---

### Database Strategy
**Use Managed PostgreSQL unless**:
- Je hebt database HA expertise in-house → StatefulSet + Postgres Operator
- Vendor independence is absolute requirement → StatefulSet (maar hogere operationele last)

**Layer 0 Rationale**: Team maturity (geen DB HA expertise), data resilience (PITR, HA native), pragmatisme (business impact > portability voor database)

---

### Container Registry
**Use Harbor (self-hosted) unless**:
- Je hebt geen capaciteit voor registry operations → Cloud provider registry (ECR, ACR, GCR)
- Je wilt vendor SaaS → Quay.io, Docker Hub (paid tiers)

**Layer 0 Rationale**: Vendor independence, budget (self-hosted is free), image scanning included

---

### Ingress Controller
**Use NGINX Ingress Controller unless**:
- Je wilt dynamische configuratie zonder restarts → Traefik
- Je bent all-in op Envoy ecosystem → Contour, Istio Gateway

**Layer 0 Rationale**: Maturity (meest gebruikt), cloud-agnostic (portability), feature set (SSL, rate limiting)

---

### Infrastructure as Code
**Use Terraform unless**:
- Je wilt moderne taal (TypeScript/Python) → Pulumi
- Je wilt Kubernetes-native orchestratie → Crossplane (maar veel complexer)

**Layer 0 Rationale**: Vendor independence (multi-cloud), maturity (stabiele providers), community support

---

## 13. Critical Open Questions Impact Analysis

### Q1: Welke Managed Kubernetes Provider?
**Layer 0 Impact**: 
- **Vendor Independence** → Provider moet Terraform support hebben
- **Data Sovereignty** → EU datacenter vereist
- **Team Maturity** → Support kwaliteit is kritisch

**Blokkerende Beslissing**: Ja (kan niet starten zonder provider keuze)

---

### Q5: Resource Requirements?
**Layer 0 Impact**:
- **Budget** → Node sizing bepaalt maandelijkse kosten
- **Beschikbaarheid** → Bepaalt aantal nodes voor HA

**Blokkerende Beslissing**: Ja (sizing is essentieel voor cluster provisioning)

---

### Q10: Git Branching Strategy?
**Layer 0 Impact**:
- **GitOps Principe** → Moet passen bij Essential SAFe proces
- **Ownership Model** → Bepaalt approval workflows

**Blokkerende Beslissing**: Nee (kan later verfijnd worden, start met simpele trunk-based)

---

### Q26: Huidige Database?
**Layer 0 Impact**:
- **Data Resilience** → Migratie complexiteit
- **Vendor Independence** → Managed DB keuze (PostgreSQL, MySQL, etc.)

**Blokkerende Beslissing**: Ja (bepaalt migratie strategie)

---

### Q31-34: Applicatie Stateless? Health Checks?
**Layer 0 Impact**:
- **Zero-Downtime Deployments** → Vereist stateless applicatie
- **High Availability** → Vereist horizontale scaling

**Blokkerende Beslissing**: Ja (fundamentele requirement voor rolling updates)

---

## 14. Consistency Validation

### ✅ Alle Layer 1 Keuzes Traceerbaar
Elke tool keuze in Layer 1 heeft:
- Duidelijke Layer 0 requirement mapping
- Rationale based on constraints (team, budget, vendor independence)
- "Use X unless Y" decision rule
- Alternative consideration (waarom niet tool Y?)

### ✅ Geen Tool Keuzes Zonder Rationale
Alle tools in Layer 1 hebben:
- Business/technical requirement
- Layer 0 principle alignment
- Trade-off analysis

### ✅ Trade-offs Zijn Expliciet
Waar Layer 0 principes conflicteren:
- Managed DB (team maturity) vs. StatefulSet (vendor independence)
- Resolution: Team maturity > vendor independence **voor database**
- Rationale: Business impact (data resilience) + team capability

---

## 15. Voor Interactieve Site: Decision Tree Inputs

### User Input Variables
```json
{
  "team_size": "number",
  "kubernetes_experience": "none|basic|intermediate|expert",
  "budget_constraint": "low|medium|high",
  "vendor_independence_priority": "low|medium|high",
  "compliance_requirements": ["GDPR", "PCI-DSS", "SOC2", "none"],
  "team_maturity": "none|learning|experienced",
  "deployment_frequency": "weekly|daily|multiple_daily",
  "service_count": "1|2-5|5-10|10+",
  "downtime_tolerance": "none|minutes|hours",
  "data_criticality": "low|medium|high"
}
```

### Decision Logic Examples
```javascript
// CNI Decision
if (network_policies_required && vendor_independence === "high") {
  if (team_experience === "none" && budget === "low") {
    recommend("Cilium", "eBPF performance + multi-region ready, maar training nodig");
    alternative("Calico", "Simpeler maar iptables-based, als team geen capaciteit heeft");
  }
}

// Database Decision
if (data_criticality === "high" && team_maturity === "none") {
  recommend("Managed PostgreSQL", "HA + PITR out-of-box, team heeft geen DB expertise");
  tradeoff("Vendor lock-in risk, maar business impact > portability voor database");
  alternative("StatefulSet + Operator", "Alleen als team DB HA expertise heeft");
}

// GitOps Decision
if (audit_trail_required || self_service_required) {
  recommend("Argo CD", "UI + RBAC + audit trail");
  alternative("Flux", "Als je GitOps-pure zonder UI wilt");
}
```

---

## 16. Samenvatting: Traceability Matrix

| Layer 0 Requirement | Layer 1 Implementation | Tool Choice | Critical Open Question |
|---------------------|----------------------|-------------|----------------------|
| Zero-downtime deployments | Rolling updates + health checks | Kubernetes Deployments, Argo CD, NGINX | Q31-34 (app stateless?) |
| Proactive monitoring | Metrics + logs + alerts | Prometheus, Grafana, Loki, Alertmanager | Q14 (business metrics?) |
| Data resilience | PITR + HA database | Managed PostgreSQL, Velero | Q26 (current DB?), Q27 (size?) |
| Vendor independence | Open-source stack + IaC | Cilium, Argo CD, Prometheus, Terraform | Q1 (K8s provider?) |
| Security by design | Secrets mgmt + RBAC + network policies | Vault, External Secrets, Cilium, RBAC | Q18 (IdP?), Q20 (Vault unsealing?) |
| GitOps vanaf dag 1 | Declarative deployments | Argo CD, GitHub Actions | Q10 (branching strategy?) |
| Team maturity | Managed services + simple tooling | Managed K8s, Managed DB | Q15 (Ops FTE?), Q42 (consultant?) |
| Budget constraint | Open-source voorkeur | Self-hosted stack (Harbor, Vault, etc.) | Q43 (current costs?), Q44 (budget approval?) |

---

**Document Eigenaar**: Platform Architect / Decision Board  
**Update Frequentie**: Bij elke wijziging in Layer 0 requirements of Layer 1 keuzes  
**Audit Status**: ✅ Alle beslissingen traceerbaar naar Layer 0  
**Geschiktheid Interactieve Site**: ✅ Decision logic extractable, input variables defined  

---

**Versie**: 1.0  
**Datum**: December 2024  
**Licentie**: MIT
