# Priority 2: Platform Enhancements & Resilience — Decision Framework

**Target Audience**: Platform Engineers, DevOps Engineers, SREs, Architects  
**Type**: Decision Framework & Capability Mapping  
**Organization**: Dutch webshop / online store with Essential SAFe methodology  
**Prerequisite**: Priority 0 and Priority 1 are **analyzed and structured** (not necessarily implemented)  

---

## ⚠️ Important: This is NOT an Implementation Guide

**This document is:**
- 🎯 A **decision framework** for when Priority 2 capabilities become relevant
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
🔗 **[Priority 1 LINK]** - How does this build on Priority 1?  

---

## Executive Summary

This document describes **Priority 2: Platform Enhancements & Resilience** — the **decision-making process** for advanced platform capabilities after the Priority 1 foundation is stable.

### Context: From Priority 1 to Priority 2

**Priority 1 (Foundation)** is about:
- Cluster runs
- GitOps works
- Basic observability (metrics, logs)
- Network policies exist
- Deployments succeed

**Priority 2 (Enhancement)** is about **maturity and optimization**:
- What happens **between** services? → service mesh
- How do you **trace** a request end-to-end? → distributed tracing
- How do you **test** failure scenarios? → chaos engineering
- How do you **enforce** security policies? → policy enforcement
- Where does the **money** go? → cost visibility
- Are we **ready** for multi-region? → architectural readiness

### Core Question Priority 2

> **"When does this complexity investment become worthwhile?"**

Not: "What tool is best?"  
But: "**Under what circumstances would I even want this?**"

---

## Decision Matrix: Priority 1 → Priority 2 Triggers

| Capability | Trigger Condition | Complexity Cost | Skip If... |
|-----------|-------------------|----------------|------------|
| **Service Mesh** | > 5 microservices, security/observability per-service | Medium-High | Monolith or < 3 services |
| **Distributed Tracing** | Debugging cross-service issues takes > 1h | Medium | < 5 services, simple call chains |
| **Chaos Engineering** | Production incidents, HA validation needed | Low-Medium | Dev environment, single instance |
| **Policy Enforcement** | Compliance requirement, > 10 developers | Medium | Small team, manual review works |
| **Cost Visibility** | Budget concerns, multi-tenant | Low | Single team, fixed costs |
| **Multi-Region Readiness** | Latency requirements, DR strategy | High | Single region sufficient, no DR requirement |
| **Enhanced Auditing** | GDPR/DORA compliance, security team | Medium | No compliance requirement |

---

## 1. Service Mesh

### 🎯 [TRIGGER] When Relevant?

**Implement a service mesh when:**
- ✅ You have **> 5 microservices** with complex inter-service communication
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
- Priority 1 is not yet stable
- You have < 5 services
- Team has no Kubernetes experience yet

### 🔗 [Priority 1 LINK]

**Builds on:**
- Cilium CNI (Priority 1) → Service mesh adds L7 visibility
- Prometheus (Priority 1) → Service mesh adds per-service golden signals
- Network Policies (Priority 1) → Service mesh adds mTLS (zero-trust)

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
| **OpenTelemetry + Tempo** | Grafana native, S3 storage, cost-efficient | Newer than Jaeger, less features | Already Grafana stack, S3 available |
| **Cloud Provider (X-Ray, AppInsights)** | Managed, auto-instrumentation | Vendor lock-in, costs | Already in that cloud, no self-host |
| **Zipkin** | Lightweight, simple | Minder actief dan Jaeger | Legacy use case |

### 💭 [DECISION POINT] Questions to Answer

1. **What is the business impact of slow debugging?**
   - How many tijd takes cross-service debugging per week?
   - How many klantimpact hebband performance issues?

2. **Can we services instrumenterand?**
   - Do we have ownership per service (for SDK integration)?
   - Can we auto-instrumentation gebruikand (.NET, Java)?
   - Do we have capacity for manual instrumentation (Go, Python)?

3. **What is our trace retention strategy?**
   - How many days traces store? (storage costs!)
   - Sampling ratio (100% dev, 10% prod, 1% for high-traffic)?

### ⚠️ [TIMING] Why Now or Not?

**Implement NOW if:**
- Debugging cross-service issues > 1 uur per incident
- You production incidents have without clear root cause
- You service depanddencies onbekend are (shadow depanddencies)

**Wait LATER if:**
- You < 5 services have
- Logs + metrics sufficient are
- No budget for trace storage (TB's per month!)

### 🔗 [Priority 1 LINK]

**Builds on:**
- Prometheus (Priority 1) → Traces voegand request-level detail add
- Loki (Priority 1) → Trace ID in logs for correlatie
- Grafana (Priority 1) → Unified view (metrics + logs + traces)

---

## 3. Chaos Enginoring

### 🎯 [TRIGGER] When Relevant?

**Implementeer chaos andginoring when:**
- ✅ You **HA (High Availability) claimt** maar niet test
- ✅ You **production incidents** want voorkomand through proactief testand
- ✅ You **RTO/RPO** want validerand (Disaster Recovery testing)
- ✅ You **team confidence** want bouwand in platform resilience
- ✅ You **SLO's** have die je want validerand

**NOT implement when:**
- ❌ You **no HA setup** have (single replica, single node)
- ❌ You **Priority 1 basis not stable** is
- ❌ Team **no tijd** has for experiment analysis
- ❌ You **no monitoring** have to impact to measure

### 🔀 [TRADE-OFFS] Choice Space

| Tool | Pro | Contra | Use When |
|------|-----|--------|----------|
| **Chaos Mesh** | K8s-native, rich scenarios, GitOps | Chinos project (governance concern?) | Self-hosted, veel scenarios |
| **LitmusChaos** | CNCF project, community-drivand | Complex setup | CNCF preference |
| **Gremlin** | Enterprise support, managed | Commercial, niet self-hosted | Budget available, managed voorkeur |
| **AWS/Azure Chaos** | Cloud-native, provider integration | Vendor lock-in | Already in that cloud |

### 💭 [DECISION POINT] Questions to Answer

1. **What is our chaos maturity?**
   - Do we have HA setup (meerdere replicas, nodes)?
   - Do we have PodDisruptionBudgets?
   - Do we have readiness/liveness probes?

2. **What failure scenarios are relevant?**
   - Pod crash? (test: K8s restart works)
   - Node failure? (test: pod scheduling on andere node)
   - Network partition? (test: services blijvand available)
   - Resource stress? (test: HPA scaling works)

3. **How do we measure success?**
   - SLO's blijvand within target? (99.9% uptime maintained)
   - Alerts triggerand correct?
   - Automated recovery works?

### ⚠️ [TIMING] Why Now or Not?

**Implement NOW if:**
- You HA claimt maar nooit test
- You production incidents have through failure scenarios
- You confidence want bouwand in platform resilience

**Wait LATER if:**
- Priority 1 nog not stable is
- You no HA setup have
- No monitoring to impact to measure

### 🔗 [Priority 1 LINK]

**Builds on:**
- Velero (Priority 1) → Chaos test: cluster restore works?
- Prometheus (Priority 1) → Chaos experiments zichtbaar in metrics
- HA setup (Priority 1) → Chaos valideert dat HA daadwerkelijk works

---

## 4. Policy Enforcement (Low Trust)

### 🎯 [TRIGGER] When Relevant?

**Implementeer policy enforcement when:**
- ✅ You **> 10 developers** have die niet allemaal K8s-experts are
- ✅ You **compliance verrequirementtand** have (GDPR, DORA, PCI-DSS)
- ✅ You **security incidents** have gehad through misconfigurations
- ✅ You **automated validation** want for deployments
- ✅ You **audit trail** needed have for wie-wat-whand

**NOT implement when:**
- ❌ You **< 5 developers** have die allemaal K8s-experts are
- ❌ **Manowal review** proces works goed
- ❌ No compliance requirements
- ❌ Team kan policy complexity niet aan

### 🔀 [TRADE-OFFS] Choice Space

| Tool | Pro | Contra | Use When |
|------|-----|--------|----------|
| **Kyverno** | YAML-based (no Rego), mutations, generate policies | Minder krachtig dan OPA | Developer-friendly, eenvoud |
| **OPA Gatekeeper** | Zeer krachtig (Rego), mature, CNCF | Rego learning curve, complex | Security team, complexe policies |
| **Kubewardand** | Policies in Rust/Go/etc, WebAssembly | Nieuw, kleine community | Bleeding edge, WASM fans |
| **Pod Security Admission** | K8s native, gratis | Alleand pod security, niet extensible | Basic security, no custom policies |

### 💭 [DECISION POINT] Questions to Answer

1. **What policies are kritisch?**
   - No privileged containers? (security critical)
   - Resource limits required? (capacity management)
   - Trusted registry only? (supply chain security)
   - Network policies required? (network security)

2. **What is our enforcement strategy?**
   - Start in **audit mode** (1 month: collect violations)
   - Gradual **warnings** (1 month: teams fixand violations)
   - Per-policy **andforce mode** (dev → staging → production)

3. **What is our exception strategy?**
   - Who kan policy exceptions goedkeurand?
   - How lang are exceptions geldig?
   - Audit trail for exceptions?

### ⚠️ [TIMING] Why Now or Not?

**Implement NOW if:**
- You compliance requirements have
- You security incidents have through misconfigs
- You > 10 developers have

**Wait LATER if:**
- You < 5 developers have
- Manowal review works prima
- Team has no capacity for policy management

### 🔗 [Priority 1 LINK]

**Builds on:**
- Pod Security Stenards (Priority 1) → Policies andforce PSS automatisch
- Network Policies (Priority 1) → Policy generates default-deny
- RBAC (Priority 1) → Policy audit RBAC changes

---

## 5. Cost Visibility

### 🎯 [TRIGGER] When Relevant?

**Implementeer cost visibility when:**
- ✅ You **budget concerns** have (costs rising unexpectedly)
- ✅ You **multi-tenant cluster** have (costs allocatie per team)
- ✅ You **showback/chargeback** want doand per team/project
- ✅ You **idle resources** want identificerand (cost optimization)
- ✅ You **capacity planning** want baserand on daadwerkelijk gebruik

**NOT implement when:**
- ❌ You **single tenant** are with **fixed costs**
- ❌ **Cloud costs are no concern** (budget amply sufficient)
- ❌ Basic CPU/memory metrics from Prometheus sufficient are
- ❌ Team has no tijd for cost optimization

### 🔀 [TRADE-OFFS] Choice Space

| Tool | Pro | Contra | Use When |
|------|-----|--------|----------|
| **Kubecost** | Feature-rich, recommendations, multi-cloud | Commercial (gratis versie OK) | Full-featured, single cluster |
| **OpenCost** | 100% opand-source, CNCF senbox | Minder features dan Kubecost | Budget constraint, basics |
| **Cloud Provider Tools** | Native integration, managed | Vendor lock-in, not K8s-native | Already in that cloud, native voorkeur |

### 💭 [DECISION POINT] Questions to Answer

1. **What willand we wetand?**
   - Kostand per namespace? (multi-tenancy)
   - Kostand per service? (microservices cost attribution)
   - Idle resource cost? (optimization opportunities)
   - Trend analysis? (groei voorspelland)

2. **What doand we with de data?**
   - Showback (informative)? → OpenCost sufficient
   - Chargeback (financieel)? → Kubecost aanbevoland
   - Optimization (rightsizing)? → Kubecost recommendations

3. **What is our cost optimization strategy?**
   - Automated rightsizing? (risky!)
   - Manowal review (monthly)? (safe)
   - Alert on anomalies? (proactive)

### ⚠️ [TIMING] Why Now or Not?

**Implement NOW if:**
- Kostand rising unexpectedly (> 20% per month)
- You multi-tenant bent (costs allocatie unclear)
- Management vraagt cost visibility

**Wait LATER if:**
- Single tenant, fixed costs
- Budget amply sufficient
- No capacity for cost optimization

### 🔗 [Priority 1 LINK]

**Builds on:**
- Prometheus (Priority 1) → Kubecost gebruikt CPU/memory metrics
- Resource limits (Priority 1) → Cost tool toont waste (limits vs usage)

---

## 6. Multi-Region Readiness

### 🎯 [TRIGGER] When Relevant?

**Overweeg multi-region when:**
- ✅ You **gebruikers in meerdere regio's** have with **latency requirements**
- ✅ You **Disaster Recovery** strategy multi-region verrequirementt (RTO < 1h)
- ✅ You **data residency** requirements have (GDPR: EU data in EU)
- ✅ You **traffic growth** verwacht die single region niet aankan

**NOT implement when:**
- ❌ **Single region sufficient** for je use case
- ❌ You **no DR requirement** have
- ❌ **Complexity** outweighs benefits (multi-region is HARD)
- ❌ You **database** is niet multi-region ready (biggest blocker!)

### 🔀 [TRADE-OFFS] Architectural Choices

| Approach | Pro | Contra | Use When |
|----------|-----|--------|----------|
| **Active-Active (beide regio's live)** | Beste latency, beste HA | Zeer complex, data sync issues | Mission-critical, budget |
| **Active-Passive (1 live, 1 stenby)** | Simpeler, DR capability | Stenby idle (costs), RTO > 5 min | DR requirement, niet latency |
| **Read Replicas (DB per regio)** | Beste latency, simpeler | Eventual consistency, complex writes | Read-heavy workload |

### 💭 [DECISION POINT] Questions to Answer

1. **What is our multi-region strategy?**
   - **NOT NOW**: Single region in Priority 2
   - **LATER**: Multi-region in Layer 3 (indiand needed)
   - **PREPAREDNESS**: Architectuur must het niet blokkerand

2. **Is our architectuur multi-region ready?**
   - ✅ **Stateless services** (horizontally scalable)
   - ✅ **Shared database** (read replicas possible)
   - ✅ **Session state in cache** (Redis/Valkey kan regionaal)
   - ❓ **Database replicatie** (biggest challenge!)

3. **What are our blockers?**
   - Database (PostgreSQL multi-region replicatie?)
   - Stateful workloads (persistent volumes regional)
   - Cost (double infrastructure)

### ⚠️ [TIMING] Why Now or Not?

**Voorbereidand NU (niet activerand!):**
- Architectuur must multi-region niet blokkerand
- Cilium Cluster Mesh optie andabled (niet gebruikt)
- DR scenario's documenterand

**Activerand LATER (Layer 3):**
- Alleand as business case duidelijk is
- Database strategy duidelijk is
- Team capacity has

### 🔗 [Priority 1 LINK]

**Builds on:**
- Cilium CNI (Priority 1) → Cluster Mesh capability for multi-region
- Velero (Priority 1) → Backup restore in andere regio (DR)
- Stateless design (Priority 1) → Maakt multi-region possible

---

## 7. Observability Uitbreiding

### 🎯 [TRIGGER] When Relevant?

**Verhoog observability maturity when:**
- ✅ You **Priority 1 observability** (metrics, logs) niet sufficient is
- ✅ You **alerting strategy** unclear is (alles is pager-worthy?)
- ✅ You **correlation** between metrics/logs/traces want
- ✅ You **SLO's** want monitorand (error budget)

### 🔀 [TRADE-OFFS] Alerting Strategie

| Alert Level | Trigger | Action | Destination | Example |
|------------|---------|--------|-------------|---------|
| **CRITICAL** | Service down, data loss risk | Page on-call | PagerDuty | App down, DB unreachable |
| **WARNING** | Degraded performance | Notify team | Slack | High latency, high CPU |
| **INFO** | Routine events | Log only | Dashboard | Deployment success, backup OK |

### 💭 [DECISION POINT] Questions to Answer

1. **What is pager-worthy?**
   - **CRITICAL**: Production down, payment failures, data loss
   - **WARNING**: Slow performance, high resource usage
   - **INFO**: Successful deployments, routine events

2. **How correlerand we observability data?**
   - Trace ID in logs (structured logging)
   - Exemplars in Prometheus (metrics → traces)
   - Grafana Explore (unified view)

3. **What is our SLO strategy?**
   - Define SLO's (99.9% uptime, P95 < 200ms)
   - Monitor error budget
   - Alert on budget burn rate

### ⚠️ [TIMING] Why Now or Not?

**Verhoog maturity NU als:**
- Alert fatigue (te veel alerts, team negeert)
- Debugging is slow (no correlatie between metrics/logs/traces)
- SLO's are undefined (no error budget)

**Wait LATER if:**
- Priority 1 observability works prima
- Alert strategy is clear
- Team has no capacity

### 🔗 [Priority 1 LINK]

**Builds on:**
- Prometheus (Priority 1) → Enhanced with SLO monitoring
- Loki (Priority 1) → Enhanced with structured logging + trace ID
- Grafana (Priority 1) → Enhanced with unified observability

---

## 8. Security & Auditing

### 🎯 [TRIGGER] When Relevant?

**Verhoog audit maturity when:**
- ✅ You **compliance requirements** have (GDPR, DORA, ISO 27001)
- ✅ You **security incidents** want kunnand investigerand
- ✅ You **break-glass procedures** needed have (emergency access)
- ✅ You **SIEM integration** want (centralized security monitoring)

**NOT implement when:**
- ❌ No compliance requirements
- ❌ Basic K8s audit logs sufficient are
- ❌ No security team

### 🔀 [TRADE-OFFS] Audit Strategie

| Component | Audit What | Retention | Use When |
|-----------|------------|-----------|----------|
| **K8s Audit Logs** | API calls (kubectl, RBAC) | 1 year | Compliance |
| **ArgoCD Audit** | GitOps syncs, manual approvals | 1 year | Deployment audit |
| **Vault Audit** | Secret access (read/write) | 1 year | Secret compliance |

### 💭 [DECISION POINT] Questions to Answer

1. **What mustand we auditand?**
   - K8s API calls (wie deed wat whand)
   - GitOps syncs (welke change, through wie)
   - Secret access (wie las welke secret)
   - Break-glass usage (emergency access audit)

2. **What is our break-glass strategy?**
   - How krijg je emergency access? (privilege escalation tool)
   - Howlang geldig? (max 1 uur)
   - How loggand we dit? (full audit trail)
   - Post-incident review? (required)

3. **How integrerand we with SIEM?**
   - What SIEM? (Splunk, Elastic, etc.)
   - Push or pull? (Loki → SIEM)
   - Real-time or batch? (batch = cheaper)

### ⚠️ [TIMING] Why Now or Not?

**Implement NOW if:**
- Compliance requirements (DORA, GDPR)
- Security team vraagt audit trail
- Break-glass procedures needed

**Wait LATER if:**
- No compliance requirement
- Basic K8s audit logs sufficient
- No security team

### 🔗 [Priority 1 LINK]

**Builds on:**
- RBAC (Priority 1) → Audit RBAC changes
- Loki (Priority 1) → Centralized audit log storage
- Vault (Priority 1) → Audit secret access

---

## Resultaat Priority 2: Maturity Assessment

### Na Priority 2 Analyse Kun You Beantwoorden:

✅ **Service Mesh**: Do we have dit needed? (> 5 services, security/observability)  
✅ **Distributed Tracing**: Lost dit eand daadwerkelijk probleem op? (debugging > 1h)  
✅ **Chaos Enginoring**: Testand we HA or claimand we het alleand?  
✅ **Policy Enforcement**: Automated validation or manual review?  
✅ **Cost Visibility**: Where does our money go?  
✅ **Multi-Region**: Nu needed or later?  
✅ **Observability**: What is pager-worthy?  
✅ **Auditing**: Compliance requirement or overkill?  

### Priority 2 → Layer 3 (Toekomst)

**Layer 3 zou gaan over:**
- Zero trust networking (full mutual TLS enforcement)
- Active multi-region (Cilium Cluster Mesh actief)
- Advanced chaos (automated, continowous)
- SLO-based automation (error budget policies)
- Cost optimization automation (rightsizing)
- Security automation (auto-remediation)

**Maar dat is alleand relevant as Priority 2 capabilities lopand en je **daadwerkelijk** complexity needed have.**

---

## Conclusion: Complexity as Bewuste Keuze

Priority 2 is niet "de volgende stap after Priority 1".  
Priority 2 is "**welke extra capabilities are de complexity waard?**"

### Beslisregels:

1. **Start simpel**: Priority 1 first, Priority 2 alleand as trigger duidelijk is
2. **Eén tegelijk**: Niet alle Priority 2 capabilities tegelijk (team overload!)
3. **Measure impact**: Every capability must solve measurable problem
4. **Exit strategy**: Can we terug as het niet works?

### For the Webshop Case:

**Probably YES:**
- Distributed tracing (> 5 services, debugging issues)
- Cost visibility (budget concerns, multi-tenant)
- Policy enforcement (compliance, groeiend team)

**Probably NOT (now):**
- Service mesh (< 10 services, network policies sufficient)
- Multi-region (single region sufficient, no DR requirement)
- Chaos andginoring (first HA setup stabilize)

**Dit is de kracht or Priority 2: conscious, justified choices in plaats or "we doand alles maar".**

---

**Author**: [@vanhoutenbos](https://github.com/vanhoutenbos)  
**Version**: 2.0 (Decision Framework)  
**Date**: December 2024  
**License**: MIT
