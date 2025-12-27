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

## Executive Summary

### Situatie
Nederlandse webshop met Essential SAFe organisatie (meerdere teams: Dev, Ops, Functioneel Beheer, Support) migreert van handmatige VM-deployments naar Kubernetes. Bedrijf verkoopt fysieke producten met eigen verzending door Europa. Downtime tijdens checkout = direct omzetverlies.

### Huidige Pijnpunten
- ✋ Handmatige releases (alleen maandagnacht, met downtime)
- 🚨 Reactieve incident detectie (klanten bellen, toevallige ontdekking)
- 💾 Nachtelijke backups zonder point-in-time recovery
- 🗄️ SQL database als single point of failure
- 🔧 Inconsistente VM-configuratie zonder systematische patching

### Strategische Doelen (Layer 0)
1. **Zero-downtime deployments** — deployen wanneer klaar is, niet wanneer "mag"
2. **Proactieve monitoring** — problemen detecteren voordat klanten bellen
3. **Data resilience** — point-in-time recovery, geen transactieverlies
4. **Vendor independence** — migratie naar andere provider binnen 1 kwartaal mogelijk
5. **Clear ownership** — Dev, Ops en Support weten wie waarvoor verantwoordelijk is

### Fundamentele Principes (Niet-Onderhandelbaar)
- 🔐 **Security by design** — Least privilege, defense in depth, encryption
- 🔓 **Open-source voorkeur** — Geen vendor lock-in, reproduceerbare architectuur
- 📝 **GitOps vanaf dag 1** — Alle deployments via Git, geen handmatig kubectl
- 👥 **Shared responsibility** — Dev + Ops samenwerking, niet "alles naar Ops"
- 🎯 **Business impact driven** — Beslissingen gebaseerd op omzetrisico, niet tech hype

### Kritieke Succes Criteria
| Criterium | Doel | Huidige Situatie |
|-----------|------|-----------------|
| **Deployment downtime** | 0 minuten (rolling updates) | 1-4 uur per release |
| **Incident detectie** | < 2 minuten (alerts) | 10-60 minuten (klanten bellen) |
| **Data recovery** | Point-in-time (max 15 min verlies) | Laatste nachtelijke backup |
| **Vendor migration tijd** | < 1 kwartaal | Onbekend / niet getest |
| **Developer self-service** | Deploy via Git PR | Ops doet handmatig |

---

## Expliciete Doelen (Goals)

### Primaire Doelen
1. **Eliminate Deployment Downtime**
   - Zero-downtime releases via rolling updates
   - Deploy when features are ready, not when "downtime is allowed"
   - Rollback capability within minutes

2. **Proactive Operations**
   - Detect issues before customers notice
   - Automated recovery for common failures
   - Clear dashboards for all teams (Dev, Ops, Support)

3. **Data Protection & Recovery**
   - Point-in-time recovery voor kritieke data (orders, klantgegevens)
   - Geografisch gespreide backups
   - Tested restore procedures (backups zijn waardeloos als restore niet werkt)

4. **Vendor Independence**
   - Migratie naar andere cloud provider binnen 1 kwartaal
   - Open-source tooling voorkeur
   - Infrastructure as Code voor reproduceerbare omgevingen

5. **Clear Team Ownership**
   - Developers kunnen zelf deployen (via GitOps)
   - Operations faciliteert platform (geen bottleneck)
   - Support heeft inzicht zonder systeem access

### Secundaire Doelen
- Systematische patching en updates (niet ad-hoc)
- Audit trail voor compliance (wie deed wat wanneer)
- Foundation voor toekomstige multi-region (niet dag 1, maar architectuur blokkeert het niet)
- Developer productivity (sneller itereren, minder wachten op Ops)

---

## Expliciete Non-Goals (Buiten Scope Layer 0)

### Wat We NIET Doen (Nu)
1. **Microservices Refactoring** ❌
   - Huidige MVC monoliet blijft intact
   - Focus: lift & shift naar Kubernetes
   - Microservices zijn toekomstige optie, geen Layer 0 requirement

2. **Multi-Region Deployment** ❌
   - Te complex voor organisatie zonder Kubernetes ervaring
   - Single region met optie voor latere expansie
   - CDN voor static assets is voldoende voor latency verbetering

3. **Advanced Observability** ❌
   - Distributed tracing is nice-to-have, niet foundational
   - Focus op metrics en logs eerst
   - Tracing kan later (Layer 2)

4. **Service Mesh** ❌
   - Niet nodig voor monolithische applicatie
   - Kan later bij microservices transitie
   - Architectuur moet service mesh toestaan, maar niet implementeren

5. **100% Uptime Garantie** ❌
   - Realistisch: incidenten kunnen gebeuren
   - Focus: minimize downtime, niet eliminate
   - Accepteer dat maintenance en incidents impact hebben

6. **Immediate Developer Kubernetes Access** ❌
   - Developers krijgen GEEN kubectl access (security)
   - GitOps is enige deployment methode
   - Read-only dashboards wel beschikbaar

### Waarom Dit Belangrijk Is
Non-goals voorkomen **scope creep** en **analysis paralysis**. Teams hebben neiging om "alvast" voor de toekomst te bouwen, wat leidt tot over-engineering en vertraging. Layer 0 is pragmatisch: doe wat nodig is, niet wat leuk is.

---

## Harde Randvoorwaarden (Hard Constraints)

### Niet-Onderhandelbare Eisen

#### 1. Vendor Independence
- **Constraint**: Migratie naar andere infrastructuur leverancier moet binnen **1 kwartaal** mogelijk zijn
- **Implicatie**: Geen afhankelijkheid van cloud-specific services (AWS ECS, Azure Container Apps, etc.)
- **Validatie**: Infrastructure as Code moet reproduceerbaar zijn op andere cloud

#### 2. Data Sovereignty & GDPR
- **Constraint**: Klantgegevens moeten binnen EU blijven
- **Implicatie**: Datacenter keuze beperkt tot EU regio's
- **Validatie**: Backup storage moet ook EU-compliant zijn

#### 3. Business Continuity
- **Constraint**: Checkout functionaliteit is **business-kritisch**
  - Max acceptable downtime: **30 minuten per maand** (99.9% uptime target)
  - Max acceptable data loss (RPO): **15 minuten** voor transacties
  - Max recovery time (RTO): **30 minuten** voor kritieke systemen
- **Implicatie**: High availability voor database en applicatie verplicht

#### 4. Security Baseline
- **Constraint**: Geen productie toegang voor developers (compliance requirement)
- **Implicatie**: GitOps is enige deployment methode (no kubectl apply)
- **Validatie**: RBAC policies moeten dit afdwingen

#### 5. Operational Ownership
- **Constraint**: Operations blijft eigenaar van productie omgeving
- **Implicatie**: Developers kunnen zelf deployen, maar Ops bepaalt guardrails (resource limits, security policies)
- **Validatie**: Platform team heeft final say over cluster configuratie

#### 6. Budget Realisme
- **Constraint**: Geen enterprise SaaS budgets (Datadog, New Relic, etc.)
- **Implicatie**: Open-source tooling voorkeur
- **Validatie**: Keuzes moeten verantwoord zijn zonder vendor support contracts

#### 7. Team Maturity
- **Constraint**: Team heeft **geen Kubernetes ervaring** (training nodig)
- **Implicatie**: Start simpel, geen complexe multi-cluster setups
- **Validatie**: Operationeel model moet haalbaar zijn voor team van ~10 mensen

### Trade-offs die We Accepteren

| Trade-off | Keuze | Rationale |
|-----------|-------|-----------|
| **Managed Kubernetes vs. Self-hosted** | Managed (bij Nederlandse provider) | Team heeft geen ervaring; managed reduceert operationele last |
| **Managed Database vs. Kubernetes StatefulSet** | TBD in Layer 1 | Afweging tussen vendor independence en operational complexity |
| **Open-source vs. SaaS observability** | Open-source (Prometheus/Grafana) | Budget + vendor independence |
| **GitOps complexity vs. Control** | Accepteer learning curve | Security en audit trail rechtvaardigen investering |

---

## Expliciete Risico's & Mitigaties

### Hoog Risico (Moet Gemitigeerd Worden)

#### 1. Team Heeft Geen Kubernetes Ervaring
- **Risico**: Verkeerde architectuur keuzes, operationele blunders, lange learning curve
- **Impact**: Downtime, security incidents, frustratie
- **Mitigatie**:
  - [ ] Externe Kubernetes consultant voor initiële setup (3-6 maanden)
  - [ ] Training voor team (officiële cursussen + hands-on workshops)
  - [ ] Proof of Concept in non-productie omgeving eerst
  - [ ] Uitgebreide documentatie en runbooks

#### 2. Database Migratie is Complex
- **Risico**: SQL database is single point of failure; migratie naar HA setup is complex
- **Impact**: Downtime tijdens migratie, potentieel dataverlies
- **Mitigatie**:
  - [ ] Start met lees-replicas (geen failover) voor query load spreiding
  - [ ] Test restore procedures extensief in non-prod
  - [ ] Overweeg managed database (cloud provider) voor HA capabilities
  - [ ] Schema migrations moeten backward compatible zijn (blue-green capable)

#### 3. Vendor Lock-in Per Ongeluk
- **Risico**: Gebruik van vendor-specific features "omdat het makkelijk is"
- **Impact**: Kan niet migreren binnen 1 kwartaal (hard constraint breach)
- **Mitigatie**:
  - [ ] Architectuur review board (Ops + externe consultant)
  - [ ] Expliciet "portability checklist" bij elke tool keuze
  - [ ] Infrastructure as Code vanaf dag 1 (geen handmatige configuratie)
  - [ ] Quarterly review: "Kunnen we nog steeds migreren?"

#### 4. GitOps Workflow Breekt Bestaand Proces
- **Risico**: Essential SAFe proces past niet bij GitOps branching strategy
- **Impact**: Confusion, workarounds, handmatig kubectl gebruik (security risk)
- **Mitigatie**:
  - [ ] Map SAFe sprints naar Git workflow (trunk-based vs. GitFlow)
  - [ ] Duidelijke escalatie pad voor hotfixes (bypass normale PR flow?)
  - [ ] Training voor PO's en functioneel beheer (niet alleen engineers)
  - [ ] Pilot met 1 team eerst, dan roll-out naar andere teams

### Medium Risico (Monitor & Plan)

#### 5. Observability Overwhelm
- **Risico**: Te veel metrics, alerts, dashboards → alert fatigue
- **Impact**: Echte problemen worden gemist in de noise
- **Mitigatie**:
  - [ ] Start met basics: uptime, error rate, response time
  - [ ] Iteratief alerts toevoegen (niet alles dag 1)
  - [ ] Alert review elke sprint (disable irrelevante alerts)

#### 6. Costs Escaleren
- **Risico**: Cloud kosten hoger dan verwacht (storage, egress, compute)
- **Impact**: Budget overschrijding, management ontevreden
- **Mitigatie**:
  - [ ] Cost monitoring vanaf dag 1 (OpenCost / Kubecost)
  - [ ] Resource limits per namespace (geen unbounded growth)
  - [ ] Monthly cost review met management

#### 7. Security Gaps in Migratie
- **Risico**: VM security model != Kubernetes security model
- **Impact**: Onbedoelde attack surface, compliance issues
- **Mitigatie**:
  - [ ] Security assessment van huidige VM setup (baseline)
  - [ ] Network policies vanaf dag 1 (deny-all default)
  - [ ] Image scanning in CI/CD (geen known CVEs in prod)

### Laag Risico (Acceptabel)

#### 8. Multi-Region Latency (Zuid-Europa)
- **Risico**: Klanten in Spanje/Italië hebben langzamere ervaring
- **Impact**: Lagere conversie, klachten
- **Acceptatie**: Single region is bewuste keuze (complexiteit vs. business impact)
- **Future Plan**: CDN eerst, multi-region later (na 6-12 maanden Kubernetes ervaring)

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

## 12. Gerichte Vervolgvragen voor Layer 1 Transitie

Voordat je Layer 1 (concrete tool selectie en platform capabilities) kan beginnen, moeten de volgende vragen beantwoord worden. Deze vragen zijn **specifiek genoeg** om technische beslissingen te informeren, maar **abstract genoeg** om nog geen tools te kiezen.

### 12.1 Applicatie Architectuur & Readiness

#### Database & Stateful Workloads
- **Q1**: Is de huidige MVC applicatie **stateless**?
  - Worden sessies opgeslagen in database/Redis, of in applicatie geheugen?
  - Impact: Bepaalt of horizontale scaling mogelijk is zonder code wijzigingen

- **Q2**: Waar draait de SQL database?
  - In dezelfde VM als applicatie, of dedicated database server?
  - Impact: Bepaalt migratie strategie (StatefulSet vs. externe managed database)

- **Q3**: Wat is de huidige database size en load?
  - Hoeveel GB data, hoeveel queries per seconde?
  - Impact: Storage sizing, HA strategie (lees-replicas, sharding)

- **Q4**: Zijn database schema migrations backward compatible?
  - Kan oude applicatie versie werken met nieuwe database schema?
  - Impact: Bepaalt of blue-green deployments mogelijk zijn

#### Applicatie Dependencies
- **Q5**: Gebruikt de applicatie **hardcoded localhost references**?
  - Database connectiestrings, cache URLs, externe API endpoints?
  - Impact: Moet code aangepast worden voor Kubernetes service discovery?

- **Q6**: Wat zijn de externe dependencies?
  - Payment providers (Stripe, Mollie), shipping APIs, email services?
  - Impact: Network policies, egress filtering, secret management

- **Q7**: Hoeveel resources gebruikt de applicatie?
  - CPU, memory, disk I/O (metrics van huidige VM)?
  - Impact: Pod resource requests/limits, node sizing

### 12.2 Infrastructuur & Datacenter Mogelijkheden

#### Nederlandse Cloud Provider Capabilities
- **Q8**: Welke Kubernetes distributie biedt de provider?
  - Managed Kubernetes (bijv. OpenShift, Rancher), of IaaS VMs (zelf Kubeadm)?
  - Impact: Operationele complexiteit, upgrade strategie

- **Q9**: Welke storage opties zijn beschikbaar?
  - Block storage (persistent volumes), NFS, object storage (S3-compatible)?
  - Impact: StorageClass keuzes, backup strategie

- **Q10**: Welke netwerk features zijn beschikbaar?
  - Load balancers (Layer 4, Layer 7), floating IPs, private VPC?
  - Impact: Ingress controller keuze, external-dns mogelijkheden

- **Q11**: Is er geografische replicatie mogelijk?
  - Meerdere datacenters binnen NL, of ook andere EU landen?
  - Impact: Multi-region strategie, backup georedundancy

- **Q12**: Wat is het SLA van de infrastructuur provider?
  - Uptime garanties, support response times?
  - Impact: Realistische availability targets voor applicatie

#### Kosten & Budgetten
- **Q13**: Wat is het huidige maandelijkse infrastructuur budget?
  - VM kosten, storage, bandwidth?
  - Impact: Cluster sizing, managed vs. self-hosted trade-offs

- **Q14**: Wat is het budget voor tooling en SaaS?
  - Kunnen we managed services betalen (bijv. managed Prometheus, managed Vault)?
  - Impact: Open-source self-hosted vs. managed service keuzes

### 12.3 Team & Organisatie

#### Team Skills & Capaciteit
- **Q15**: Hoeveel FTE heeft het Ops team?
  - Kunnen ze platform maintenance doen naast BAU werk?
  - Impact: Managed Kubernetes vs. self-hosted, automation priorities

- **Q16**: Wat is de huidige Git workflow?
  - Trunk-based, GitFlow, feature branches?
  - Impact: GitOps branching strategy, environment promotions

- **Q17**: Zijn er dedicated security engineers?
  - Of is security onderdeel van Ops team?
  - Impact: Security tooling complexity (self-managed OPA vs. simpelere alternatieven)

#### Deployment & Release Proces
- **Q18**: Hoe vaak wil de business releases doen?
  - Dagelijks, wekelijks, per sprint?
  - Impact: CI/CD pipeline design, deployment frequency targets

- **Q19**: Wie approved productie deployments?
  - PO, tech lead, ops team, of geautomatiseerd (na tests)?
  - Impact: GitOps approval workflows, manual gates

- **Q20**: Hoe gaan we om met hotfixes?
  - Direct naar prod, of via normale staging flow?
  - Impact: Emergency deployment procedures, GitOps bypass policies

### 12.4 Security & Compliance

#### Security Posture Baseline
- **Q21**: Welke security controls zijn er nu?
  - Firewalls, IDS/IPS, antivirus, patching schedule?
  - Impact: Equivalent controls in Kubernetes (network policies, runtime security)

- **Q22**: Is er PCI-DSS compliance nodig?
  - Worden credit card gegevens opgeslagen, of is payment extern (Stripe/Mollie)?
  - Impact: Strengere security controls, audit logging, encryption requirements

- **Q23**: Wie heeft nu toegang tot productie?
  - Welke teams, welke personen, welke access level?
  - Impact: RBAC design, audit logging, break-glass procedures

#### Secrets & Credentials
- **Q24**: Waar worden secrets nu opgeslagen?
  - Environment variables, config files, dedicated secret store?
  - Impact: Kubernetes secrets management strategie

- **Q25**: Hoe vaak moeten credentials geroteerd worden?
  - Maandelijks, per kwartaal, ad-hoc?
  - Impact: Secret rotation automation, external secret store keuze

### 12.5 Observability & Alerting

#### Huidige Monitoring
- **Q26**: Wat wordt er nu gemonitor'd (als iets)?
  - Uptime checks, resource utilization, application metrics?
  - Impact: Baseline voor nieuwe observability stack

- **Q27**: Welke metrics zijn business-kritisch?
  - Checkout conversie rate, order processing time, payment success rate?
  - Impact: Custom application metrics, business dashboards

- **Q28**: Wie moet alerts ontvangen?
  - Ops on-call, dev team, support team (voor verschillende alert types)?
  - Impact: Alerting routing rules, escalation policies

#### Incident Management
- **Q29**: Wat is de huidige incident response procedure?
  - Runbooks, escalatie matrix, postmortem proces?
  - Impact: Observability tool keuzes (moet integreren met bestaand proces)

- **Q30**: Hoe wordt customer impact nu gecommuniceerd?
  - Status page, email, support team belt klanten?
  - Impact: Status page integratie, automated incident detection

### 12.6 Data Protection & Backup

#### Backup Requirements
- **Q31**: Wat is de huidige backup retention policy?
  - Dagelijks voor 7 dagen, wekelijks voor 1 maand, etc.?
  - Impact: Backup storage sizing, retention automation

- **Q32**: Zijn backups encrypted?
  - At rest encryption, encryption keys management?
  - Impact: Backup tool keuze, KMS integration

- **Q33**: Hoe vaak worden restores getest?
  - Maandelijks, per kwartaal, nooit?
  - Impact: Disaster recovery testing procedures

#### Disaster Recovery
- **Q34**: Wat is acceptable data loss voor verschillende data types?
  - Orders (15 min), product catalog (24 uur), sessies (acceptabel verlies)?
  - Impact: Backup frequency, replication strategy

- **Q35**: Wat is de acceptable recovery time?
  - Hoeveel uren/dagen mag het duren om van disaster te recoveren?
  - Impact: DR automation, documented recovery procedures

### 12.7 Migration & Cutover

#### Migration Strategy
- **Q36**: Is er een staging omgeving beschikbaar?
  - Kunnen we eerst non-prod migreren om te leren?
  - Impact: Phased migration vs. big bang

- **Q37**: Kunnen we blue-green deployment doen tijdens cutover?
  - Oude en nieuwe systeem parallel draaien, traffic switch?
  - Impact: DNS strategy, rollback plan

- **Q38**: Wat is acceptable downtime tijdens migratie?
  - Zero downtime (complex), of geplande maintenance window (simpeler)?
  - Impact: Migration strategie complexity

#### Rollback Planning
- **Q39**: Wat is het rollback scenario als Kubernetes migratie faalt?
  - Terug naar oude VMs (zijn die nog beschikbaar?)
  - Impact: Keep old infrastructure alive for X months

- **Q40**: Hoe snel moeten we kunnen rollback?
  - Binnen 1 uur, binnen 1 dag?
  - Impact: Automation level van rollback procedures

---

### Samenvatting: Layer 0 → Layer 1 Readiness Checklist

✅ **Klaar voor Layer 1** als:
- [ ] Alle 40 bovenstaande vragen zijn beantwoord (of expliciet gemarkeerd als "TBD in Layer 1")
- [ ] Business context is helder (wie zijn de stakeholders, wat zijn hun pijnpunten)
- [ ] Hard constraints zijn gedocumenteerd (vendor independence, GDPR, budget)
- [ ] Risico's zijn geïdentificeerd met mitigatie plannen
- [ ] Team capabilities zijn realistisch ingeschat (niet over-optimistisch)

❌ **Nog NIET klaar voor Layer 1** als:
- [ ] Er zijn conflicterende requirements (bijv. "zero downtime" vs. "geen budget voor HA")
- [ ] Team heeft geen tijd voor training (Kubernetes kennis is essentieel)
- [ ] Infrastructuur provider capabilities zijn onbekend (kan blokkeren bij implementatie)
- [ ] Security baseline is onduidelijk (risico op compliance issues later)

---

## 13. Volgende Stappen: Van Layer 0 naar Layer 1

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

## 14. Bijlage: Referenties naar KubeCompass Framework

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

---

## 15. Auto-Copilot Instructies & Validatie

### Voor Engineers die Dit Document Gebruiken

Dit Layer 0 document is specifiek ontworpen om als input te dienen voor AI auto-copilots (ChatGPT, Claude, Gemini) bij het uitwerken van Layer 1 en verder. 

#### Hoe te Gebruiken met Auto-Copilot

**Stap 1: Layer 0 Validatie**
Geef de copilot dit volledige document en vraag:
```
Ik heb een Layer 0 analyse gedaan voor een Kubernetes migratie. 
Analyseer dit document en identificeer:
1. Welke aannames zijn niet gevalideerd en risico's vormen
2. Welke hard constraints kunnen conflicteren
3. Welke vragen uit sectie 12 zijn kritisch voor Layer 1
4. Welke risico's uit sectie "Expliciete Risico's" hebben onvoldoende mitigatie
```

**Stap 2: Layer 1 Tool Selectie**
Na validatie van Layer 0:
```
Gebaseerd op deze Layer 0 analyse, help me met Layer 1 tool selectie.
Geef "Use X unless Y" recommendations voor:
1. CNI plugin (Cilium vs Calico vs Flannel)
2. GitOps tool (Argo CD vs Flux)
3. Observability stack (Prometheus/Grafana vs alternatives)
4. Backup solution (Velero vs alternatives)
5. Secrets management (External Secrets Operator vs Sealed Secrets vs Vault)

Gebruik de KubeCompass decision matrix principes (zie MATRIX.md).
Respecteer de hard constraints: vendor independence, budget, team maturity.
```

**Stap 3: Iteratieve Refinement**
Voor elke tool categorie:
```
Voor [CNI plugin] keuze:
- Wat zijn de trade-offs tussen Cilium en Calico?
- Hoe meet ik deze trade-offs tegen de Layer 0 requirements?
  - Performance (webshop moet snel zijn)
  - Network policies support (security requirement)
  - Multi-region capability (toekomstige eis)
  - Operational complexity (team heeft geen Kubernetes ervaring)
- Wat is de migration cost als we later willen switchen?
```

### Validatie Checklist voor Layer 0 Compleetheid

Dit document is **compleet** als:
- [x] **Expliciete Goals** zijn gedocumenteerd (wat willen we bereiken)
- [x] **Expliciete Non-Goals** zijn gedocumenteerd (wat doen we NIET)
- [x] **Harde Randvoorwaarden** zijn duidelijk (niet-onderhandelbaar)
- [x] **Risico's met mitigaties** zijn geïdentificeerd (hoog/medium/laag)
- [x] **Business context** is helder (wie, wat, waarom)
- [x] **Ownership model** is gedefinieerd (Dev/Ops/Support rollen)
- [x] **Aannames zijn expliciet** en gemarkeerd voor validatie in Layer 1
- [x] **Vervolgvragen voor Layer 1** zijn gestructureerd en specifiek
- [x] **Geen tool namen** in requirements (tenzij als voorbeeld van wat NIET te doen)
- [x] **Geen vendor-specific** oplossingen als requirement

Dit document is **NIET compleet** als:
- [ ] Er zijn tool keuzes gemaakt zonder alternatieven te overwegen
- [ ] Er zijn conflicterende requirements zonder resolutie
- [ ] Team capabilities zijn niet realistisch ingeschat
- [ ] Budget en time constraints zijn niet gedocumenteerd
- [ ] Rollback scenario's zijn niet gedefinieerd

### Principes die Gevolgd Zijn (Layer 0 Discipline)

✅ **Geen premature tool keuzes**: Document noemt Cilium/Calico/Flannel als *voorbeelden*, niet als beslissingen  
✅ **Vendor neutraliteit**: Open-source voorkeur is *principe*, niet "we gebruiken tool X"  
✅ **Business driven**: Elk requirement is gekoppeld aan business impact (omzetverlies, klantvertrouwen)  
✅ **Pragmatisme**: Non-goals sectie voorkomt over-engineering (geen microservices dag 1, geen multi-region dag 1)  
✅ **Expliciet over onwetendheid**: Sectie 10 "Aannames" erkent wat we NIET weten  
✅ **Iteratief refinement**: Sectie 12 "Vervolgvragen" maakt duidelijk wat Layer 1 moet beantwoorden  

### Anti-Patterns die Vermeden Zijn

❌ **Vermeden: "We gaan Cilium gebruiken"** → In plaats: "CNI moet Network Policies ondersteunen"  
❌ **Vermeden: "We nemen Prometheus"** → In plaats: "Observability moet proactief zijn, niet reactief"  
❌ **Vermeden: "Multi-region vanaf dag 1"** → In plaats: "Single region, maar architectuur blokkeert multi-region niet"  
❌ **Vermeden: "100% uptime garantie"** → In plaats: "Realistisch: minimaliseer downtime, accepteer dat incidenten gebeuren"  
❌ **Vermeden: "Team leert Kubernetes wel"** → In plaats: "Team heeft geen ervaring, externe consultant + training nodig"  

---

**Layer 0 Document Versie**: 2.0  
**Laatste Update**: December 2024  
**Auteur**: KubeCompass Framework + Community Feedback  
**Licentie**: MIT — vrij te gebruiken en aan te passen voor eigen situaties
