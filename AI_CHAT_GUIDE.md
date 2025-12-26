# AI Chat Integration Guide

**Gebruik KubeCompass met AI Assistenten voor Gepersonaliseerde Aanbevelingen**

---

## Wat is dit?

Deze gids helpt je om KubeCompass te gebruiken met AI chatbots (zoals ChatGPT, Claude, Gemini) om gepersonaliseerde Kubernetes tool aanbevelingen te krijgen. In plaats van door documentatie te zoeken, beschrijf je gewoon jouw situatie en krijg je direct relevante "**Gebruik X, tenzij...**" adviezen.

---

## Quick Start: Kopieer & Plak Prompts

### 🎯 Basis Prompt Template

```
Ik werk met het KubeCompass framework voor Kubernetes tool selectie. 
Kun je mij helpen met aanbevelingen voor mijn situatie?

Mijn context:
- Organisatie schaal: [enkel team / meerdere teams / enterprise]
- Use case: [startup MVP / productie app / enterprise platform / edge/IoT]
- Team grootte: [aantal mensen]
- Ervaring niveau: [beginner / intermediate / expert]
- Prioriteiten: [security, performance, eenvoud, kosten, observability, etc.]

Voor elk domein (networking, GitOps, observability, secrets, etc.), 
geef aanbevelingen in dit format:

**Domein**: [naam]
**Gebruik**: [primary tool]
**Tenzij**: [alternatieve scenario's]
**Waarom**: [korte rationale]
```

### 📋 Voorbeelden voor Veelvoorkomende Scenario's

#### Scenario 1: Startup MVP

```
Ik werk aan een startup MVP met KubeCompass als guide.

Context:
- Klein team (3-5 developers)
- Budget-bewust, snelle iteratie belangrijk
- Focus op functionaliteit, niet op complexe infrastructure
- Cloud-native (AWS/GCP/Azure)
- Nog geen compliance vereisten

Geef me "Gebruik X, tenzij..." aanbevelingen voor:
1. Container Networking (CNI)
2. GitOps (ja/nee, en welke tool)
3. Secrets Management
4. Observability (metrics/logs)
5. Ingress Controller
6. Container Registry

Format per domein:
- **Gebruik**: [tool]
- **Tenzij**: [alternatieve scenario]
- **Waarom**: [rationale in 1-2 zinnen]
```

**Verwacht Antwoord Format:**

```
1. Container Networking (CNI)
   - **Gebruik**: Flannel
   - **Tenzij**: Je verwacht snel te groeien naar enterprise features 
     (dan direct Cilium)
   - **Waarom**: Flannel is simpel, stabiel en vereist minimale configuratie. 
     Perfect voor MVP fase waar networking "gewoon moet werken".

2. GitOps
   - **Gebruik**: Flux
   - **Tenzij**: Je hebt niet-technische stakeholders die deployment 
     status moeten zien (dan Argo CD voor de UI)
   - **Waarom**: Flux is lichtgewicht en GitOps-pure. Voor kleine 
     teams geen overhead van extra UI.

[etc...]
```

#### Scenario 2: Enterprise Multi-Tenant Platform

```
Ik bouw een enterprise Kubernetes platform met KubeCompass framework.

Context:
- Grote organisatie, 20+ teams
- Multi-tenant vereisten met strikte isolatie
- Compliance: SOC 2, ISO 27001
- Security first benadering
- Budget beschikbaar voor enterprise tooling
- Dedicated platform team

Geef "Gebruik X, tenzij..." aanbevelingen voor alle kritische domains:
- Networking (CNI + Service Mesh?)
- GitOps & Deployment
- Secrets Management
- Identity & Access (RBAC, SSO)
- Observability Stack
- Security & Policy Enforcement
- Backup & Disaster Recovery
- Container Registry

Benadruk enterprise features, compliance en multi-tenancy aspecten.
```

#### Scenario 3: Performance-Critical Application

```
Ik run een high-performance applicatie op Kubernetes met KubeCompass 
als beslissings framework.

Context:
- High throughput vereist (100k+ requests/sec)
- Low latency kritisch (<10ms p99)
- Real-time data processing
- Microservices architectuur (50+ services)
- Performance is top prioriteit boven eenvoud

Aanbevelingen met focus op performance:
1. CNI Plugin (welke biedt beste throughput?)
2. Service Mesh (ja/nee voor performance use case?)
3. Ingress/Load Balancing
4. Observability (zonder performance impact)
5. Message Broker/Event Streaming

Per tool:
- **Gebruik**: [tool]
- **Tenzij**: [performance trade-off scenario]
- **Performance rationale**: [waarom deze keuze voor performance]
```

---

## 🔄 Interactieve Chat Workflow

### Stap 1: Start met Context Sharing

```
Ik gebruik KubeCompass om een Kubernetes platform te bouwen.

Mijn situatie:
[beschrijf jouw context]

Kun je me helpen met tool selectie? Stel me eerst een paar 
verduidelijkende vragen zodat je betere aanbevelingen kunt geven.
```

### Stap 2: Beantwoord AI Vragen

De AI zal waarschijnlijk vragen stellen over:
- Schaal en groei verwachtingen
- Team expertise niveau
- Budget constraints
- Compliance vereisten
- Bestaande infrastructure
- Specifieke pijnpunten

### Stap 3: Vraag om Gestructureerde Output

```
Kun je nu een complete tool stack aanbevelen in dit format:

## Layer 0: Foundational (Beslis Day 1)
[tools met "Gebruik X, tenzij..." format]

## Layer 1: Core Operations (Binnen eerste maand)
[tools met "Gebruik X, tenzij..." format]

## Layer 2: Enhancement (Toevoegen wanneer nodig)
[tools met "Gebruik X, tenzij..." format]

Voor elke aanbeveling:
- Tool naam
- Key features (3-5 bullets)
- "Gebruik X, tenzij..." statement
- Link naar KubeCompass review (als beschikbaar)
```

---

## 📊 Structured Output Formats

### Format 1: Decision Matrix Style

```
| Domain | Gebruik | Tenzij | Maturity | Complexity |
|--------|---------|--------|----------|------------|
| CNI | Cilium | Je hebt een zeer klein team en wilt maximale eenvoud (Flannel) | CNCF Graduated | Medium |
| GitOps | Argo CD | Je prefereert pure GitOps zonder UI (Flux) | CNCF Graduated | Medium |
| Secrets | ESO + Vault | Budget constraints of klein team (Sealed Secrets) | Stable | High |
```

### Format 2: JSON Output (voor verdere processing)

```json
{
  "configuration": {
    "scale": "enterprise",
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
          "Native encryption",
          "Hubble observability"
        ],
        "use_unless": "Je hebt bestaande Calico expertise en geen behoefte aan eBPF features",
        "rationale": "Enterprise grade security en observability, CNCF graduated",
        "cncf_status": "Graduated"
      },
      "alternatives": [
        {
          "tool": "Calico",
          "when": "Strong BGP routing requirements of bestaande Calico deployments"
        }
      ]
    }
  ]
}
```

### Format 3: Markdown Checklist

```markdown
# Kubernetes Platform Setup - Tool Decisions

## ✅ Layer 0: Foundational (Beslis nu)

### Container Networking
- [ ] **Gebruik**: Cilium
- [ ] **Tenzij**: Klein team zonder compliance vereisten → Flannel
- [ ] **Actie**: Review [Cilium documentation](reviews/cilium.md)
- [ ] **Priority**: HIGH - Kan niet later worden veranderd

### GitOps Strategy
- [ ] **Gebruik**: Argo CD
- [ ] **Tenzij**: Pure GitOps voorkeur zonder UI → Flux
- [ ] **Actie**: Setup Git repository structure
- [ ] **Priority**: HIGH - Definieert deployment workflow

[...]
```

---

## 🎨 Advanced Prompt Patterns

### Pattern 1: Comparative Analysis

```
Vergelijk deze tools voor [domain] binnen KubeCompass framework:
- Tool A vs Tool B vs Tool C

Voor mijn context [beschrijf situatie], geef:
1. Matrix met scores (maturity, complexity, lock-in risk)
2. "Gebruik X, tenzij..." voor elk
3. Migration path als ik later wil switchen
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

Geef "Voeg X toe, tenzij..." aanbevelingen met prioriteit.
```

### Pattern 3: Migration Planning

```
Ik wil migreren van [huidige setup] naar een production-ready platform 
volgens KubeCompass principes.

Huidige tools:
[lijst]

Doel:
[beschrijf gewenste eind-state]

Maak een gefaseerd migratieplan met "Upgrade X, tenzij..." 
beslissingen en risk assessment per stap.
```

### Pattern 4: Cost Optimization

```
Analyseer mijn KubeCompass stack voor kosten-optimalisatie:

Huidige tools:
[lijst met managed vs self-hosted]

Budget: [bedrag]
Team size: [aantal]

Geef "Behoud X, tenzij..." of "Switch naar Y, tenzij..." 
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
Configureer als KubeCompass expert:

Je bent een Kubernetes architect die het KubeCompass framework gebruikt.
KubeCompass is opinionated, hands-on en transparant over trade-offs.

Key principes:
1. Layer 0 (Foundational) beslissingen zijn hard to change - beslis vroeg
2. Layer 1 (Core Ops) binnen eerste maand
3. Layer 2 (Enhancement) wanneer nodig
4. Altijd "Gebruik X, tenzij..." format
5. CNCF graduated tools hebben voorkeur maar zijn niet verplicht
6. Transparant over trade-offs

[Plak dan jouw specifieke vraag]
```

### Claude (Anthropic)

**Beste voor**: Gestructureerde analyse en vergelijkingen

```
Ik heb het complete KubeCompass framework beschikbaar.
Hier is de context: [upload/paste FRAMEWORK.md en MATRIX.md]

Analyseer mijn situatie en geef aanbevelingen:
[beschrijf situatie]

Output format: Structured "Gebruik X, tenzij..." lijst per domain,
gesorteerd op decision layer (0→1→2).
```

### Gemini (Google)

**Beste voor**: Multi-document context en verwijzingen

```
Ik werk met KubeCompass framework. Hier zijn de relevante documenten:
[link of paste FRAMEWORK.md, MATRIX.md, relevante reviews]

Voor mijn use case [beschrijf], welke tools uit KubeCompass matrix 
passen het beste?

Format: "Gebruik X, tenzij Y" met verwijzingen naar specifieke 
secties in de documentatie.
```

---

## 📝 Template Library

### Template 1: First Time Platform Builder

```
Ik bouw mijn eerste Kubernetes platform met KubeCompass als guide.

Team:
- [aantal] developers
- Ervaring: [beginner/intermediate/advanced]

App karakteristieken:
- [type: web app / microservices / data processing]
- [schaal: requests per dag]
- [data: stateful / stateless]

Help me met "Gebruik X, tenzij..." beslissingen voor ALL 
foundational (Layer 0) tools. Leg uit WAAROM elke keuze 
belangrijk is voor later.
```

### Template 2: Security Audit

```
Security audit volgens KubeCompass framework:

Huidige setup:
[beschrijf tools per domain]

Compliance vereisten:
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
Ik schaal op van [huidige schaal] naar [doelschaal] volgens 
KubeCompass framework.

Current (Layer X tools):
[lijst]

Target scale:
- Teams: [huidige] → [doel]
- Services: [huidige] → [doel]
- Requests/day: [huidige] → [doel]

Voor elk domain waar ik moet upgraden:
- "Behoud X, tenzij..." of "Upgrade naar Y, want..."
- Migration complexity (Low/Medium/High)
- Timing (now / binnen 3 maanden / kan wachten)
```

---

## 🔗 Integration met KubeCompass Resources

### Verwijs altijd naar:

1. **[FRAMEWORK.md](FRAMEWORK.md)** - Voor domain definities en decision layers
2. **[MATRIX.md](MATRIX.md)** - Voor complete tool overzicht met scoring
3. **[SCENARIOS.md](SCENARIOS.md)** - Voor real-world architectuur voorbeelden
4. **[reviews/](reviews/)** - Voor hands-on tool evaluaties
5. **[tool-selector-wizard.html](tool-selector-wizard.html)** - Voor interactieve selectie

### Voorbeeld Prompt met References:

```
Op basis van KubeCompass FRAMEWORK.md (Layer 0/1/2 model) en 
MATRIX.md (tool scores), geef aanbevelingen voor:

Mijn situatie: [beschrijf]

Output:
1. Foundational tools (Layer 0) met "Gebruik X, tenzij..."
2. Voor elke aanbeveling, link naar relevante KubeCompass review
3. Verwijs naar vergelijkbaar SCENARIOS.md voorbeeld indien van toepassing
```

---

## 💡 Best Practices

### ✅ Do's

- **Wees specifiek** over jouw context (team size, budget, compliance, etc.)
- **Vraag om "tenzij" scenario's** - dit zijn de echte insights
- **Request gestructureerde output** - makkelijker te verwerken
- **Itereer**: Start breed, verfijn met vervolgvragen
- **Combineer met KubeCompass docs** - AI + framework = beste resultaat
- **Export naar JSON/Markdown** voor documentatie

### ❌ Don'ts

- **Niet te generiek**: "Geef me Kubernetes tools" is te breed
- **Geen blind AI vertrouwen**: Valideer tegen KubeCompass MATRIX.md
- **Skip geen foundational decisions**: Layer 0 eerst!
- **Negeer geen trade-offs**: "Tenzij" statements zijn cruciaal
- **Geen outdated info**: Verwijs naar versie/datum in KubeCompass

---

## 🎓 Learning Path

### Beginner → Expert met AI Chat

#### Week 1: Foundation
```
Prompt: "Leg uit wat KubeCompass Layer 0, 1, 2 betekent met voorbeelden. 
Waarom is dit belangrijk voor tool selectie?"
```

#### Week 2: Domain Deep-Dive
```
Prompt: "Verdiep CNI plugin keuze. Vergelijk Cilium vs Calico vs Flannel 
met KubeCompass criteria (maturity, lock-in, complexity). 
Geef 'Gebruik X, tenzij...' advies voor 3 verschillende scales."
```

#### Week 3: Complete Stack
```
Prompt: "Voor mijn [type] project, maak complete Layer 0/1/2 tool stack 
met KubeCompass framework. Leg trade-offs uit en 'tenzij' scenario's."
```

#### Week 4: Edge Cases
```
Prompt: "Wat zijn edge cases waar standaard KubeCompass aanbevelingen 
NIET werken? Geef 5 voorbeelden met alternatieve keuzes."
```

---

## 📤 Export & Share

### Delen van AI-gegenereerde Aanbevelingen

Wanneer je nuttige aanbevelingen krijgt van AI:

1. **Export naar Markdown** (copy-paste uit chat)
2. **Valideer tegen MATRIX.md** 
3. **Test met [tool-selector-wizard.html](tool-selector-wizard.html)**
4. **Share terug naar KubeCompass community** (PR or Discussion)

### Template voor Community Sharing

```markdown
# AI-Generated Stack voor [Use Case]

**Gegenereerd met**: [ChatGPT/Claude/Gemini]
**Datum**: [datum]
**KubeCompass versie**: [git commit of datum]

## Context
[beschrijf situatie]

## Aanbevelingen

### Layer 0: Foundational
[tool lijst met "Gebruik X, tenzij..."]

### Layer 1: Core Operations
[tool lijst met "Gebruik X, tenzij..."]

### Layer 2: Enhancement
[tool lijst met "Gebruik X, tenzij..."]

## Validatie
- [ ] Gecheckt tegen MATRIX.md
- [ ] Getest met tool-selector-wizard
- [ ] Hands-on ervaring: [ja/nee/nog niet]

## Feedback
[wat werkte goed, wat niet, lessons learned]
```

---

## 🚀 Advanced: Custom AI Agents

Voor gevorderde gebruikers die eigen AI agents willen bouwen:

### GPT-4 Custom Instructions

```
You are a KubeCompass expert assistant. KubeCompass is an opinionated, 
hands-on Kubernetes tool selection framework.

Core principles:
1. Layer 0 (Foundational): Hard to change, decide Day 1
   - Examples: CNI, GitOps strategy, RBAC model
2. Layer 1 (Core Operations): Decide within first month
   - Examples: Observability, ingress, secrets management
3. Layer 2 (Enhancement): Add when needed
   - Examples: Image scanning, policy tools, chaos engineering

Tool evaluation criteria:
- Maturity (Alpha/Beta/Stable/CNCF Graduated)
- Vendor independence
- Operational complexity
- Lock-in risk
- GitHub stars (as adoption signal)

Response format:
Always use "Use X, unless..." format for recommendations.
Explain trade-offs transparently.
Reference KubeCompass documentation when relevant.
Prioritize CNCF graduated tools but don't require them.

When asked for recommendations:
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

Then use short prompts like:
```
Stack for: 10-person team, production e-commerce, AWS
```

Claude will automatically reference the uploaded KubeCompass docs.

---

## 🤝 Contribute AI-Generated Insights

Vond je een nuttige AI-generated aanbeveling? Deel het!

1. **Open Discussion** op GitHub met AI output
2. **Submit PR** met nieuwe scenario in SCENARIOS.md
3. **Verbeter prompts** in deze guide via PR

Samen maken we KubeCompass + AI een krachtige combinatie!

---

**Built by [@vanhoutenbos](https://github.com/vanhoutenbos) and contributors.**

Vragen? Open een [discussion](https://github.com/vanhoutenbos/KubeCompass/discussions) of [issue](https://github.com/vanhoutenbos/KubeCompass/issues).
