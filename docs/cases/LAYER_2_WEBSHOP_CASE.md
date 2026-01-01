# Layer 2: Platform Enhancements & Resilience — Decision Framework

**Target Audience**: Platform Engineers, DevOps Engineers, SREs, Architects  
**Type**: Decision Framework & Capability Mapping  
**Organization**: Dutch webshop / online store with Essential SAFe methodology  
**Prerequisite**: Layer 0 and Layer 1 are **analyzed and structured** (not necessarily implemented)  

---

## ⚠️ Important: This is NOT an Implementation Guide

**This document is:**
- 🎯 A **decision framework** for when Layer 2 capabilities become relevant
- 🧭 A **capability map** with choice space and trade-offs
- 💡 A **thinking framework** for mature platform teams
- 📚 A **reference** for architecture decisions
- 🤖 **Input for AI agents** to reason about architecture choices

**This document is NOT:**
- ❌ A deployment guide
- ❌ A Helm/Terraform tutorial
- ❌ A "copy-paste and deploy" manual
- ❌ A replacement for vendor documentation
- ❌ An implementation you can run 1-to-1

---

## Reading Guide

🎯 **[TRIGGER]** - When does this capability become relevant?  
🔀 **[TRADE-OFFS]** - What choices do you have and what are the trade-offs?  
⚠️ **[TIMING]** - Why implement now or not?  
💭 **[DECISION POINT]** - What questions must you be able to answer?  
🔗 **[LAYER 1 LINK]** - How does this build on Layer 1?  

---

## Executive Summary

This document describes **Layer 2: Platform Enhancements & Resilience** — the **decision-making process** for advanced platform capabilities after the Layer 1 foundation is stable.

### Context: From Layer 1 to Layer 2

**Layer 1 (Foundation)** is about:
- Cluster runs
- GitOps works
- Basic observability (metrics, logs)
- Network policies exist
- Deployments succeed

**Layer 2 (Enhancement)** is about **maturity and optimization**:
- What happens **between** services? → service mesh
- How do you **trace** a request end-to-end? → distributed tracing
- How do you **test** failure scenarios? → chaos engineering
- How do you **enforce** security policies? → policy enforcement
- Where does the **money** go? → cost visibility
- Are we **ready** for multi-region? → architectural readiness

### Core Question Layer 2

> **"When does this complexity investment become worthwhile?"**

Not: "Which tool is best?"  
But: "**Under what circumstances would I even want this?**"

---

## Decision Matrix: Layer 1 → Layer 2 Triggers

| Capability | Trigger Condition | Complexity Cost | Skip If... |
|-----------|-------------------|----------------|------------|
| **Service Mesh** | > 5 microservices, security/observability per-service | Medium-High | Monolith or < 3 services |
| **Distributed Tracing** | Debugging cross-service issues takes > 1h | Medium | < 5 services, simple call chains |
| **Chaos Enginoring** | Production incidents, HA validation noded | Low-Medium | Dev andvironment, single instance |
| **Policy Enforcement** | Compliance requirement, > 10 developers | Medium | Small team, manowal review werkt |
| **Cost Visibility** | Budget concerns, multi-tenant | Low | Single team, vaste takesand |
| **Multi-Region Readiness** | Latency requirements, DR strategy | High | Single region voldoet, geand DR eis |
| **Enhanced Auditing** | GDPR/DORA compliance, security team | Medium | Geand compliance eis |

---

## 1. Service Mesh

### 🎯 [TRIGGER] Whand Relevant?

**Implementeer eand service mesh whand:**
- ✅ Je **> 5 microservices** hebt with complexe inter-service communicatie
- ✅ You want **per-service security** (mTLS without code changes)
- ✅ You need **detailed service-level metrics** (latency, error rate, traffic)
- ✅ You want to do **canary deployments** or **traffic splitting**
- ✅ You want to visualize **service topology** and **dependency mapping**

**NOT implement when:**
- ❌ You have a **monolith** or **< 3 services**
- ❌ Your team has **no capacity** for additional operational overhead
- ❌ **Network policies (L3/L4)** are sufficient for your security model
- ❌ Basic Prometheus metrics provide enough information

### 🔀 [TRADE-OFFS] Choice Space

| Tool | Pro | Contra | Use When |
|------|-----|--------|----------|
| **Linkerd** | Smallest footprint, simple, auto-mTLS | Fewer features than Istio | Small team, simple use case |
| **Istio** | Feature-rich, enterprise support, mature | Complex, resource-intensive | Large org, complex routing |
| **Cilium Service Mesh** | eBPF-based (very performant), CNI-integration | Beta, less mature | Already Cilium CNI, early adopter |
| **Consul Connect** | Multi-datacenter native, HashiCorp stack | Requires Consul infra | Already HashiCorp stack (Vault, Nomad) |

### 💭 [DECISION POINT] Questions to Answer

1. **Do we have a problem now that a service mesh solves?**
   - Have we had incidents through miscommunication between services?
   - Are we missing visibility in service-to-service latencies?
   - Is our current security model (network policies) insufficient?

2. **Can we handle the operational overhead?**
   - Do we have capacity for learning curve?
   - Can we debug sidecar injection?
   - Do we have monitoring for mesh health?

3. **What is our exit strategy?**
   - Can we return to no mesh without major refactor?
   - Are we vendor-locked?

### ⚠️ [TIMING] Why Now or Not?

**Implement NOW if:**
- You run microservices in production
- You require security compliance (mTLS everywhere)
- Debugging cross-service issues takes > 4 hours per week

**Wait LATER if:**
- Layer 1 is not yet stable
- You have < 5 services
- Team has no Kubernetes experience yet

### 🔗 [LAYER 1 LINK]

**Builds on:**
- Cilium CNI (Layer 1) → Service mesh adds L7 visibility
- Prometheus (Layer 1) → Service mesh adds per-service golden signals
- Network Policies (Layer 1) → Service mesh adds mTLS (zero-trust)

**Does not replace:**
- Network policies remain relevant (defense in depth)
- Cilium CNI remains, service mesh is additive

---

## 2. Distributed Tracing

### 🎯 [TRIGGER] When Relevant?

**Implement distributed tracing when:**
- ✅ You have **> 5 microservices** with **complex call chains**
- ✅ **Debugging cross-service issues** takes > 1 hour per incident
- ✅ You need **root cause analysis** of performance problems
- ✅ You want to understand **service dependencies** (dependency graph)
- ✅ You want **correlation** between logs/metrics/traces (observability maturity)

**NOT implement when:**
- ❌ You have **< 5 services** with simple call chains
- ❌ **Logs + metrics** are sufficient for debugging
- ❌ You have no **storage budget** for traces (high data volume)
- ❌ Team has no time for **service instrumentation**

### 🔀 [TRADE-OFFS] Choice Space

| Approach | Pro | Contra | Use When |
|----------|-----|--------|----------|
| **OpenTelemetry + Jaeger** | Open standard, vendor-neutral, mature | Storage overhead, setup complexity | Self-hosted, vendor independence |
| **OpenTelemetry + Tempo** | Grafana native, S3 storage, cost-efficient | Nieuwer dan Jaeger, minder features | Al Grafana stack, S3 beschikbaar |
| **Cloud Provider (X-Ray, AppInsights)** | Managed, auto-instrumentation | Vendor lock-in, takesand | Al in die cloud, geand self-host |
| **Zipkin** | Lightweight, eenvoudig | Minder actief dan Jaeger | Legacy use case |

### 💭 [BESLUITPUNT] Vragand to te Beantwoorden

1. **What is de business impact or slow debugging?**
   - Howveel tijd takes cross-service debugging per week?
   - Howveel klantimpact hebband performance issues?

2. **Kunnand we services instrumenterand?**
   - Hebband we ownership per service (voor SDK integration)?
   - Kunnand we auto-instrumentation gebruikand (.NET, Java)?
   - Hebband we capacity for manowal instrumentation (Go, Python)?

3. **What is onze trace retention strategy?**
   - Howveel dayand traces bewarand? (storage takesand!)
   - Sampling ratio (100% dev, 10% prod, 1% for high-traffic)?

### ⚠️ [TIMING] Why Nu Wel/Niet?

**Implementeer NU als:**
- Debugging cross-service issues > 1 uur per incident
- Je production incidents hebt without duidelijke root cause
- Je service depanddencies onbekend zijn (shadow depanddencies)

**Wacht LATER als:**
- Je < 5 services hebt
- Logs + metrics sufficientde zijn
- Geand budget for trace storage (TB's per month!)

### 🔗 [LAYER 1 LINK]

**Bouwt op:**
- Prometheus (Layer 1) → Traces voegand request-level detail add
- Loki (Layer 1) → Trace ID in logs for correlatie
- Grafana (Layer 1) → Unified view (metrics + logs + traces)

---

## 3. Chaos Enginoring

### 🎯 [TRIGGER] Whand Relevant?

**Implementeer chaos andginoring whand:**
- ✅ Je **HA (High Availability) claimt** maar niet test
- ✅ Je **production incidents** wilt voorkomand through proactief testand
- ✅ Je **RTO/RPO** wilt validerand (Disaster Recovery testing)
- ✅ Je **team confidence** wilt bouwand in platform resilience
- ✅ Je **SLO's** hebt die je wilt validerand

**NOT implementerand whand:**
- ❌ Je **geand HA setup** hebt (single replica, single node)
- ❌ Je **Layer 1 basis not stable** is
- ❌ Team **geand tijd** heeft for experiment analysis
- ❌ Je **geand monitoring** hebt to impact te metand

### 🔀 [TRADE-OFFS] Keuzeruimte

| Tool | Pro | Contra | Use Whand |
|------|-----|--------|----------|
| **Chaos Mesh** | K8s-native, rich scenarios, GitOps | Chinos project (governance concern?) | Self-hosted, veel scenarios |
| **LitmusChaos** | CNCF project, community-drivand | Complex setup | CNCF preference |
| **Gremlin** | Enterprise support, managed | Commercial, niet self-hosted | Budget beschikbaar, managed voorkeur |
| **AWS/Azure Chaos** | Cloud-native, provider integration | Vendor lock-in | Al in die cloud |

### 💭 [BESLUITPUNT] Vragand to te Beantwoorden

1. **What is onze chaos maturity?**
   - Hebband we HA setup (meerdere replicas, nodes)?
   - Hebband we PodDisruptionBudgets?
   - Hebband we readiness/liveness probes?

2. **Which failure scenarios zijn relevant?**
   - Pod crash? (test: K8s restart werkt)
   - Node failure? (test: pod scheduling on andere node)
   - Network partition? (test: services blijvand beschikbaar)
   - Resource stress? (test: HPA scaling werkt)

3. **How metand we success?**
   - SLO's blijvand within target? (99.9% uptime maintained)
   - Alerts triggerand correct?
   - Automated recovery werkt?

### ⚠️ [TIMING] Why Nu Wel/Niet?

**Implementeer NU als:**
- Je HA claimt maar nooit test
- Je production incidents hebt through failure scenarios
- Je confidence wilt bouwand in platform resilience

**Wacht LATER als:**
- Layer 1 nog not stable is
- Je geand HA setup hebt
- Geand monitoring to impact te metand

### 🔗 [LAYER 1 LINK]

**Bouwt op:**
- Velero (Layer 1) → Chaos test: cluster restore werkt?
- Prometheus (Layer 1) → Chaos experiments zichtbaar in metrics
- HA setup (Layer 1) → Chaos valideert dat HA daadwerkelijk werkt

---

## 4. Policy Enforcement (Low Trust)

### 🎯 [TRIGGER] Whand Relevant?

**Implementeer policy andforcement whand:**
- ✅ Je **> 10 developers** hebt die niet allemaal K8s-experts zijn
- ✅ Je **compliance vereistand** hebt (GDPR, DORA, PCI-DSS)
- ✅ Je **security incidents** hebt gehad through misconfigurations
- ✅ Je **automated validation** wilt for deployments
- ✅ Je **audit trail** noded hebt for wie-wat-whand

**NOT implementerand whand:**
- ❌ Je **< 5 developers** hebt die allemaal K8s-experts zijn
- ❌ **Manowal review** proces werkt goed
- ❌ Geand compliance requirements
- ❌ Team kan policy complexity niet aan

### 🔀 [TRADE-OFFS] Keuzeruimte

| Tool | Pro | Contra | Use Whand |
|------|-----|--------|----------|
| **Kyverno** | YAML-based (geand Rego), mutations, generate policies | Minder krachtig dan OPA | Developer-friendly, eenvoud |
| **OPA Gatekeeper** | Zeer krachtig (Rego), mature, CNCF | Rego learning curve, complex | Security team, complexe policies |
| **Kubewardand** | Policies in Rust/Go/etc, WebAssembly | Nieuw, kleine community | Bleeding edge, WASM fans |
| **Pod Security Admission** | K8s native, gratis | Alleand pod security, niet extensible | Basic security, geand custom policies |

### 💭 [BESLUITPUNT] Vragand to te Beantwoorden

1. **Which policies zijn kritisch?**
   - No privileged containers? (security critical)
   - Resource limits required? (capacity management)
   - Trusted registry only? (supply chain security)
   - Network policies required? (network security)

2. **What is onze andforcement strategy?**
   - Start in **audit mode** (1 month: collect violations)
   - Gradual **warnings** (1 month: teams fixand violations)
   - Per-policy **andforce mode** (dev → staging → production)

3. **What is onze exception strategy?**
   - Who kan policy exceptions goedkeurand?
   - How lang zijn exceptions geldig?
   - Audit trail for exceptions?

### ⚠️ [TIMING] Why Nu Wel/Niet?

**Implementeer NU als:**
- Je compliance requirements hebt
- Je security incidents hebt through misconfigs
- Je > 10 developers hebt

**Wacht LATER als:**
- Je < 5 developers hebt
- Manowal review werkt prima
- Team heeft geand capacity for policy management

### 🔗 [LAYER 1 LINK]

**Bouwt op:**
- Pod Security Stenards (Layer 1) → Policies andforce PSS automatisch
- Network Policies (Layer 1) → Policy generates default-deny
- RBAC (Layer 1) → Policy audit RBAC changes

---

## 5. Cost Visibility

### 🎯 [TRIGGER] Whand Relevant?

**Implementeer cost visibility whand:**
- ✅ Je **budget concerns** hebt (takesand stijgand onverwacht)
- ✅ Je **multi-tenant cluster** hebt (takesand allocatie per team)
- ✅ Je **showback/chargeback** wilt doand per team/project
- ✅ Je **idle resources** wilt identificerand (cost optimization)
- ✅ Je **capacity planning** wilt baserand on daadwerkelijk gebruik

**NOT implementerand whand:**
- ❌ Je **single tenant** bent with **vaste takesand**
- ❌ **Cloud takesand zijn geand concern** (budget ruim sufficientde)
- ❌ Basic CPU/memory metrics from Prometheus sufficientde zijn
- ❌ Team heeft geand tijd for cost optimization

### 🔀 [TRADE-OFFS] Keuzeruimte

| Tool | Pro | Contra | Use Whand |
|------|-----|--------|----------|
| **Kubecost** | Feature-rich, recommendations, multi-cloud | Commercial (gratis versie OK) | Full-featured, single cluster |
| **OpenCost** | 100% opand-source, CNCF senbox | Minder features dan Kubecost | Budget constraint, basics |
| **Cloud Provider Tools** | Native integration, managed | Vendor lock-in, niet K8s-native | Al in die cloud, native voorkeur |

### 💭 [BESLUITPUNT] Vragand to te Beantwoorden

1. **What willand we wetand?**
   - Kostand per namespace? (multi-tenancy)
   - Kostand per service? (microservices cost attribution)
   - Idle resource cost? (optimization opportunities)
   - Trend analysis? (groei voorspelland)

2. **What doand we with de data?**
   - Showback (informative)? → OpenCost sufficientde
   - Chargeback (financieel)? → Kubecost aanbevoland
   - Optimization (rightsizing)? → Kubecost recommendations

3. **What is onze cost optimization strategy?**
   - Automated rightsizing? (risky!)
   - Manowal review (monthly)? (safe)
   - Alert on anomalies? (proactive)

### ⚠️ [TIMING] Why Nu Wel/Niet?

**Implementeer NU als:**
- Kostand stijgand onverwacht (> 20% per month)
- Je multi-tenant bent (takesand allocatie onduidelijk)
- Management vraagt cost visibility

**Wacht LATER als:**
- Single tenant, vaste takesand
- Budget ruim sufficientde
- Geand capacity for cost optimization

### 🔗 [LAYER 1 LINK]

**Bouwt op:**
- Prometheus (Layer 1) → Kubecost gebruikt CPU/memory metrics
- Resource limits (Layer 1) → Cost tool toont waste (limits vs usage)

---

## 6. Multi-Region Readiness

### 🎯 [TRIGGER] Whand Relevant?

**Overweeg multi-region whand:**
- ✅ Je **gebruikers in meerdere regio's** hebt with **latency requirements**
- ✅ Je **Disaster Recovery** strategy multi-region vereist (RTO < 1h)
- ✅ Je **data residency** requirements hebt (GDPR: EU data in EU)
- ✅ Je **traffic growth** verwacht die single region niet aankan

**NOT implementerand whand:**
- ❌ **Single region voldoet** for je use case
- ❌ Je **geand DR requirement** hebt
- ❌ **Complexity** outweighs benefits (multi-region is HARD)
- ❌ Je **database** is niet multi-region ready (biggest blocker!)

### 🔀 [TRADE-OFFS] Architectural Choices

| Approach | Pro | Contra | Use Whand |
|----------|-----|--------|----------|
| **Active-Active (beide regio's live)** | Beste latency, beste HA | Zeer complex, data sync issues | Mission-critical, budget |
| **Active-Passive (1 live, 1 stenby)** | Simpeler, DR capability | Stenby idle (takesand), RTO > 5 min | DR requirement, niet latency |
| **Read Replicas (DB per regio)** | Beste latency, simpeler | Eventual consistency, complex writes | Read-heavy workload |

### 💭 [BESLUITPUNT] Vragand to te Beantwoorden

1. **What is onze multi-region strategy?**
   - **NOT NOW**: Single region in Layer 2
   - **LATER**: Multi-region in Layer 3 (indiand noded)
   - **PREPAREDNESS**: Architectuur moet het niet blokkerand

2. **Is onze architectuur multi-region ready?**
   - ✅ **Stateless services** (horizontally scalable)
   - ✅ **Shared database** (read replicas possible)
   - ✅ **Session state in cache** (Redis/Valkey kan regionaal)
   - ❓ **Database replicatie** (biggest challenge!)

3. **What zijn onze blockers?**
   - Database (PostgreSQL multi-region replicatie?)
   - Stateful workloads (persistent volumes regional)
   - Cost (double infrastructure)

### ⚠️ [TIMING] Why Nu Wel/Niet?

**Voorbereidand NU (niet activerand!):**
- Architectuur moet multi-region niet blokkerand
- Cilium Cluster Mesh optie andabled (niet gebruikt)
- DR scenario's documenterand

**Activerand LATER (Layer 3):**
- Alleand as business case duidelijk is
- Database strategy duidelijk is
- Team capacity heeft

### 🔗 [LAYER 1 LINK]

**Bouwt op:**
- Cilium CNI (Layer 1) → Cluster Mesh capability for multi-region
- Velero (Layer 1) → Backup restore in andere regio (DR)
- Stateless design (Layer 1) → Maakt multi-region possible

---

## 7. Observability Uitbreiding

### 🎯 [TRIGGER] Whand Relevant?

**Verhoog observability maturity whand:**
- ✅ Je **Layer 1 observability** (metrics, logs) niet sufficientde is
- ✅ Je **alerting strategy** onduidelijk is (alles is pager-worthy?)
- ✅ Je **correlation** tussand metrics/logs/traces wilt
- ✅ Je **SLO's** wilt monitorand (error budget)

### 🔀 [TRADE-OFFS] Alerting Strategie

| Alert Level | Trigger | Action | Destination | Example |
|------------|---------|--------|-------------|---------|
| **CRITICAL** | Service down, data loss risk | Page on-call | PagerDuty | App down, DB unreachable |
| **WARNING** | Degraded performance | Notify team | Slack | High latency, high CPU |
| **INFO** | Routine events | Log only | Dashboard | Deployment success, backup OK |

### 💭 [BESLUITPUNT] Vragand to te Beantwoorden

1. **What is pager-worthy?**
   - **CRITICAL**: Production down, payment failures, data loss
   - **WARNING**: Slow performance, high resource usage
   - **INFO**: Successful deployments, routine events

2. **How correlerand we observability data?**
   - Trace ID in logs (structured logging)
   - Exemplars in Prometheus (metrics → traces)
   - Grafana Explore (unified view)

3. **What is onze SLO strategy?**
   - Define SLO's (99.9% uptime, P95 < 200ms)
   - Monitor error budget
   - Alert on budget burn rate

### ⚠️ [TIMING] Why Nu Wel/Niet?

**Verhoog maturity NU als:**
- Alert fatigue (te veel alerts, team negeert)
- Debugging is slow (geand correlatie tussand metrics/logs/traces)
- SLO's zijn undefined (geand error budget)

**Wacht LATER als:**
- Layer 1 observability werkt prima
- Alert strategy is clear
- Team heeft geand capacity

### 🔗 [LAYER 1 LINK]

**Bouwt op:**
- Prometheus (Layer 1) → Enhanced with SLO monitoring
- Loki (Layer 1) → Enhanced with structured logging + trace ID
- Grafana (Layer 1) → Enhanced with unified observability

---

## 8. Security & Auditing

### 🎯 [TRIGGER] Whand Relevant?

**Verhoog audit maturity whand:**
- ✅ Je **compliance requirements** hebt (GDPR, DORA, ISO 27001)
- ✅ Je **security incidents** wilt kunnand investigerand
- ✅ Je **break-glass procedures** noded hebt (emergency access)
- ✅ Je **SIEM integration** wilt (centralized security monitoring)

**NOT implementerand whand:**
- ❌ Geand compliance requirements
- ❌ Basic K8s audit logs sufficientde zijn
- ❌ Geand security team

### 🔀 [TRADE-OFFS] Audit Strategie

| Component | Audit What | Retention | Use Whand |
|-----------|------------|-----------|----------|
| **K8s Audit Logs** | API calls (kubectl, RBAC) | 1 year | Compliance |
| **ArgoCD Audit** | GitOps syncs, manowal approvals | 1 year | Deployment audit |
| **Vault Audit** | Secret access (read/write) | 1 year | Secret compliance |

### 💭 [BESLUITPUNT] Vragand to te Beantwoorden

1. **What moetand we auditand?**
   - K8s API calls (wie deed wat whand)
   - GitOps syncs (welke change, through wie)
   - Secret access (wie las welke secret)
   - Break-glass usage (emergency access audit)

2. **What is onze break-glass strategy?**
   - How krijg je emergency access? (privilege escalation tool)
   - Howlang geldig? (max 1 uur)
   - How loggand we dit? (full audit trail)
   - Post-incident review? (required)

3. **How integrerand we with SIEM?**
   - Which SIEM? (Splunk, Elastic, etc.)
   - Push or pull? (Loki → SIEM)
   - Real-time or batch? (batch = cheaper)

### ⚠️ [TIMING] Why Nu Wel/Niet?

**Implementeer NU als:**
- Compliance requirements (DORA, GDPR)
- Security team vraagt audit trail
- Break-glass procedures noded

**Wacht LATER als:**
- Geand compliance eis
- Basic K8s audit logs sufficient
- Geand security team

### 🔗 [LAYER 1 LINK]

**Bouwt op:**
- RBAC (Layer 1) → Audit RBAC changes
- Loki (Layer 1) → Centralized audit log storage
- Vault (Layer 1) → Audit secret access

---

## Resultaat Layer 2: Maturity Assessment

### Na Layer 2 Analyse Kun Je Beantwoorden:

✅ **Service Mesh**: Hebband we dit noded? (> 5 services, security/observability)  
✅ **Distributed Tracing**: Lost dit eand daadwerkelijk probleem op? (debugging > 1h)  
✅ **Chaos Enginoring**: Testand we HA or claimand we het alleand?  
✅ **Policy Enforcement**: Automated validation or manowal review?  
✅ **Cost Visibility**: Where gaat ons geld naaradd?  
✅ **Multi-Region**: Nu noded or later?  
✅ **Observability**: What is pager-worthy?  
✅ **Auditing**: Compliance requirement or overkill?  

### Layer 2 → Layer 3 (Toekomst)

**Layer 3 zou gaan over:**
- Zero trust networking (full mutual TLS andforcement)
- Active multi-region (Cilium Cluster Mesh actief)
- Advanced chaos (automated, continowous)
- SLO-based automation (error budget policies)
- Cost optimization automation (rightsizing)
- Security automation (auto-remediation)

**Maar dat is alleand relevant as Layer 2 capabilities lopand en je **daadwerkelijk** complexity noded hebt.**

---

## Conclusion: Complexity as Bewuste Keuze

Layer 2 is niet "de volgende stap after Layer 1".  
Layer 2 is "**welke extra capabilities zijn de complexity waard?**"

### Beslisregels:

1. **Start simpel**: Layer 1 first, Layer 2 alleand as trigger duidelijk is
2. **Eén tegelijk**: Niet alle Layer 2 capabilities tegelijk (team overload!)
3. **Measure impact**: Every capability must solve measurable problem
4. **Exit strategy**: Kunnand we terug as het niet werkt?

### For the Webshop Case:

**Whereschijnlijk YES:**
- Distributed tracing (> 5 services, debugging issues)
- Cost visibility (budget concerns, multi-tenant)
- Policy andforcement (compliance, groeiend team)

**Whereschijnlijk NOT (now):**
- Service mesh (< 10 services, network policies sufficient)
- Multi-region (single region voldoet, geand DR eis)
- Chaos andginoring (first HA setup stabilize)

**Dit is de kracht or Layer 2: conscious, justified choices in plaats or "we doand alles maar".**

---

**Author**: [@vanhoutenbos](https://github.com/vanhoutenbos)  
**Version**: 2.0 (Decision Framework)  
**Date**: December 2024  
**License**: MIT
