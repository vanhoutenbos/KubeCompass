# Layer 0: Fundament & Context — Webshop Migratiecase

**Doelgroep**: Engineers, Architecten, Management  
**Status**: Foundational — moet vastgelegd zijn vóórdat technische implementatie begint  
**Organisatie**: Nederlandse webshop / online warenhuis met Essential SAFe werkwijze  

---

## Wat is Layer 0?

Layer 0 definieert **het fundament waarop alle technische beslissingen worden gebouwd**. Het gaat niet om concrete tools, YAML-configuraties of pipelines, maar om:

- **Niet-functionele eisen** die de platformarchitectuur bepalen
- **Randvoorwaarden** die niet meer te veranderen zijn zonder grote impact
- **Principes** die richtinggevend zijn voor alle latere keuzes
- **Grenzen** van wat acceptabel is en wat niet

### Waarom Layer 0 eerst?

Zonder duidelijk Layer 0 fundament:
- Worden fundamentele keuzes later als "detail" afgedaan, terwijl ze de architectuur bepalen
- Ontstaan implicite aannames die leiden tot verkeerde toolkeuzes
- Is er geen duidelijk kader om beslissingen te toetsen
- Wordt vendor lock-in per ongeluk geaccepteerd

**Layer 0 moet beantwoord zijn voordat je überhaupt begint met Kubernetes-implementatie.**

---

## 1. Business Context & Impact

### 1.1 Business Model
- **Product**: Fysieke producten verkocht via webshop
- **Distributie**: Eigen verzending door heel Europa
- **Omzet**: Direct afhankelijk van webshopbeschikbaarheid
- **Kritieke functionaliteit**:
  - Producten kunnen zoeken (vervelend als het niet werkt)
  - Bestellen en betalen (**business-kritisch** — direct omzetverlies bij downtime)

### 1.2 Business Impact van Downtime
- **Direct**: Omzetverlies gedurende downtime periode
- **Indirect**: Klantvertrouwen beschadigd
- **Cumulatief**: Herhaald falen = klanten keren niet terug
- **Reputatie**: Negatieve reviews, sociale media impact

**Conclusie**: Beschikbaarheid is **business-kritisch**, niet alleen een technische metric.

---

## 2. Beschikbaarheid & Downtime Verwachtingen

### 2.1 Huidige Situatie (AS-IS)
- Releases alleen maandagnacht
- Downtime wordt **verwacht** bij releases
- Problemen worden reactief ontdekt (via klanten of toeval)
- Geen onderscheid tussen geplande en ongeplande downtime

### 2.2 Doelstelling (TO-BE)
**Kwalitatieve doelen** (SLA's komen in Layer 1):

1. **Releases zonder downtime**
   - Deploy wanneer features klaar zijn, niet wanneer "downtime mag"
   - Rolling updates als standaard
   - Rollback-mogelijkheid binnen minuten

2. **Ongeplande downtime geminimaliseerd**
   - High availability (HA) voor kritieke componenten
   - Geen single points of failure
   - Automatische failover waar mogelijk

3. **Planned maintenance zonder impact**
   - Updates en patches toepassen zonder klantimpact
   - Node drain en pod migration als standaard

### 2.3 Realistische Verwachtingen

**Wat wél haalbaar is** (met Kubernetes):
- Zero-downtime deployments voor applicatielagen
- Automatische herstart van gefaalde pods
- Rolling updates met health checks
- Graduele traffic shift (canary/blue-green mogelijk in latere fase)

**Wat NIET haalbaar is** (zonder extra investeringen):
- 100% uptime — accepteer dat incidenten kunnen voorkomen
- Zero-downtime voor database schema migrations — vereist applicatiearchitectuur aanpassingen
- Instant failover bij datacenter failure — multi-region vereist (zie sectie 8)

### 2.4 Acceptatiecriteria

- [ ] Applicatie kan deployen zonder downtime (rolling update)
- [ ] Gefaalde pods worden binnen 30 seconden automatisch herstart
- [ ] Database downtime is **niet geëlimineerd**, maar **wel geïsoleerd** (applicatie blijft lopen met fallback-gedrag)
- [ ] Maintenance windows zijn **niet meer nodig** voor applicatie updates

---

## 3. Data-Kritikaliteit & Continuïteit

### 3.1 Grootste Angsten (Klant Input)
1. **Downtime**: Webshop is niet bereikbaar → direct omzetverlies
2. **Dataverlies**: Orders, klantgegevens, transacties kwijt → onherstelbaar

### 3.2 Huidige Backup Strategie
- Nachtelijke SQL backups
- **Beperking**: Point-in-time recovery is niet mogelijk
- **Risico**: Verlies van alle transacties sinds laatste backup

### 3.3 Layer 0 Eisen

**Data Classificatie**:
| Data Type | Kritikaliteit | RPO (Recovery Point Objective) | RTO (Recovery Time Objective) |
|-----------|---------------|-------------------------------|-------------------------------|
| **Orders & Transacties** | Business-kritisch | Max 15 minuten | Max 30 minuten |
| **Klantgegevens** | Hoog (GDPR) | Max 1 uur | Max 1 uur |
| **Product Catalogus** | Medium | Max 24 uur | Max 2 uur |
| **Sessie Data** | Laag (acceptabel verlies) | N/A | N/A |

**Backup Principes**:
- **Point-in-time recovery** is een harde eis
- **Geografische spreiding** van backups (niet in zelfde datacenter)
- **Getest restore proces** — backups zijn waardeloos als restore niet werkt
- **Encryption at rest** voor alle backups (GDPR compliance)

**Database Continuïteit**:
- **Single point of failure elimineren**:
  - SQL database moet HA zijn (replicatie, failover)
  - Read-replicas voor query load spreiding
- **Applicatiearchitectuur aanpassingen**:
  - Retry logica voor tijdelijke database failures
  - Circuit breaker pattern om cascading failures te voorkomen
  - Caching layer (Redis/Valkey) om database load te verlagen

**Wat NIET in Layer 0**:
- Specifieke backup tool keuze (Velero, Kasten, etc.) → Layer 1
- Exacte backup frequentie (elk uur, elke 4 uur) → Layer 1
- Database technology keuze (PostgreSQL HA, MySQL Cluster) → Layer 1

---

## 4. Security Baseline (Conceptueel)

### 4.1 Huidige Situatie
- Handmatige VM-configuratie → inconsistent security posture
- Geen systematische patching
- Toegangsbeheer onduidelijk gedocumenteerd

### 4.2 Layer 0 Security Principes

**1. Least Privilege**
- Developers hebben **geen** productie toegang (tenzij expliciet nodig)
- Operations heeft **namespace-scoped** toegang (niet cluster-admin voor alles)
- Service accounts hebben **minimal permissions** (niet `cluster-admin` voor applicaties)

**2. Defense in Depth**
- Security is **gelaagd** (niet afhankelijk van één control)
- Network policies (pod-to-pod communicatie beperken)
- Pod Security Standards (geen privileged containers zonder goede reden)
- Image scanning (kwetsbaarheden detecteren vóór deployment)

**3. Encryption**
- **In Transit**: TLS verplicht voor alle externe communicatie
- **At Rest**: Gevoelige data encrypted in database en backups
- **Secrets Management**: Geen credentials in Git, environment variables of plaintext ConfigMaps

**4. Audit & Compliance**
- **Wie deed wat wanneer**: Alle wijzigingen traceable (GitOps!)
- **GDPR compliance**: Data residency, right to be forgotten, data encryption
- **Audit logs**: Bewaard voor minimaal 1 jaar

**5. Supply Chain Security**
- **Image provenance**: Weten waar container images vandaan komen
- **Vulnerability scanning**: Blokker known CVEs
- **Image signing**: Verifieer authenticity (optioneel in eerste fase, maar architectuur moet het toestaan)

### 4.3 Security Ownership

| Verantwoordelijkheid | Eigenaar | Ondersteuning door |
|---------------------|----------|-------------------|
| **Platform security** (cluster hardening, RBAC, network policies) | Ops/Platform team | Security Officer |
| **Application security** (secure coding, dependency updates) | Development teams | Security Officer |
| **Incident response** | Ops team (first response) | Security Officer (escalatie) |
| **Compliance audits** | Security Officer | Ops + Dev (documentatie) |

---

## 5. Observability Verwachtingen

### 5.1 Huidige Situatie (Reactief)
- Problemen ontdekt via:
  - Klanten die bellen naar support
  - Medewerkers die "toevallig" iets merken
- Geen proactieve monitoring
- Geen duidelijk "single pane of glass"

### 5.2 Layer 0 Observability Eisen

**Proactieve Detectie**:
- **Voordat klanten het merken**: Alerts op kritieke metrics (response time, error rate, pod crashes)
- **Root cause analysis**: Kunnen achterhalen waarom iets fout ging
- **Trend analysis**: Langzame degradatie detecteren voordat het een incident wordt

**Drie Pilaren**:
1. **Metrics**: "Is het systeem gezond?" (CPU, memory, request latency, error rates)
2. **Logs**: "Wat gebeurde er precies?" (application logs, audit logs)
3. **Traces**: "Waar zit de bottleneck?" (request flow door microservices — niet nu, maar architectuur moet het toestaan)

**Self-Service voor Teams**:
- Developers kunnen **eigen dashboards** bekijken (geen afhankelijkheid van Ops)
- Support team kan **basis troubleshooting** doen zonder ops te betrekken

**Alerting Principles**:
- **Actionable**: Elke alert moet een duidelijke actie hebben (geen alert fatigue)
- **Context**: Alert bevat relevante info (welke pod, welke namespace, welke customer impact)
- **Routing**: Kritieke alerts → PagerDuty/ops on-call, warnings → Slack/Teams

### 5.3 Realistische Scope

**Wat WEL in Layer 0**:
- ✅ Observability is **niet-optioneel** — moet vanaf dag 1 aanwezig zijn
- ✅ Metrics, logs, en dashboards voor **alle workloads**
- ✅ Alerts voor **business-kritieke scenario's** (betaling faalt, webshop down)

**Wat NIET in Layer 0**:
- ❌ Tool keuze (Prometheus, Datadog, etc.) → Layer 1
- ❌ Exacte metrics en alert thresholds → Layer 1
- ❌ Distributed tracing (nice to have, kan later) → Layer 2

---

## 6. Ownership Model: Dev / Ops / Support

### 6.1 Huidige Situatie
- **Ops**: Eigenaar van productie, detecteert en lost incidenten op
- **Dev**: Levert code, beperkt betrokken bij productiegedrag
- **Support**: Eerste lijn contact met klanten, escaleert naar Ops

### 6.2 Layer 0 Ownership Principes

**Shared Responsibility Model**:

| Verantwoordelijkheid | Dev | Ops | Support |
|---------------------|-----|-----|---------|
| **Code kwaliteit** | ✅ Eigenaar | 🤝 Reviewt (code review, security scan) | ❌ |
| **Deployment** | ✅ Triggert (via GitOps) | 🤝 Faciliteert (platform beschikbaar) | ❌ |
| **Monitoring & Alerts** | ✅ Definieert application metrics | ✅ Definieert platform metrics | 🤝 Bekijkt dashboards |
| **Incident Detection** | 🤝 Application alerts | ✅ Platform alerts | 🤝 Customer reports |
| **Incident Response** | 🤝 Application issues | ✅ Platform issues | ✅ First line triage |
| **Post-Mortem** | ✅ Application root cause | ✅ Platform root cause | 🤝 Customer impact analysis |

**Operationeel Model**:
1. **Self-service voor Dev**:
   - Developers kunnen zelf deployen (via GitOps)
   - Developers kunnen logs en metrics bekijken
   - Developers hebben **geen** kubectl access tot productie (GitOps only)

2. **Ops als Platform Team**:
   - Ops bouwt en onderhoudt het Kubernetes platform
   - Ops definieert **guardrails** (resource limits, security policies)
   - Ops escaleert **niet** alle application issues terug naar Dev (clear ownership)

3. **Support als First Line**:
   - Support heeft **read-only** dashboards (is webshop bereikbaar, zijn er errors)
   - Support escaleert naar Ops (platform issue) of Dev (application issue)
   - Support heeft **geen** toegang tot systemen (alleen observability dashboards)

### 6.3 On-Call & Escalatie

**Layer 0 Principe**: Duidelijke escalatie paden, geen "alles naar Ops"

| Scenario | First Responder | Escalatie |
|---------|----------------|-----------|
| **Webshop onbereikbaar** | Ops (platform issue) | Dev (als applicatie de oorzaak is) |
| **Betaling faalt** | Dev (application logic) | Ops (als database down is) |
| **Slow performance** | Dev (query optimization) | Ops (als resource exhaustion) |
| **Security incident** | Ops (isoleer threat) | Security Officer + Dev |

**On-Call Rotatie** (buiten Layer 0 scope, maar principe vaststellen):
- Ops on-call voor **platform** (cluster down, node failures)
- Dev on-call voor **application** (bug in code, payment service down) — overweeg dit in latere fase

---

## 7. Strategische Eisen: Portability & Vendor Lock-in

### 7.1 Expliciete Klanteis
> "Vendor lock-in is een expliciete zorg. We willen binnen één kwartaal kunnen migreren naar een andere infrastructuurleverancier zonder functioneel verlies."

### 7.2 Layer 0 Portability Principes

**1. Cloud-Agnostic Architecture**
- **Geen afhankelijkheid van cloud-specific services** (AWS ECS, Azure Container Apps, GCP Cloud Run)
- **Kubernetes als portability layer**: Workloads draaien op standaard Kubernetes API's
- **Open-source tooling voorkeur**: Geen vendor SaaS waar mogelijk

**2. Infrastructure as Code**
- Volledige cluster + tooling **reproduceerbaar** via IaC (Terraform, Pulumi, etc.)
- **Geen handmatige configuratie** — alles in Git
- **Datacenter swap** is een `terraform apply` in andere omgeving (in theorie)

**3. Data Portability**
- **Backups cloud-agnostic**: S3-compatible API (niet AWS S3 API's die alleen op AWS werken)
- **Database**: Open-source (PostgreSQL, MySQL) → geen vendor-managed DB waar migratie moeilijk is
- **Object storage**: MinIO (self-hosted) of S3-compatible → geen Azure Blob/GCS lock-in

**4. Network & Identity Portability**
- **CNI keuze**: Open-source (Cilium, Calico) → geen cloud-native only solutions
- **Identity provider**: Self-hosted (Keycloak) of cloud-agnostic → geen AWS IAM / Azure AD exclusieve integraties
- **Load balancing**: Kubernetes Ingress (niet cloud-specific ALB/NLB configuraties)

### 7.3 Realistische Beperkingen en Concessies

**Wat WEL haalbaar is**:
- ✅ Workloads draaien op elke Kubernetes distributie (AKS, GKE, EKS, on-prem)
- ✅ IaC kan cluster reproduceren op andere cloud binnen 1 week
- ✅ Backups zijn portable (S3-compatible API)

**Wat NIET haalbaar is** (zonder concessies):
- ❌ Instant migration zonder enige aanpassing (DNS, IP's, load balancers veranderen altijd)
- ❌ Zero cloud-native features gebruiken (managed databases zijn soms wél de beste keuze voor HA — afweging maken)

### 7.4 Tooling Lock-in Risico Matrix

| Tool Category | Hoog Risico (Vermijd) | Laag Risico (Acceptabel) |
|---------------|----------------------|-------------------------|
| **Compute** | AWS ECS, Azure Container Apps | Kubernetes (overal beschikbaar) |
| **Database** | AWS Aurora (proprietary), Azure Cosmos | PostgreSQL HA, MySQL Cluster |
| **Object Storage** | AWS S3 API's (zonder S3-compatible fallback) | MinIO, S3-compatible cloud storage |
| **Identity** | AWS IAM only, Azure AD only | Keycloak (self-hosted), OIDC providers |
| **Networking** | AWS VPC CNI (EKS-only) | Cilium, Calico (cloud-agnostic) |
| **GitOps** | Vendor SaaS (zonder export) | Argo CD, Flux (self-hosted) |

**Layer 0 Beslissing**: **Open-source en self-hosted voorkeur**, tenzij managed service duidelijk voordeel heeft (en migration path bestaat).

---

## 8. Fundamentele Architectuurbeslissingen (Multi-Region, Networking, Identity)

### 8.1 Multi-Region / Multi-Cluster

**Huidige eis**: Klanten door heel Europa, website traag vanuit Zuid-Europa.

**Layer 0 Vraag**: Willen we multi-region vanaf dag 1?

**Analyse**:
- **Voordeel**: Lagere latency, disaster recovery
- **Nadeel**: Complexiteit (data replicatie, cross-region networking, kosten)

**Layer 0 Beslissing**:
- ❌ **NIET multi-region vanaf dag 1** (te complex voor organisatie zonder Kubernetes ervaring)
- ✅ **Wel architectuur die multi-region toestaat** (geen design decisions die multi-region blokkeren)
- ✅ **CDN voor static assets** (eerste stap voor latency verbetering) → Layer 1 beslissing

**Criteria voor multi-region in toekomst**:
- [ ] Single-region setup is stabiel (> 3 maanden zonder major incidents)
- [ ] Team heeft ervaring met Kubernetes operations
- [ ] Business case is helder (hoeveel omzet winnen we met lagere latency?)

### 8.2 Networking & CNI Overwegingen

**Layer 0 Vraag**: Welke CNI fundamenten zijn niet te veranderen?

**Analyse**:
| CNI Keuze | Veranderbaarheid | Impact |
|-----------|------------------|--------|
| **CNI plugin** (Cilium, Calico, Flannel) | Zeer moeilijk (vereist cluster rebuild of downtime) | ❗ Layer 0 beslissing |
| **Service Mesh** (Istio, Linkerd) | Moeilijk maar mogelijk (additive) | ⚠️ Layer 0/1 grens — niet nodig vanaf dag 1 |
| **Network Policies** (enabled/disabled) | Makkelijk achteraf in te schakelen | ✅ Layer 1 beslissing |

**Layer 0 Beslissingen**:
- ✅ **CNI moet multi-region capabel zijn** (geen single-zone only solutions)
- ✅ **CNI moet Network Policies ondersteunen** (security requirement)
- ✅ **Performance is belangrijk** (webshop moet snel zijn)
- ❌ **Service mesh is NIET een Layer 0 requirement** (kan later, als microservices architectuur)

**Criteria voor CNI keuze** (tooling in Layer 1):
- Ondersteunt Network Policies (security)
- Cloud-agnostic (portability)
- Performance (eBPF voorkeur boven iptables)
- Community support (niet single-vendor)

### 8.3 Identity & Access Management

**Layer 0 Vraag**: Hoe authenticeren we mensen en machines?

**Fundamentele Keuzes**:
1. **User Authentication**: Hoe loggen developers/ops in op cluster?
   - **Optie A**: kubeconfig files (simpel, maar niet schaalbaar)
   - **Optie B**: OIDC provider (Keycloak, cloud IdP) — schaalbaar, audit trails
   - **Layer 0 Beslissing**: **OIDC is eindstaat**, maar kubeconfig files zijn acceptabel voor eerste maanden (team is klein)

2. **Service Account Management**: Hoe authenticeren applicaties?
   - **Principe**: Elke applicatie krijgt **eigen service account** (geen gedeelde secrets)
   - **Principe**: Service accounts hebben **minimal permissions** (namespace-scoped)
   - **Layer 0 Beslissing**: **RBAC is mandatory** vanaf dag 1

3. **Secrets Management**: Waar slaan we credentials op?
   - **Principe**: **Nooit in Git** (ook niet encrypted — rotatie is te moeilijk)
   - **Principe**: **External secrets** voorkeur (Vault, cloud secret managers)
   - **Layer 0 Beslissing**: **Secrets management is Layer 0** — moet vanaf dag 1 goed zijn (moeilijk te fixen later)

**Identity Provider Beslissing**:
- ✅ **Self-hosted voorkeur** (Keycloak) voor vendor independence
- ⚠️ **Cloud IdP acceptabel** als self-hosted te complex is (pragmatisme)
- ❌ **Geen kubeconfig files langetermijn** (niet schaalbaar, geen audit trail)

### 8.4 GitOps: Yes or No?

**Layer 0 Vraag**: Is GitOps een fundamenteel principe, of "nice to have"?

**Argumenten voor GitOps**:
- ✅ **Audit trail**: Alle wijzigingen in Git (compliance)
- ✅ **Rollback**: Git revert = rollback deployment
- ✅ **Declarative**: Gewenste staat in Git, Kubernetes convergeert ernaar
- ✅ **Self-service**: Developers deployen via PR (geen kubectl access nodig)

**Argumenten tegen GitOps**:
- ⚠️ **Learning curve**: Team moet Git, PR workflows, en GitOps tool leren
- ⚠️ **Initial complexity**: Repo structuur, branching strategy, environments

**Layer 0 Beslissing**: 
- ✅ **GitOps is Layer 0 principe** — te fundamenteel voor workflow om later toe te voegen
- ✅ **Alle deployments via Git** (geen kubectl apply handmatig)
- ✅ **Architectuur moet GitOps ondersteunen** vanaf dag 1

**Rationale**: Zonder GitOps is er geen audit trail, geen reproduceerbare deployments, en te veel kubectl toegang nodig (security risk).

---

## 9. Wat NIET in Layer 0 Thuishoort

Layer 0 is **fundamenteel en strategisch**, niet tactisch. De volgende zaken horen **niet** in Layer 0:

### 9.1 Concrete Tool Keuzes
- ❌ "We gebruiken Cilium" → Dit is Layer 1 (na analyse van CNI requirements)
- ❌ "We gebruiken Argo CD" → Dit is Layer 1 (na analyse van GitOps requirements)
- ✅ "We hebben een CNI nodig die Network Policies ondersteunt" → Dit is Layer 0

### 9.2 Operationele Details
- ❌ Backup frequentie (elk uur, elke 4 uur) → Layer 1
- ❌ Prometheus retention (15 dagen, 30 dagen) → Layer 1
- ✅ "Backups moeten point-in-time recovery ondersteunen" → Layer 0

### 9.3 Implementatie Specificaties
- ❌ Hoeveel nodes, welke instance types → Layer 1 (sizing)
- ❌ Welke namespaces, welke resource quotas → Layer 1 (multi-tenancy design)
- ✅ "Resources moeten beperkt zijn om resource exhaustion te voorkomen" → Layer 0

### 9.4 Features die Later Kunnen
- ❌ Service mesh (Istio, Linkerd) → Layer 2 (kan later, als microservices architectuur)
- ❌ Chaos engineering (Chaos Mesh) → Layer 2 (waardevol, maar niet foundational)
- ❌ Advanced observability (distributed tracing) → Layer 2 (metrics en logs eerst)
- ✅ "Observability moet proactief zijn" → Layer 0

---

## 10. Aannames die Gevalideerd Moeten Worden (in Volgende Lagen)

Layer 0 maakt **strategische keuzes**, maar niet alles is nu bekend. De volgende aannames moeten gevalideerd worden in Layer 1 en verder:

### 10.1 Applicatie Architectuur Aannames

**Aanname**: Huidige MVC monoliet kan **zonder refactor** naar Kubernetes.
- **Validatie nodig**: 
  - [ ] Is de applicatie **stateless** (sessies in database/Redis, niet in geheugen)?
  - [ ] Kan de applicatie **horizontaal schalen** (meerdere replica's zonder problemen)?
  - [ ] Zijn er **hardcoded localhost/IP afhankelijkheden** (database connectiestrings, etc.)?

**Aanname**: Database migratie naar Kubernetes is gewenst.
- **Validatie nodig**:
  - [ ] Is het beter om database **buiten Kubernetes** te houden (beheerde cloud database)?
  - [ ] Wat is de inspanning van database HA-configuratie (replicatie, failover)?
  - [ ] Is StatefulSet voldoende, of hebben we een Kubernetes Operator nodig?

**Aanname**: Geen microservices architectuur **nu**, maar moet mogelijk zijn **later**.
- **Validatie nodig**:
  - [ ] Welke delen van de monoliet kunnen als eerste uitgesplitst worden (bijv. search, payment)?
  - [ ] Is async messaging nodig (NATS, Kafka) of blijft alles synchroon?

### 10.2 Datacenter & Infrastructuur Aannames

**Aanname**: Nederlandse datacenter leverancier biedt **Kubernetes-compatibele infrastructuur**.
- **Validatie nodig**:
  - [ ] Is er beheerde Kubernetes beschikbaar, of zelf-gehost (Kubeadm, RKE)?
  - [ ] Welke storage opties zijn beschikbaar (block storage, NFS, object storage)?
  - [ ] Welke netwerk features zijn beschikbaar (load balancers, VPC, etc.)?

**Aanname**: Multi-cloud is **niet nodig**, maar vendor switch moet mogelijk zijn.
- **Validatie nodig**:
  - [ ] Hoe makkelijk is het om cluster te reproduceren bij andere leverancier?
  - [ ] Welke datacenter-specifieke features gebruiken we (en accepteren we dat lock-in)?

### 10.3 Team & Organisatie Aannames

**Aanname**: Team heeft **geen Kubernetes ervaring**, maar wil leren.
- **Validatie nodig**:
  - [ ] Hoeveel training is nodig (1 week, 1 maand)?
  - [ ] Kunnen we externe consultants inzetten voor initiële setup?
  - [ ] Wat is de ramp-up tijd voor self-sufficiency?

**Aanname**: Essential SAFe proces past bij GitOps workflow.
- **Validatie nodig**:
  - [ ] Hoe mappen we sprints naar Git branching strategy?
  - [ ] Wie approved productie deployments (PO, tech lead, ops)?
  - [ ] Hoe gaan we om met hotfixes (direct naar prod of via staging)?

### 10.4 Security & Compliance Aannames

**Aanname**: GDPR compliance is voldoende, geen extra compliance regimes (PCI-DSS, ISO 27001).
- **Validatie nodig**:
  - [ ] Zijn er betaalgegevens die PCI-DSS vereisen (of is payment extern — Stripe/Mollie)?
  - [ ] Zijn er industriespecifieke compliance eisen (medical devices, financial services)?

**Aanname**: Huidige security posture is "goed genoeg" voor migratie naar Kubernetes.
- **Validatie nodig**:
  - [ ] Zijn er bekende vulnerabilities in huidige stack (OS patches, library updates)?
  - [ ] Moeten we security audit doen **voor** migratie (baseline vaststellen)?

---

## 11. Samenvattend: Layer 0 Beslisboom

Voordat je verder gaat naar Layer 1 (tool selectie), moeten deze vragen **duidelijk beantwoord** zijn:

### ✅ Beschikbaarheid
- [ ] **Zero-downtime deployments zijn een eis** (rolling updates, health checks)
- [ ] **High availability voor kritieke componenten** (database, load balancer)
- [ ] **Accepteer dat 100% uptime niet haalbaar is** (realistisch)

### ✅ Data
- [ ] **Point-in-time recovery is mandatory** (niet alleen nachtelijke backups)
- [ ] **Geografische backup spreiding** (niet in zelfde datacenter als productie)
- [ ] **Tested restore proces** (backups zijn waardeloos als restore niet werkt)

### ✅ Security
- [ ] **Least privilege principe** (developers geen productie toegang, service accounts minimal permissions)
- [ ] **Defense in depth** (security is gelaagd, niet single control)
- [ ] **Encryption in transit en at rest** (TLS, database encryption, backup encryption)
- [ ] **Secrets management vanaf dag 1** (niet in Git, niet in plaintext)

### ✅ Observability
- [ ] **Proactieve monitoring** (niet reactief via klanten)
- [ ] **Metrics, logs, dashboards voor alle workloads** (geen blind spots)
- [ ] **Self-service voor teams** (developers kunnen eigen dashboards bekijken)

### ✅ Ownership
- [ ] **Shared responsibility model** (dev + ops, niet "alles naar ops")
- [ ] **Self-service deployment** (GitOps, geen kubectl access)
- [ ] **Clear escalatie paden** (niet "alles naar ops")

### ✅ Portability
- [ ] **Cloud-agnostic architectuur** (geen vendor lock-in)
- [ ] **Infrastructure as Code** (reproduceerbaar)
- [ ] **Open-source tooling voorkeur** (tenzij managed service duidelijk voordeel heeft)

### ✅ Fundamentele Architectuur
- [ ] **GitOps is een principe** (alle deployments via Git)
- [ ] **CNI moet Network Policies ondersteunen** (security)
- [ ] **RBAC is mandatory** (geen cluster-admin voor iedereen)
- [ ] **Multi-region is toekomstige mogelijkheid** (niet dag 1, maar architectuur blokkeert het niet)

---

## 12. Volgende Stappen: Van Layer 0 naar Layer 1

Nu Layer 0 is vastgelegd, kan Layer 1 beginnen:

### Layer 1 Scope (Binnen 1-2 Weken)
- **Tool selectie**: Welke concrete tools (Cilium vs Calico, Argo CD vs Flux, etc.)
- **Cluster sizing**: Hoeveel nodes, welke instance types
- **Network design**: Subnets, load balancers, DNS
- **Storage design**: Welke StorageClasses, backup strategie
- **Security design**: RBAC rollen, network policies, pod security standards

### Layer 1 Deliverables
- Architectuur diagram (netwerk, storage, observability)
- Tool selection matrix (met rationale per keuze)
- Proof of Concept planning (welke features testen we eerst)

### Layer 2 Scope (Maand 2-3)
- Implementatie van platform (cluster setup, tooling installatie)
- Migratie van eerste applicatie (test workload)
- Team training (Kubernetes basics, GitOps workflow)
- Production cutover planning

---

## Bijlage: Referenties naar KubeCompass Framework

Dit Layer 0 document is gebaseerd op de KubeCompass methodologie:

- **[FRAMEWORK.md](FRAMEWORK.md)**: Decision layers uitleg (Layer 0, 1, 2)
- **[METHODOLOGY.md](METHODOLOGY.md)**: Objectiviteit en scoring rubric
- **[SCENARIOS.md](SCENARIOS.md)**: Enterprise multi-tenant scenario (vergelijkbaar met deze case)
- **[PRODUCTION_READY.md](PRODUCTION_READY.md)**: Compliance en maturity progression

**Belangrijkste verschil met Enterprise Scenario**:
- Enterprise scenario: 200-500 medewerkers, compliance (ISO 27001, SOC 2), 10-20 teams
- Deze case: Kleiner team, geen strikte compliance, maar wel business-kritisch

**Relevante KubeCompass Principes**:
- ✅ **Layer 0 first**: Fundamenten vastleggen voordat tools kiezen
- ✅ **Vendor neutraliteit**: Open-source voorkeur, geen lock-in
- ✅ **Pragmatisme**: Niet alle enterprise features zijn nodig (KISS)
- ✅ **Business impact**: Beslissingen gebaseerd op business waarde, niet tech hype

---

**Document Status**: ✅ Gereed voor review met engineers, architecten, en management  
**Volgende Stap**: Layer 1 tool selectie en architectuur design  
**Eigenaar**: Platform Team / Lead Architect  
**Review Cyclus**: Na elke 3 maanden (Layer 0 evolueert met business behoeften)
