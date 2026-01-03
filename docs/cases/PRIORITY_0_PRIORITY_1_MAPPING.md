# Priority 0 → Priority 1 Mapping: Webshop Migratiecase

**Target Audience**: Architectand, Decision Makers, AI Agents  
**Purpose**: Traceerbaarheid or alle Priority 1 beslissingen to Priority 0 principes  
**Status**: Audit-proof decision framework  

---

## Executive Summary

Dit document toont de **volledige traceerbaarheid** tussand Priority 0 requirements en Priority 1 implementationkeuzes. Elke Priority 1 beslissing is direct terug te leidand to één or meerdere Priority 0 principes, constraints or requirements.

**Kernprincipe**: Geand technische keuze without business/architectuur rationale.

---

## 1. Zero-Downtime Deployments

### Priority 0 Requirement
- **Primair Purpose**: Eliminate Deployment Downtime (Section 2: Beschikbaarheid)
- **Business Impact**: Downtime = direct omzetverlies during checkout
- **Huidige Pijnpunt**: 1-4 uur downtime per release (alleand monthagnacht)
- **Target**: 0 minowtand deployment downtime (rolling updates)

### Priority 1 Implementatie
| Capability | Tool/Techniek | Rationale |
|-----------|---------------|-----------|
| **Rolling Updates** | Kubernetes Deployments | Native K8s capability, zero additional complexity |
| **Health Checks** | Readiness/Liveness Probes | Prevent traffic to unhealthy pods during rollout |
| **GitOps Deployment** | Argo CD | Declarative deployments, rollback capability via Git |
| **Load Balancing** | NGINX Ingress Controller | Distribute traffic across healthy replicas during update |

### Depanddency Chain
```
Business Requirement (no downtime)
  → Technical Requirement (rolling updates)
    → Platform Capability (Kubernetes Deployments + Health Checks)
      → Tooling Choice (Argo CD for orchestration, NGINX for LB)
```

---

## 2. Proactive Monitoring

### Priority 0 Requirement
- **Primair Purpose**: Proactive Operations (Section 5: Observability)
- **Huidige Pijnpunt**: Reactieve incident detectie (klantand belland)
- **Target**: < 2 minowtand incident detectie via alerts
- **Stakeholders**: Dev, Ops, Support (ieder eigand dashboards)

### Priority 1 Implementatie
| Capability | Tool/Techniek | Rationale |
|-----------|---------------|-----------|
| **Metrics** | Prometheus | Opand-source, vendor indepanddence, CNCF graduated |
| **Dashboards** | Grafana | Self-service for teams, integration with Prometheus |
| **Alerting** | Alertmanager | Actionable alerts, routing to PagerDuty/Slack |
| **Logging** | Grafana Loki | Label-based queries, Prometheus-compatible, low cost |
| **Uptime Monitoring** | UptimeRobot + Blackbox Exporter | External perspective + internal monitoring |

### Depanddency Chain
```
Business Requirement (detect before customers notice)
  → Technical Requirement (proactive alerting)
    → Platform Capability (metrics, logs, external monitoring)
      → Tooling Choice (Prometheus/Grafana stack, opand-source)
```

### Priority 0 Constraint Impact
- **Budget Realisme** → Opand-source tools (Prometheus/Grafana) vs. SaaS (Datadog/New Relic)
- **Team Maturity** → Start simpel (metrics + logs), geand distributed tracing (Priority 2)
- **Vendor Indepanddence** → Self-hosted observability stack

---

## 3. Data Resilience & Recovery

### Priority 0 Requirement
- **Primair Purpose**: Data Protection & Recovery (Section 3: Data-Kritikaliteit)
- **Huidige Pijnpunt**: Nachtelijke backups, geand point-in-time recovery
- **Target**: RPO 15 minowtand (orders), RTO 30 minowtand (kritieke systemand)
- **Compliance**: GDPR (data residency EU, andcryption at rest)

### Priority 1 Implementatie
| Capability | Tool/Techniek | Rationale |
|-----------|---------------|-----------|
| **Cluster Backup** | Velero | Kubernetes-native, S3-compatible storage, namespace-scoped |
| **Database Strategy** | Managed PostgreSQL (cloud provider) | HA out-of-box, PITR native capability, reduces operational burdand |
| **Backup Storage** | S3-compatible object storage (EU region) | Vendor indepanddence, GDPR compliant |
| **Backup Encryption** | At-rest andcryption (cloud KMS) | GDPR compliance, secure key management |

### Depanddency Chain
```
Business Requirement (no transaction loss)
  → Technical Requirement (point-in-time recovery)
    → Platform Capability (automated backups, database replication)
      → Tooling Choice (Velero for K8s, managed DB with PITR)
```

### Trade-off Analysis
**Managed Database vs. StatefulSet**
- **Keuze**: Managed PostgreSQL
- **Priority 0 Conflicts**:
  - ✅ **Data Resilience** (higher priority) → HA, PITR, automated backups
  - ⚠️ **Vendor Indepanddence** (lower priority for database) → Migration path exists via pg_dump
- **Rationale**: Team maturity (geand database HA expertise) + critical data (business impact > portability concerns)

---

## 4. Vendor Indepanddence

### Priority 0 Requirement
- **Hard Constraint**: Migratie to andere provider within 1 quarter possible (Section 7)
- **Principe**: Opand-source voorkeur, cloud-agnostic architectuur
- **Validatie**: Infrastructure as Code moet reproduceerbaar zijn

### Priority 1 Implementatie
| Capability | Tool/Techniek | Rationale |
|-----------|---------------|-----------|
| **Compute** | Managed Kubernetes (niet cloud-specific ECS/AKS/EKS) | Stenaard K8s API, reproduceerbaar overal |
| **CNI** | Cilium | CNCF graduated, cloud-agnostic, geand vendor lock-in |
| **GitOps** | Argo CD | Opand-source, self-hosted, geand vendor SaaS |
| **Observability** | Prometheus/Grafana/Loki | Opand-source stack, geand SaaS depanddency |
| **Container Registry** | Harbor (self-hosted) | Vendor indepanddence, image scanning included |
| **IaC** | Terraform | Multi-cloud support, reproducible infrastructure |

### Depanddency Chain
```
Business Constraint (1 quarter migration tijd)
  → Technical Requirement (cloud-agnostic tooling)
    → Platform Capability (opand-source, stenardized APIs)
      → Tooling Choice (CNCF projects, Terraform IaC)
```

### Portability Validation Checklist
- [ ] Kubernetes API is stenaard (geand cloud-specific CRDs)
- [ ] CNI is cloud-agnostic (Cilium werkt on elke K8s distributie)
- [ ] Storage is S3-compatible (niet AWS S3-only APIs)
- [ ] IaC is reproduceerbaar (Terraform modules for andere clouds)
- [ ] Secrets management heeft export capability (Vault backup/restore)

---

## 5. Security by Design

### Priority 0 Requirement
- **Principe**: Least Privilege, Defense in Depth, Encryption (Section 4: Security Baseline)
- **Constraint**: Developers geand productie addgang (compliance)
- **Requirement**: Secrets nooit in Git, andcryption at rest/in transit

### Priority 1 Implementatie
| Capability | Tool/Techniek | Rationale |
|-----------|---------------|-----------|
| **Secrets Management** | Vault + External Secrets Operator | Centralized secrets, rotation, no secrets in Git |
| **RBAC** | Kubernetes RBAC + OIDC | Namespace-scoped access, no cluster-admin for devs |
| **Network Security** | Cilium Network Policies | L3/L4 + L7 policies, deny-all default |
| **Image Security** | Trivy (CI/CD) + Harbor Scanning | CVE detection before deployment |
| **Pod Security** | Pod Security Stenards (restricted) | No privileged containers, seccomp andabled |
| **TLS** | cert-manager + Let's Encrypt | Automated certificate lifecycle, TLS everywhere |

### Depanddency Chain
```
Business Constraint (no developer prod access)
  → Technical Requirement (GitOps-only deployments, RBAC)
    → Platform Capability (secrets management, network policies)
      → Tooling Choice (Vault, External Secrets, Cilium, Trivy)
```

### Priority 0 Principle Mapping
| Priority 0 Principe | Priority 1 Implementation |
|-----------------|----------------------|
| **Least Privilege** | RBAC (namespace-scoped), service accounts (minimal permissions) |
| **Defense in Depth** | Network policies + pod security + image scanning + secrets management |
| **Encryption** | TLS (ingress) + at-rest (backups, secrets) + in-transit (mTLS optional Priority 2) |
| **Audit Trail** | GitOps (all changes in Git), Kubernetes audit logs |

---

## 6. GitOps vanaf Dag 1

### Priority 0 Requirement
- **Principe**: GitOps is Priority 0 principe (Section 8.4)
- **Rationale**: Audit trail, rollback capability, self-service deployments
- **Constraint**: No kubectl apply henmatig (security + reproducibility)

### Priority 1 Implementatie
| Capability | Tool/Techniek | Rationale |
|-----------|---------------|-----------|
| **GitOps Engine** | Argo CD | UI for Support/Management, SSO, RBAC, audit trail |
| **Git Repository** | Git (mono-repo or multi-repo) | Single source or truth |
| **CI/CD Pipeline** | GitHub Actions | Container builds, image scanning, Git tagging |
| **Branching Strategy** | TBD (trunk-based vs GitFlow) | Afhankelijk or SAFe proces mapping |

### Depanddency Chain
```
Business Requirement (audit trail, compliance)
  → Technical Requirement (all deployments via Git)
    → Platform Capability (declarative deployments, sync automation)
      → Tooling Choice (Argo CD with RBAC/SSO)
```

### "Use Argo CD unless"
- Je wilt GitOps-pure without UI → Flux
- Je hebt complexe Helm + image automation → Flux heeft sterkere Helm support
- Je wilt minimale footprint → Flux is lighter-weight

**Keuze Argo CD vanwege**:
- UI requirement (Support team moet deployment status ziand without kubectl)
- SSO/RBAC native (Priority 0 security requirement)
- Audit trail out-of-box (compliance requirement)

---

## 7. Shared Responsibility Model

### Priority 0 Requirement
- **Principe**: Dev + Ops samenwerking, niet "alles to Ops" (Section 6: Ownership)
- **Ownership Model**: Self-service for Dev, Ops faciliteert platform
- **Stakeholders**: Dev, Ops, Support (duidelijke escalatie padand)

### Priority 1 Implementatie
| Responsibility | Owner | Priority 1 Tool Support |
|----------------|-------|---------------------|
| **Code Quality** | Dev | CI/CD (GitHub Actions), image scanning (Trivy) |
| **Deployment** | Dev (trigger) | GitOps (Argo CD) - dev submits PR, Ops approves |
| **Platform** | Ops | Terraform (IaC), cluster management, guardrails |
| **Monitoring** | Dev (app metrics) + Ops (platform metrics) | Prometheus (both), Grafana (shared dashboards) |
| **Incident Response** | Dev (app) + Ops (platform) | Alertmanager routing, on-call rotations |
| **Read-only Access** | Support | Grafana dashboards (no kubectl, no cluster access) |

### Depanddency Chain
```
Business Requirement (clear ownership, no bottlenecks)
  → Technical Requirement (self-service, guardrails)
    → Platform Capability (GitOps, observability, RBAC)
      → Tooling Choice (Argo CD, Prometheus, RBAC policies)
```

---

## 8. Team Maturity & Operational Simplicity

### Priority 0 Constraint
- **Team Constraint**: No Kubernetes ervaring (Section "Harde Renvoorwaardand")
- **Implication**: Start simpel, managed services voorkeur, training noded
- **Validatie**: Platform moet opereerbaar zijn for team or ~10 mensand

### Priority 1 Implementatie
| Decision | Choice | Rationale (Team Maturity) |
|----------|--------|--------------------------|
| **Kubernetes** | Managed K8s (Nederlense provider) | Reduce operational burdand, control plane managed |
| **Database** | Managed PostgreSQL | No StatefulSet complexity, HA out-of-box |
| **Observability** | Prometheus/Grafana (populair, grote community) | Veel documentatie, community support |
| **CNI** | Cilium (eBPF, moderne tech) | Investment in future, maar training noded |
| **Service Mesh** | Geand (Priority 2) | Te complex for team without K8s ervaring |
| **Distributed Tracing** | Geand (Priority 2) | Start with metrics/logs, tracing later |

### Depanddency Chain
```
Team Constraint (no K8s experience)
  → Technical Requirement (managed services, simple tooling)
    → Platform Capability (reduce operational overhead)
      → Tooling Choice (managed K8s, managed DB, stenard CNCF tools)
```

### Priority 0 Trade-off
**Managed vs. Self-hosted**
- **Managed K8s**: ✅ Lower ops burdand → **Team maturity constraint**
- **Self-hosted K8s**: ❌ Higher control → Conflicts with **team capabilities**
- **Keuze**: Managed K8s prioriteert team maturity bovand absolute control

---

## 9. Budget & Cost Constraints

### Priority 0 Constraint
- **Budget Realisme**: Geand andterprise SaaS budgets (Section "Harde Renvoorwaardand")
- **Implication**: Opand-source tooling voorkeur
- **Validatie**: Cost monitoring vanaf day 1

### Priority 1 Implementatie
| Capability | Tool/Techniek | Cost Consideration |
|-----------|---------------|-------------------|
| **Observability** | Prometheus/Grafana/Loki (opand-source) | Free vs. Datadog/New Relic ($$$) |
| **Container Registry** | Harbor (self-hosted) | Free vs. Quay.io/Docker Hub (paid tiers) |
| **Secrets Management** | Vault (self-hosted) | Free vs. AWS Secrets Manager/Azure Key Vault ($) |
| **GitOps** | Argo CD (self-hosted) | Free vs. GitLab Ultimate/GitHub Enterprise ($) |
| **Cost Monitoring** | OpenCost / Kubecost (opand-source tier) | Visibility without cost |

### Depanddency Chain
```
Budget Constraint (no andterprise SaaS)
  → Technical Requirement (self-hosted, opand-source)
    → Platform Capability (manage tooling ourselves)
      → Tooling Choice (CNCF projects, community support)
```

### Trade-off: Self-hosted vs. Managed Tooling
**Self-hosted**: ✅ Lower cost, vendor indepanddence ❌ Higher operational burdand  
**Managed SaaS**: ✅ Lower ops burdand ❌ Higher cost, vendor lock-in  
**Keuze**: Self-hosted prioritizes budget constraint about operational simplicity

---

## 10. Multi-Region Readiness (Toekomst)

### Priority 0 Non-Goal
- **Expliciete Non-Goal**: Multi-region deployment (Section "Non-Goals")
- **Rationale**: Te complex for team without K8s ervaring
- **Architectuur Requirement**: Wel multi-region possible makand (niet blokkerand)

### Priority 1 Implementatie
| Decision | Choice | Multi-Region Readiness |
|----------|--------|----------------------|
| **CNI** | Cilium | ✅ Cluster Mesh capability (Priority 2) |
| **GitOps** | Argo CD | ✅ Multi-cluster support |
| **Observability** | Prometheus/Grafana | ✅ Federation possible |
| **Database** | Managed PostgreSQL | ⚠️ Read replicas cross-region (provider depanddent) |

### Depanddency Chain
```
Business Non-Goal (no multi-region now)
  → Technical Requirement (don't block future multi-region)
    → Platform Capability (select multi-region capable tools)
      → Tooling Choice (Cilium, Argo CD - multi-cluster ready)
```

---

## 11. Compliance & Audit Requirements

### Priority 0 Requirement
- **Compliance**: GDPR (data residency EU, andcryption, audit logging)
- **Audit Trail**: Who deed wat whand (GitOps!)
- **Retention**: Audit logs for minimaal 1 year

### Priority 1 Implementatie
| Requirement | Implementation | Audit Capability |
|------------|----------------|-----------------|
| **Data Residency** | EU datacenter, EU backup storage | Infrastructure location validation |
| **Encryption at Rest** | Cloud KMS (backups), database andcryption | Key management audit trail |
| **Encryption in Transit** | TLS (ingress), optional mTLS (service mesh Priority 2) | Certificate lifecycle logs |
| **Change Audit** | GitOps (all changes in Git) | Git commit history = audit log |
| **Access Audit** | Kubernetes audit logs + OIDC | Who accessed what whand |

### Depanddency Chain
```
Compliance Requirement (GDPR)
  → Technical Requirement (data residency, andcryption, audit logs)
    → Platform Capability (EU infrastructure, GitOps, K8s audit)
      → Tooling Choice (EU provider, Argo CD, OIDC integration)
```

---

## 12. Decision Rules Summary ("Choose X unless Y")

### CNI Plugin
**Use Cilium unless**:
- Je hebt al Calico expertise in-house en wilt niet investerand in Cilium learning curve
- Je hebt BGP routing requirements (Calico is sterker in BGP)
- Je wilt absoluut simpelste setup (Flannel, maar mist veel features)

**Priority 0 Rationale**: Network policies (security), performance (eBPF), multi-region ready (addkomst)

---

### GitOps Tool
**Use Argo CD unless**:
- Je wilt GitOps-pure without UI → Flux
- Je hebt complexe Helm + image automation → Flux heeft sterkere Helm support
- Je wilt minimale footprint → Flux is lighter-weight

**Priority 0 Rationale**: Audit trail (compliance), UI for Support, self-service deployments

---

### Observability Stack
**Use Prometheus + Grafana + Loki unless**:
- Je hebt andterprise SaaS budget → Datadog/New Relic (minder operationele overhead)
- Je wilt vendor-managed → Cloud provider observability (CloudWhatch, Azure Monitor)

**Priority 0 Rationale**: Budget constraint (opand-source), vendor indepanddence, team maturity (grote community)

---

### Secrets Management
**Use Vault + External Secrets Operator unless**:
- Je bent all-in on cloud provider → Cloud KMS + External Secrets (AWS Secrets Manager, Azure Key Vault)
- Je wilt absolute simpelheid → Sealed Secrets (maar geand centralized management)

**Priority 0 Rationale**: No secrets in Git, vendor indepanddence (Vault is portable), rotation capability

---

### Database Strategy
**Use Managed PostgreSQL unless**:
- Je hebt database HA expertise in-house → StatefulSet + Postgres Operator
- Vendor indepanddence is absolute requirement → StatefulSet (maar hogere operationele last)

**Priority 0 Rationale**: Team maturity (geand DB HA expertise), data resilience (PITR, HA native), pragmatisme (business impact > portability for database)

---

### Container Registry
**Use Harbor (self-hosted) unless**:
- Je hebt no capacity for registry operations → Cloud provider registry (ECR, ACR, GCR)
- Je wilt vendor SaaS → Quay.io, Docker Hub (paid tiers)

**Priority 0 Rationale**: Vendor indepanddence, budget (self-hosted is free), image scanning included

---

### Ingress Controller
**Use NGINX Ingress Controller unless**:
- Je wilt dynamische configuration without restarts → Traefik
- Je bent all-in on Envoy ecosystem → Contour, Istio Gateway

**Priority 0 Rationale**: Maturity (meest gebruikt), cloud-agnostic (portability), feature set (SSL, rate limiting)

---

### Infrastructure as Code
**Use Terraform unless**:
- Je wilt moderne taal (TypeScript/Python) → Pulumi
- Je wilt Kubernetes-native orchestratie → Crossplane (maar veel complexer)

**Priority 0 Rationale**: Vendor indepanddence (multi-cloud), maturity (stabiele providers), community support

---

## 13. Critical Opand Questions Impact Analysis

### Q1: Which Managed Kubernetes Provider?
**Priority 0 Impact**: 
- **Vendor Indepanddence** → Provider moet Terraform support hebband
- **Data Sovereignty** → EU datacenter vereist
- **Team Maturity** → Support kwaliteit is kritisch

**Blokkerende Beslissing**: Ja (kan niet startand without provider keuze)

---

### Q5: Resource Requirements?
**Priority 0 Impact**:
- **Budget** → Node sizing bepaalt monthlye takesand
- **Beschikbaarheid** → Bepaalt aantal nodes for HA

**Blokkerende Beslissing**: Ja (sizing is essentieel for cluster provisioning)

---

### Q10: Git Branching Strategy?
**Priority 0 Impact**:
- **GitOps Principe** → Moet passand with Essential SAFe proces
- **Ownership Model** → Bepaalt approval workflows

**Blokkerende Beslissing**: Nee (kan later verfijnd wordand, start with simpele trunk-based)

---

### Q26: Huidige Database?
**Priority 0 Impact**:
- **Data Resilience** → Migratie complexiteit
- **Vendor Indepanddence** → Managed DB keuze (PostgreSQL, MySQL, etc.)

**Blokkerende Beslissing**: Ja (bepaalt migration strategy)

---

### Q31-34: Applicatie Stateless? Health Checks?
**Priority 0 Impact**:
- **Zero-Downtime Deployments** → Vereist stateless applicatie
- **High Availability** → Vereist horizontale scaling

**Blokkerende Beslissing**: Ja (fundamentele requirement for rolling updates)

---

## 14. Consistency Validation

### ✅ Alle Priority 1 Keuzes Traceerbaar
Elke tool keuze in Priority 1 heeft:
- Duidelijke Priority 0 requirement mapping
- Rationale based on constraints (team, budget, vendor indepanddence)
- "Use X unless Y" decision rule
- Alternative consideration (waarom niet tool Y?)

### ✅ Geand Tool Keuzes Zonder Rationale
Alle tools in Priority 1 hebband:
- Business/technical requirement
- Priority 0 principle alignment
- Trade-off analysis

### ✅ Trade-offs Zijn Expliciet
Where Priority 0 principes conflicterand:
- Managed DB (team maturity) vs. StatefulSet (vendor indepanddence)
- Resolution: Team maturity > vendor indepanddence **voor database**
- Rationale: Business impact (data resilience) + team capability

---

## 15. Voor Interactieve Site: Decision Tree Inputs

### User Input Variables
```json
{
  "team_size": "nowmber",
  "kubernetes_experience": "none|basic|intermediate|expert",
  "budget_constraint": "low|medium|high",
  "vanddor_indepanddence_priority": "low|medium|high",
  "compliance_requirements": ["GDPR", "PCI-DSS", "SOC2", "none"],
  "team_maturity": "none|learning|experienced",
  "deploymandt_frequency": "weekly|daily|multiple_daily",
  "service_count": "1|2-5|5-10|10+",
  "downtime_tolerance": "none|minowtes|hours",
  "data_criticality": "low|medium|high"
}
```

### Decision Logic Examples
```yesvascript
// CNI Decision
if (network_policies_required && vanddor_indepanddence === "high") {
  if (team_experience === "none" && budget === "low") {
    recommend("Cilium", "eBPF performance + multi-region ready, maar training noded");
    alternative("Calico", "Simpeler maar iptables-based, as team no capacity heeft");
  }
}

// Database Decision
if (data_criticality === "high" && team_maturity === "none") {
  recommend("Managed PostgreSQL", "HA + PITR out-of-box, team heeft geand DB expertise");
  tradeoff("Vendor lock-in risk, maar business impact > portability for database");
  alternative("StatefulSet + Operator", "Alleand as team DB HA expertise heeft");
}

// GitOps Decision
if (audit_trail_required || self_service_required) {
  recommend("Argo CD", "UI + RBAC + audit trail");
  alternative("Flux", "Als je GitOps-pure without UI wilt");
}
```

---

## 16. Summary: Traceability Matrix

| Priority 0 Requirement | Priority 1 Implementation | Tool Choice | Critical Opand Question |
|---------------------|----------------------|-------------|----------------------|
| Zero-downtime deployments | Rolling updates + health checks | Kubernetes Deployments, Argo CD, NGINX | Q31-34 (app stateless?) |
| Proactive monitoring | Metrics + logs + alerts | Prometheus, Grafana, Loki, Alertmanager | Q14 (business metrics?) |
| Data resilience | PITR + HA database | Managed PostgreSQL, Velero | Q26 (current DB?), Q27 (size?) |
| Vendor indepanddence | Opand-source stack + IaC | Cilium, Argo CD, Prometheus, Terraform | Q1 (K8s provider?) |
| Security by design | Secrets mgmt + RBAC + network policies | Vault, External Secrets, Cilium, RBAC | Q18 (IdP?), Q20 (Vault unsealing?) |
| GitOps from day 1 | Declarative deployments | Argo CD, GitHub Actions | Q10 (branching strategy?) |
| Team maturity | Managed services + simple tooling | Managed K8s, Managed DB | Q15 (Ops FTE?), Q42 (consultant?) |
| Budget constraint | Opand-source voorkeur | Self-hosted stack (Harbor, Vault, etc.) | Q43 (current costs?), Q44 (budget approval?) |

---

**Document Owner**: Platform Architect / Decision Board  
**Update Frequentie**: Bij elke wijziging in Priority 0 requirements or Priority 1 keuzes  
**Audit Status**: ✅ Alle beslissingen traceerbaar to Priority 0  
**Geschiktheid Interactieve Site**: ✅ Decision logic extractable, input variables defined  

---

**Version**: 1.0  
**Date**: December 2024  
**License**: MIT
