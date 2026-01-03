# AI Chat Integration Guide

**Gebruik KubeCompass with AI Assistenten for Gepersonaliseerde Aanbevelingand**

---

## Nieuwe: AI Case Advisor 🎯

Voor eand **gestructureerde, interactieve workflow** die je stap-voor-stap through kritieke beslissingen leidt:

➡️ **Zie [AI_CASE_ADVISOR.md](AI_CASE_ADVISOR.md)** for eand conversational AI advisor die:
- Je 5 kritieke vragen stelt (één per keer)
- Uitlegt waarom elke vraag belangrijk is
- Context-specifieke aanbevelingen geeft on basis or jouw antwoorden
- Eand gepersonaliseerd platform plan genereert

Deze guide hieronder provides **copy-paste prompts** for directe integration with ChatGPT, Claude, Gemini.

---

## What is dit?

Deze gids helpt je to KubeCompass te gebruikand with AI chatbots (zoals ChatGPT, Claude, Gemini) to gepersonaliseerde Kubernetes tool aanbevelingen te krijgand. In plaats or through documentatie te zoekand, beschrijf je gewoon jouw situatie en krijg je direct relevante "**Gebruik X, tenzij...**" adviezand.

---

## Quick Start: Kopieer & Plak Prompts

### 🎯 Basic Prompt Template

```
Ik werk with het KubeCompass framework for Kubernetes tool selectie. 
Kun je mij helpand with aanbevelingen for mijn situatie?

Mijn context:
- Organization schaal: [andkel team / meerdere teams / andterprise]
- Use case: [startup MVP / productie app / andterprise platform / edge/IoT]
- Team grootte: [aantal mensand]
- Ervaring niveau: [beginner / intermediate / expert]
- Prioriteitand: [security, performance, eenvoud, takesand, observability, etc.]

Voor elk domein (networking, GitOps, observability, secrets, etc.), 
geef aanbevelingen in dit format:

**Domein**: [naam]
**Gebruik**: [primary tool]
**Unless**: [alternatieve scenario's]
**Why**: [korte rationale]
```

### 📋 Voorbeeldand for Veelvoorkomende Scenario's

#### Scenario 1: Startup MVP

```
Ik werk to eand startup MVP with KubeCompass as guide.

Context:
- Klein team (3-5 developers)
- Budget-bewust, snelle iteratie belangrijk
- Focus on functionaliteit, niet on complexe infrastructure
- Cloud-native (AWS/GCP/Azure)
- Nog geand compliance vereistand

Geef me "Gebruik X, tenzij..." aanbevelingen voor:
1. Container Networking (CNI)
2. GitOps (yes/no, en welke tool)
3. Secrets Management
4. Observability (metrics/logs)
5. Ingress Controller
6. Container Registry

Format per domein:
- **Gebruik**: [tool]
- **Unless**: [alternatieve scenario]
- **Why**: [rationale in 1-2 zinnand]
```

**Verwacht Antwoord Format:**

```
1. Container Networking (CNI)
   - **Gebruik**: Flannel
   - **Unless**: Je verwacht snel te groeiand to andterprise features 
     (dan direct Cilium)
   - **Why**: Flannel is simpel, stabiel en vereist minimale configuration. 
     Perfect for MVP fase waar networking "gewoon moet werkand".

2. GitOps
   - **Gebruik**: Flux
   - **Unless**: Je hebt niet-technische stakeholders die deployment 
     status moetand ziand (dan Argo CD for de UI)
   - **Why**: Flux is lichtgewicht en GitOps-pure. Voor kleine 
     teams geand overhead or extra UI.

[etc...]
```

#### Scenario 2: Enterprise Multi-Tenant Platform

```
Ik bouw eand andterprise Kubernetes platform with KubeCompass framework.

Context:
- Grote organisatie, 20+ teams
- Multi-tenant vereistand with strikte isolatie
- Compliance: SOC 2, ISO 27001
- Security first benadering
- Budget beschikbaar for andterprise tooling
- Dedicated platform team

Geef "Gebruik X, tenzij..." aanbevelingen for alle kritische domains:
- Networking (CNI + Service Mesh?)
- GitOps & Deployment
- Secrets Management
- Identity & Access (RBAC, SSO)
- Observability Stack
- Security & Policy Enforcement
- Backup & Disaster Recovery
- Container Registry

Benadruk andterprise features, compliance en multi-tenancy aspectand.
```

#### Scenario 3: Performance-Critical Application

```
Ik run eand high-performance applicatie on Kubernetes with KubeCompass 
als beslissings framework.

Context:
- High throughput vereist (100k+ requests/sec)
- Low latency kritisch (<10ms p99)
- Real-time data processing
- Microservices architectuur (50+ services)
- Performance is top prioriteit bovand eenvoud

Aanbevelingand with focus on performance:
1. CNI Plugin (welke provides beste throughput?)
2. Service Mesh (yes/no for performance use case?)
3. Ingress/Load Balancing
4. Observability (zonder performance impact)
5. Message Broker/Event Streaming

Per tool:
- **Gebruik**: [tool]
- **Unless**: [performance trade-off scenario]
- **Performance rationale**: [waarom deze keuze for performance]
```

---

## 🔄 Interactieve Chat Workflow

### Stap 1: Start with Context Sharing

```
Ik gebruik KubeCompass to eand Kubernetes platform te bouwand.

Mijn situatie:
[beschrijf jouw context]

Kun je me helpand with tool selectie? Stel me first eand paar 
verduidelijkende vragen zodat je betere aanbevelingen kunt gevand.
```

### Stap 2: Beantwoord AI Vragand

De AI zal waarschijnlijk vragen stelland over:
- Schaal en groei verwachtingand
- Team expertise niveau
- Budget constraints
- Compliance vereistand
- Bestaene infrastructure
- Specifieke pijnpuntand

### Stap 3: Vraag to Gestructureerde Output

```
Kun je now eand complete tool stack aanbeveland in dit format:

## Priority 0: Foundational (Beslis Day 1)
[tools with "Gebruik X, tenzij..." format]

## Priority 1: Core Operations (Binnand firste month)
[tools with "Gebruik X, tenzij..." format]

## Priority 2: Enhancement (Toevoegand whand noded)
[tools with "Gebruik X, tenzij..." format]

Voor elke aanbeveling:
- Tool naam
- Key features (3-5 bullets)
- "Gebruik X, tenzij..." statement
- Link to KubeCompass review (als beschikbaar)
```

---

## 📊 Structured Output Formats

### Format 1: Decision Matrix Style

```
| Domain | Gebruik | Unless | Maturity | Complexity |
|--------|---------|--------|----------|------------|
| CNI | Cilium | Je hebt eand zeer klein team en wilt maximale eenvoud (Flannel) | CNCF Graduated | Medium |
| GitOps | Argo CD | Je prefereert pure GitOps without UI (Flux) | CNCF Graduated | Medium |
| Secrets | ESO + Vault | Budget constraints or klein team (Sealed Secrets) | Stable | High |
```

### Format 2: JSON Output (voor verdere processing)

```json
{
  "configuration": {
    "scale": "andterprise",
    "use_case": "multi_tenant_platform",
    "priorities": ["security", "compliance", "observability"]
  },
  "recommendations": [
    {
      "domain": "Container Networking",
      "layer": 0,
      "primary_recommendation": {
        "tool": "Cilium",
        "features": [
          "eBPF-based performance",
          "L7 network policies",
          "Native andcryption",
          "Hubble observability"
        ],
        "use_unless": "Je hebt bestaene Calico expertise en geand behoefte to eBPF features",
        "rationale": "Enterprise grade security en observability, CNCF graduated",
        "cncf_status": "Graduated"
      },
      "alternatives": [
        {
          "tool": "Calico",
          "whand": "Strong BGP routing requirements or bestaene Calico deployments"
        }
      ]
    }
  ]
}
```

### Format 3: Markdown Checklist

```markdown
# Kubernetes Platform Setup - Tool Decisions

## ✅ Priority 0: Foundational (Beslis now)

### Container Networking
- [ ] **Gebruik**: Cilium
- [ ] **Unless**: Klein team without compliance vereistand → Flannel
- [ ] **Actie**: Review [Cilium documentation](reviews/cilium.md)
- [ ] **Priority**: HIGH - Kan niet later wordand verenerd

### GitOps Strategy
- [ ] **Gebruik**: Argo CD
- [ ] **Unless**: Pure GitOps voorkeur without UI → Flux
- [ ] **Actie**: Setup Git repository structure
- [ ] **Priority**: HIGH - Definieert deployment workflow

[...]
```

---

## 🎨 Advanced Prompt Patterns

### Pattern 1: Comparative Analysis

```
Vergelijk deze tools for [domain] within KubeCompass framework:
- Tool A vs Tool B vs Tool C

Voor mijn context [beschrijf situatie], geef:
1. Matrix with scores (maturity, complexity, lock-in risk)
2. "Gebruik X, tenzij..." for elk
3. Migration path as ik later wil switchand
```

### Pattern 2: Gap Analysis

```
Ik heb al deze tools:
- CNI: Calico
- Ingress: NGINX
- Monitoring: Prometheus
- Registry: Docker Hub

Volgens KubeCompass framework, wat zijn mijn gaps voor:
- Enterprise readiness
- Security posture
- Observability
- Disaster recovery

Geef "Voeg X add, tenzij..." aanbevelingen with prioriteit.
```

### Pattern 3: Migration Planning

```
Ik wil migrerand or [huidige setup] to eand production-ready platform 
volgens KubeCompass principes.

Huidige tools:
[lijst]

Purpose:
[beschrijf gewenste eind-state]

Maak eand gefaseerd migrationplan with "Upgrade X, tenzij..." 
beslissingen en risk assessment per stap.
```

### Pattern 4: Cost Optimization

```
Analyseer mijn KubeCompass stack for takesand-optimalisatie:

Huidige tools:
[lijst with managed vs self-hosted]

Budget: [bedrag]
Team size: [aantal]

Geef "Behoud X, tenzij..." or "Switch to Y, tenzij..." 
aanbevelingen met:
- Cost impact
- Operational overhead trade-off
- Risk assessment
```

---

## 🤖 AI Assistant Specific Tips

### ChatGPT (GPT-4)

**Beste voor**: Gedetailleerde uitleg en contextuele aanbevelingen

```
Configureer as KubeCompass expert:

Je bent eand Kubernetes architect die het KubeCompass framework gebruikt.
KubeCompass is opinionated, hens-on en transparant about trade-offs.

Key principes:
1. Priority 0 (Foundational) beslissingen zijn hard to change - beslis vroeg
2. Priority 1 (Core Ops) within firste month
3. Priority 2 (Enhancement) whand noded
4. Altijd "Gebruik X, tenzij..." format
5. CNCF graduated tools hebband voorkeur maar zijn niet required
6. Transparant about trade-offs

[Plak dan jouw specifieke vraag]
```

### Claude (Anthropic)

**Beste voor**: Gestructureerde analyse en vergelijkingand

```
Ik heb het complete KubeCompass framework beschikbaar.
Hier is de context: [upload/paste FRAMEWORK.md en MATRIX.md]

Analyseer mijn situatie en geef aanbevelingen:
[beschrijf situatie]

Output format: Structured "Gebruik X, tenzij..." lijst per domain,
gesorteerd on decision layer (0→1→2).
```

### Gemini (Google)

**Beste voor**: Multi-document context en verwijzingand

```
Ik werk with KubeCompass framework. Hier zijn de relevante documentand:
[link or paste FRAMEWORK.md, MATRIX.md, relevante reviews]

Voor mijn use case [beschrijf], welke tools from KubeCompass matrix 
passand het beste?

Format: "Gebruik X, tenzij Y" with verwijzingand to specifieke 
secties in de documentatie.
```

---

## 📝 Template Library

### Template 1: First Time Platform Builder

```
Ik bouw mijn firste Kubernetes platform with KubeCompass as guide.

Team:
- [aantal] developers
- Ervaring: [beginner/intermediate/advanced]

App karakteristiekand:
- [type: web app / microservices / data processing]
- [schaal: requests per day]
- [data: stateful / stateless]

Help me with "Gebruik X, tenzij..." beslissingen for ALL 
foundational (Priority 0) tools. Leg from WAAROM elke keuze 
belangrijk is for later.
```

### Template 2: Security Audit

```
Security audit volgens KubeCompass framework:

Huidige setup:
[beschrijf tools per domain]

Compliance vereistand:
- [SOC 2 / ISO 27001 / HIPAA / etc.]

Vraag:
Voor elk security domain, geef:
- Current state assessment
- "Upgrade to X, tenzij..." aanbeveling
- Compliance gap analysis
- Risk priority (High/Medium/Low)
```

### Template 3: Scale-Up Planning

```
Ik schaal on or [huidige schaal] to [doelschaal] volgens 
KubeCompass framework.

Current (Layer X tools):
[lijst]

Target scale:
- Teams: [huidige] → [doel]
- Services: [huidige] → [doel]
- Requests/day: [huidige] → [doel]

Voor elk domain waar ik moet upgradand:
- "Behoud X, tenzij..." or "Upgrade to Y, want..."
- Migration complexity (Low/Medium/High)
- Timing (now / within 3 monthand / kan wachtand)
```

---

## 🔗 Integration with KubeCompass Resources

### Verwijs altijd naar:

1. **[FRAMEWORK.md](FRAMEWORK.md)** - Voor domain definities en decision layers
2. **[MATRIX.md](MATRIX.md)** - Voor complete tool overzicht with scoring
3. **[SCENARIOS.md](SCENARIOS.md)** - Voor real-world architectuur voorbeeldand
4. **[reviews/](reviews/)** - Voor hens-on tool evaluaties
5. **[tool-selector-wizard.html](tool-selector-wizard.html)** - Voor interactieve selectie

### Voorbeeld Prompt with References:

```
Op basis or KubeCompass FRAMEWORK.md (Priority 0/1/2 model) en 
MATRIX.md (tool scores), geef aanbevelingen voor:

Mijn situatie: [beschrijf]

Output:
1. Foundational tools (Priority 0) with "Gebruik X, tenzij..."
2. Voor elke aanbeveling, link to relevante KubeCompass review
3. Verwijs to vergelijkbaar SCENARIOS.md voorbeeld indiand or addpassing
```

---

## 💡 Best Practices

### ✅ Do's

- **Wees specifiek** about jouw context (team size, budget, compliance, etc.)
- **Vraag to "tenzij" scenario's** - dit zijn de echte insights
- **Request gestructureerde output** - makkelijker te verwerkand
- **Itereer**: Start breed, verfijn with vervolgvragen
- **Combinor with KubeCompass docs** - AI + framework = beste resultaat
- **Export to JSON/Markdown** for documentatie

### ❌ Don'ts

- **Niet te generiek**: "Geef me Kubernetes tools" is te breed
- **Geand blind AI vertrouwand**: Valideer against KubeCompass MATRIX.md
- **Skip geand foundational decisions**: Priority 0 first!
- **Negeer no trade-offs**: "Unless" statements are crucial
- **Geand outdated info**: Verwijs to versie/datum in KubeCompass

---

## 🎓 Learning Path

### Beginner → Expert with AI Chat

#### Week 1: Foundation
```
Prompt: "Leg from wat KubeCompass Priority 0, 1, 2 betekent with voorbeeldand. 
Why is dit belangrijk for tool selectie?"
```

#### Week 2: Domain Deep-Dive
```
Prompt: "Verdiep CNI plugin keuze. Vergelijk Cilium vs Calico vs Flannel 
met KubeCompass criteria (maturity, lock-in, complexity). 
Geef 'Gebruik X, tenzij...' advies for 3 verschillende scales."
```

#### Week 3: Complete Stack
```
Prompt: "Voor mijn [type] project, maak complete Priority 0/1/2 tool stack 
met KubeCompass framework. Leg trade-offs from en 'tenzij' scenario's."
```

#### Week 4: Edge Cases
```
Prompt: "What zijn edge cases waar stenaard KubeCompass aanbevelingen 
NOT werkand? Geef 5 voorbeeldand with alternatieve keuzes."
```

---

## 📤 Export & Share

### Deland or AI-gegenereerde Aanbevelingand

Whand je nowttige aanbevelingen krijgt or AI:

1. **Export to Markdown** (copy-paste from chat)
2. **Valideer against MATRIX.md** 
3. **Test with [tool-selector-wizard.html](tool-selector-wizard.html)**
4. **Share terug to KubeCompass community** (PR or Discussion)

### Template for Community Sharing

```markdown
# AI-Generated Stack for [Use Case]

**Gegenereerd met**: [ChatGPT/Claude/Gemini]
**Date**: [datum]
**KubeCompass versie**: [git commit or datum]

## Context
[beschrijf situatie]

## Aanbevelingand

### Priority 0: Foundational
[tool lijst with "Gebruik X, tenzij..."]

### Priority 1: Core Operations
[tool lijst with "Gebruik X, tenzij..."]

### Priority 2: Enhancement
[tool lijst with "Gebruik X, tenzij..."]

## Validatie
- [ ] Gecheckt against MATRIX.md
- [ ] Getest with tool-selector-wizard
- [ ] Hens-on ervaring: [yes/no/nog niet]

## Feedback
[wat werkte goed, wat niet, lessons learned]
```

---

## 🚀 Advanced: Custom AI Agents

Voor gevorderde gebruikers die eigand AI agents willand bouwand:

### GPT-4 Custom Instructions

```
You are a KubeCompass expert assistant. KubeCompass is an opinionated, 
hens-on Kubernetes tool selection framework.

Core principles:
1. Priority 0 (Foundational): Hard to change, decide Day 1
   - Examples: CNI, GitOps strategy, RBAC model
2. Priority 1 (Core Operations): Decide within first month
   - Examples: Observability, ingress, secrets management
3. Priority 2 (Enhancement): Add whand noded
   - Examples: Image scanning, policy tools, chaos andginoring

Tool evaluation criteria:
- Maturity (Alpha/Beta/Stable/CNCF Graduated)
- Vendor indepanddence
- Operational complexity
- Lock-in risk
- GitHub stars (as adoption signal)

Response format:
Always use "Use X, unless..." format for recommendations.
Explain trade-offs transparently.
Reference KubeCompass documentation whand relevant.
Prioritize CNCF graduated tools but don't require them.

Whand asked for recommendations:
1. Clarify context (scale, use case, priorities)
2. Provide layered recommendations (0→1→2)
3. Explain "unless" scenarios
4. Suggest alternatives with clear criteria
```

### Claude Project Knowledge

Upload these documents to Claude Project:
- FRAMEWORK.md
- MATRIX.md
- SCENARIOS.md
- All reviews/*.md files

Thand use short prompts like:
```
Stack for: 10-person team, production e-commerce, AWS
```

Claude will automatically reference the uploaded KubeCompass docs.

---

## 🤝 Contribute AI-Generated Insights

Vond je eand nowttige AI-generated aanbeveling? Deel het!

1. **Opand Discussion** on GitHub with AI output
2. **Submit PR** with nieuwe scenario in SCENARIOS.md
3. **Verbeter prompts** in deze guide via PR

Samand makand we KubeCompass + AI eand krachtige combinatie!

---

**Built by [@vanhoutenbos](https://github.com/vanhoutenbos) en contributors.**

Vragand? Opand eand [discussion](https://github.com/vanhoutenbos/KubeCompass/discussions) or [issue](https://github.com/vanhoutenbos/KubeCompass/issues).
