# KubeCompass

![Status](https://img.shields.io/badge/Status-POC%20%2F%20Research-yellow) ![License](https://img.shields.io/badge/License-MIT-blue) ![Contributions](https://img.shields.io/badge/Contributions-Welcome-green)

**Praktische, hands-on guidance voor het bouwen van production-ready Kubernetes platforms — zonder vendor marketing.**  
**Opinionated, hands-on guidance for building production-ready Kubernetes platforms — without the vendor fluff.**

> ⚠️ **Huidige Status / Current Status**: Dit project is in **POC/Research fase**. We testen actief tools, verzamelen data en verfijnen het framework. Nog niet alle vergelijkingen zijn compleet.  
> This project is in **POC/Research phase**. We're actively testing tools, gathering data, and refining the framework. Not all comparisons are complete yet.

---

## 🎯 Wat is KubeCompass? / What is KubeCompass?

Kubernetes is krachtig, maar het ecosysteem is **overweldigend**. Elk domein heeft tientallen tools die strijden om aandacht, verkocht met buzzwords en vendor pitches.

**Kubernetes is powerful, but the ecosystem is overwhelming.** Every domain has dozens of competing tools marketed with buzzwords, leaving you wondering:

- *Welke tools werken écht in productie? / Which tools actually work in production?*
- *Welke beslissingen zijn moeilijk terug te draaien? / Which decisions are hard to reverse?*
- *Wat is hype en wat is essentieel? / What's hype vs. what's essential?*

**KubeCompass doorbreekt de ruis met / KubeCompass cuts through the noise with:**

✅ **Opinionated aanbevelingen** op basis van praktijkervaring / **Opinionated recommendations** based on real-world experience  
✅ **Hands-on testing** — elke tool is daadwerkelijk getest / Every tool is actually used, not just researched  
✅ **Timing guidance** — weet wat je direct moet beslissen / Know what to decide Day 1 vs. what can wait  
✅ **Transparante scoring** — maturity, lock-in risico, complexiteit / **Transparent scoring** — maturity, lock-in risk, complexity  
✅ **Geen vendor bias** / **No vendor bias** — gebouwd door practitioners, voor practitioners / Built by practitioners, for practitioners

---

## 🚀 Snel Starten / Quick Start

### 📖 Uitgebreide Handleidingen / Comprehensive Guides

| Voor Nederlands / For Dutch | For English |
|------------------------------|-------------|
| **[Aan de Slag](docs/AAN_DE_SLAG.md)** | **[Getting Started](docs/GETTING_STARTED.md)** |
| Complete setup & leerpad | Complete setup & learning path |

**[📑 Project Overview](docs/PROJECT_OVERVIEW.md)** - Status, roadmap, structuur / Status, roadmap, structure  
**[📚 Complete Index](docs/INDEX.md)** - Alle documentatie / All documentation

### 🛠️ Drie Manieren om te Beginnen / Three Ways to Start

#### 1. 🛒 Interactive Tool Selector
Kies tools zoals je een computer koopt! / Shop for tools like buying a computer!

🧭 **[Open Tool Selector Wizard](tool-selector-wizard.html)** 

Beantwoord vragen → Krijg aanbevelingen → Export resultaten  
Answer questions → Get recommendations → Export results

#### 2. 🤖 AI Case Advisor  
Gepersonaliseerd advies via AI / Personalized guidance through AI:

💬 **[AI Case Advisor](docs/AI_CASE_ADVISOR.md)** - 5 vragen, op maat gemaakt advies / 5 questions, tailored advice  
💬 **[AI Chat Guide](docs/AI_CHAT_GUIDE.md)** - Prompts voor ChatGPT, Claude, Gemini

#### 3. 🧪 Lokaal Testen / Local Testing

Test Kubernetes lokaal met Kind - geen cloud nodig!  
Test Kubernetes locally with Kind - no cloud needed!

```bash
# Clone repository
git clone https://github.com/vanhoutenbos/KubeCompass.git
cd KubeCompass

# Windows
.\kind\create-cluster.ps1

# Linux/WSL/Mac
./kind/create-cluster.sh

# Valideer / Validate
kubectl cluster-info
```

📖 **[Complete Guide / Uitgebreide Gids](kind/README.md)**

---

## 🗺️ Priority Framework

KubeCompass gebruikt een **Priority 0/1/2** model voor beslissingen:  
KubeCompass uses a **Priority 0/1/2** model for decisions:

### Priority 0: Foundational Requirements
**Wanneer / When:** Week 1 - Voor je begint / Before you start  
**Focus:** WHY en constraints

📖 **[Priority 0 Webshop Case](docs/cases/PRIORITY_0_WEBSHOP_CASE.md)** (Nederlands)

### Priority 1: Tool Selection  
**Wanneer / When:** Week 2-4 - Basis platform / Basic platform  
**Focus:** WHAT en HOW

📖 **[Priority 1 Webshop Case](docs/cases/PRIORITY_1_WEBSHOP_CASE.md)** (Nederlands)

### Priority 2: Platform Enhancements
**Wanneer / When:** Maand 2+ - Na basis platform / After basic platform  
**Focus:** WHEN to add complexity

📖 **[Priority 2 Webshop Case](docs/cases/PRIORITY_2_WEBSHOP_CASE.md)** (Nederlands)

**Let op / Note:** Priority 2 is een **decision framework**, geen implementation guide.

---

## 📚 Documentatie / Documentation

### 🎯 Start Hier / Start Here

| Document | Nederlands | English | Beschrijving / Description |
|----------|------------|---------|----------------------------|
| **Getting Started** | [Aan de Slag](docs/AAN_DE_SLAG.md) | [Getting Started](docs/GETTING_STARTED.md) | Complete setup & leerpad / Complete setup & learning path |
| **Project Overview** | [Project Overzicht](docs/PROJECT_OVERVIEW.md) | [Project Overview](docs/PROJECT_OVERVIEW.md) | Status, roadmap, structuur / Status, roadmap, structure |
| **Index** | [Index](docs/INDEX.md) | [Index](docs/INDEX.md) | Alle documentatie / All documentation |

### 🏗️ Framework & Filosofie / Framework & Philosophy

- **[Framework](docs/architecture/FRAMEWORK.md)** - Complete domein structuur / Complete domain structure
- **[Vision](docs/architecture/VISION.md)** - Project filosofie / Project philosophy  
- **[Methodology](docs/architecture/METHODOLOGY.md)** - Tool evaluatie / Tool evaluation method

### 🎨 Visual Tools

- 🌊 [Complete Deployment Flow](deployment-flow.html) - 18 domeinen / 18 domains
- 📊 [Domain Overview](domain-overview.html) - Per prioriteit / By priority
- 🗓️ [Timeline View](deployment-order.html) - Week-by-week roadmap
- 🚢 [Kubernetes Ecosystem](kubernetes-ecosystem.html) - Ecosystem overzicht / Ecosystem overview
- ⚙️ [Kubernetes Architecture](kubernetes-architecture.html) - Architectuur / Architecture

📖 **[Alle Diagrams / All Diagrams](docs/DIAGRAMS.md)**

### 📝 Case Studies (Nederlands / Dutch)

- **[Priority 0: Webshop](docs/cases/PRIORITY_0_WEBSHOP_CASE.md)** - Foundational requirements
- **[Priority 1: Webshop](docs/cases/PRIORITY_1_WEBSHOP_CASE.md)** - Tool selection
- **[Priority 2: Webshop](docs/cases/PRIORITY_2_WEBSHOP_CASE.md)** - Enhancement decisions

### 🔧 Tool Vergelijkingen / Tool Comparisons

- **[CNI Comparison](docs/planning/CNI_COMPARISON.md)** - Cilium vs Calico
- **[GitOps Comparison](docs/planning/GITOPS_COMPARISON.md)** - ArgoCD vs Flux vs GitLab
- **[Secrets Management](docs/planning/SECRETS_MANAGEMENT.md)** - ESO vs Sealed Secrets vs SOPS
- **[Decision Matrix](docs/MATRIX.md)** - Alle tool aanbevelingen / All tool recommendations
- **[Decision Rules](docs/DECISION_RULES.md)** - "Kies X tenzij Y" logica / "Choose X unless Y" logic

### 🛠️ Implementation

- **[Implementation Guide](docs/IMPLEMENTATION_GUIDE.md)** - Reference patterns
- **[Production Ready](docs/implementation/PRODUCTION_READY.md)** - Production criteria
- **[Testing Methodology](docs/implementation/TESTING_METHODOLOGY.md)** - Testing approach
- **[Domain Roadmap](docs/planning/DOMAIN_ROADMAP.md)** - Implementation roadmap

---

## 📊 Project Status

**Fase / Phase:** 🚧 POC/Research - Actief bezig met foundation / Actively building foundation

**Domain Coverage:** 0/18 fully tested | 2/18 documented | 4/18 in progress  
**Target Launch:** Mid-March 2026 (Week 12)

### Wat is Klaar / What's Ready

- [x] Framework structuur en decision layers / Framework structure and decision layers
- [x] Testing methodologie / Testing methodology
- [x] Decision matrix met tool aanbevelingen / Decision matrix with tool recommendations
- [x] Real-world case studies (Nederlandse webshop / Dutch webshop)
- [x] Visual diagrams en interactive tools / Visual diagrams and interactive tools
- [x] Lokaal testing platform (Kind-based) / Local testing platform (Kind-based)
- [x] Interactive Tool Selector Wizard
- [x] AI Chat Integration Guide

### In Progress / In Uitvoering

- [ ] Hands-on tool reviews (6-8 tools voor MVP / for MVP)
- [ ] Startup MVP scenario completion
- [ ] Aanvullende comparison guides / Additional comparison guides
- [ ] Community contribution workflow
- [ ] Documentatie consistency pass / Documentation consistency pass

**[📅 Volledige Roadmap / Full Roadmap](docs/planning/DOMAIN_ROADMAP.md)**

---

## 📁 Repository Structuur / Repository Structure

```
KubeCompass/
├── docs/                       # Alle documentatie / All documentation
│   ├── AAN_DE_SLAG.md         # Nederlands getting started
│   ├── GETTING_STARTED.md     # English getting started
│   ├── PROJECT_OVERVIEW.md    # Project overview
│   ├── INDEX.md               # Complete index
│   ├── architecture/          # Framework & filosofie / philosophy
│   ├── cases/                 # Case studies (Nederlands)
│   ├── planning/              # Planning & comparisons
│   ├── implementation/        # Implementation guides
│   ├── runbooks/              # Operational procedures
│   └── archief/              # Oude documenten / Old documents
│
├── kind/                      # Kind cluster configs
├── manifests/                 # Kubernetes manifests (RBAC, networking, etc.)
├── tests/                     # Test suites (smoke, security, chaos)
├── *.html                     # Interactive tools (wizard, diagrams)
├── README.md                  # ← Je bent hier / You are here
└── CONTRIBUTING.md           # Contributor guide
```

📖 **[Complete Repository Structure](docs/PROJECT_OVERVIEW.md#-repository-organization)**

---

## 🤝 Bijdragen / Contributing

We verwelkomen bijdragen! / We welcome contributions!

**Manieren om te helpen / Ways to help:**
- 🐛 Fix typos en broken links / Fix typos and broken links
- 📝 Verbeter documentatie / Improve documentation
- 🧪 Test tools en schrijf reviews / Test tools and write reviews
- 🎨 Maak diagrams / Create diagrams
- 🌍 Vertaal naar andere talen / Translate to other languages

📖 **[Contributing Guide](CONTRIBUTING.md)** - Complete contributor onboarding

---

## 📞 Contact & Support

### Help Nodig / Need Help?

- **Issues:** https://github.com/vanhoutenbos/KubeCompass/issues
- **Discussions:** https://github.com/vanhoutenbos/KubeCompass/discussions
- **Documentatie / Documentation:** [docs/INDEX.md](docs/INDEX.md)

### Betrokken Raken / Get Involved

- **Bijdragen / Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md)
- **Sponsoring:** [docs/SPONSORS.md](docs/SPONSORS.md)

---

## 🎯 Filosofie / Philosophy

### Opinionated, but Transparent / Opinionated maar Transparant

We geven eerlijke aanbevelingen met data zodat je zelf weloverwogen keuzes kunt maken.  
We give honest recommendations with data so you can make informed decisions.

### Hands-On, Not Theoretical / Hands-On, Niet Theoretisch

Elke aanbeveling is getest in echte omgevingen. Geen marketing materiaal.  
Every recommendation is tested in real environments. No marketing materials.

### Timing Matters / Timing Is Belangrijk

Sommige beslissingen zijn foundational (CNI, GitOps), andere kun je later toevoegen.  
Some decisions are foundational (CNI, GitOps), others can be added later.

### No Vendor Agenda / Geen Vendor Agenda

We verkopen geen SaaS licenses. Als een tool slecht is, zeggen we dat.  
We don't sell SaaS licenses. If a tool sucks, we'll say so.

📖 **[Volledige Vision / Full Vision](docs/architecture/VISION.md)**

---

## 📜 Licentie / License

Dit project is gelicenseerd onder de **MIT License** - gebruik het vrij, draag bij als je het nuttig vindt.  
This project is licensed under the **MIT License** - use it freely, contribute back if you find it useful.

---

**Gebouwd door / Built by [@vanhoutenbos](https://github.com/vanhoutenbos) en contributors / and contributors.**

**Vind je KubeCompass nuttig? / Find KubeCompass useful?**  
Geef het een ⭐ en vertel het verder! / Give it a ⭐ and spread the word!
