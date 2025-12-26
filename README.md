# KubeCompass

**Opinionated, hands-on guidance for building production-ready Kubernetes platforms — without the vendor fluff.**

---

## What is KubeCompass?

Kubernetes is powerful, but the ecosystem is **overwhelming**. Every domain (networking, security, CI/CD, observability, etc.) has dozens of tools competing for attention. Most are marketed with buzzwords and vendor pitches, leaving you wondering:

- *Which tools actually work in production?*
- *Which decisions are hard to reverse later?*
- *What's hype vs. what's essential?*

KubeCompass cuts through the noise with:

✅ **Opinionated recommendations** based on real-world experience  
✅ **Hands-on testing** — every tool is actually used, not just researched  
✅ **Decision timing guidance** — know what to decide Day 1 vs. what can wait  
✅ **Transparent scoring** — maturity, lock-in risk, operational complexity, and more  
✅ **No vendor bias** — built by practitioners, for practitioners  

---

## Who Is This For?

**Primary audience:**  
DevOps engineers, SREs, platform engineers, and developers looking for **practical, hands-on guidance** to build and maintain Kubernetes clusters — without enterprise overhead or vendor pitches.

**What this IS:**
- A pragmatic guide for **practitioners** who need to make real decisions
- Focused on **"how do I get this working and keep it running"**
- Bottom-up: built by engineers, for engineers

**What this is NOT (yet):**  
- A compliance-first framework tailored for banks, healthcare, or government
- A top-down governance manual for change advisory boards
- A vendor comparison for procurement teams or CISOs

*(Those use cases are on the long-term roadmap, but not the primary focus today.)*

---

If you're lost in the Kubernetes ecosystem and need a rational push in the right direction — **this is for you.**

---

## How It Works

### 1. Interactive Visual Diagrams 🎨 NEW!
Explore our visual diagrams showing domains, subdomains, and decision layers across different scales (single team, multi-team, enterprise):

🖼️ **[View Interactive Diagram](interactive-diagram.html)** (Open in browser)  
📊 **[See All Diagrams](DIAGRAMS.md)** (Complete visual guide)

**What you'll find:**
- Domain architecture overview with dependency flows
- Decision layer timing model (when to decide what)
- Scale-based deployment models (1 team → multi-team → enterprise)
- CNCF alignment mapping
- Interactive navigation (click domains to learn more)

### 2. The Framework
We map the entire Kubernetes operational landscape into **domains** (CI/CD, security, networking, observability, etc.), then identify the key **decision points** within each.

📖 **[Read the Framework](FRAMEWORK.md)**

### 3. The Decision Matrix
An interactive guide that maps domains to tools, with filters for:
- Maturity (Alpha / Beta / Stable / CNCF Graduated)
- Vendor independence
- Operational complexity
- License type

🔧 **[Explore the Matrix](MATRIX.md)**

### 4. Testing Methodology
Every tool recommendation is backed by **hands-on testing** using a consistent methodology:
- Installation & setup
- Core functionality
- Failure scenarios
- Upgrade path
- Exit strategy

📋 **[See the Testing Methodology](TESTING_METHODOLOGY.md)**

### 5. Real-World Scenarios
Example architectures for common use cases:
- Startup MVP (cost-optimized, fast iteration)
- Enterprise multi-tenant (compliance, governance, scale)
- Edge computing (resource-constrained, intermittent connectivity)

📚 **[Browse Scenarios](SCENARIOS.md)**

### 6. Case Studies (NEW!)
Detailed, layer-by-layer case studies for systematic platform design:
- E-Commerce platform migrating from VMs to Kubernetes
- Designed for iterative use with AI assistants
- Progress from business context → capabilities → tool selection

🎯 **[Explore Case Studies](case-studies/)**

---

## Philosophy

### Opinionated, but Transparent
We give you **our honest take** — but we show the data so you can disagree intelligently.

### Hands-On, Not Theoretical
Every recommendation is tested in real environments. No regurgitated marketing materials.

### Timing Matters
Some decisions (CNI, GitOps) are foundational and hard to change. Others (image scanning, chaos tools) are easy to add later. We help you prioritize.

### No Vendor Agenda
We're not here to sell you SaaS licenses or enterprise support contracts. If a tool sucks, we'll say so.

📖 **[Read the Full Vision](VISION.md)**

---

## Project Status

🚧 **Early Stage** — actively building the foundation.

**What's ready:**
- [x] Framework structure and domains
- [x] Testing methodology
- [x] Scoring rubric
- [x] Decision layers (foundational vs. additive)
- [x] Vision and philosophy
- [x] Production-ready definition
- [x] Decision matrix with tool recommendations
- [x] Enterprise multi-tenant scenario
- [x] Visual diagrams and interactive navigation
- [x] Scale-based deployment models (single team, multi-team, enterprise)
- [x] Layer-by-layer case studies (e-commerce legacy migration)

**What's in progress:**
- [ ] Additional tool reviews (GitOps, secrets management, observability)
- [ ] Additional scenarios (startup MVP, edge computing)
- [ ] Fully interactive filtering for decision matrix
- [ ] Enhanced interactive features (guided wizard, architecture generator)

**How to contribute:**
- 🐛 Found a gap or error? [Open an issue](https://github.com/vanhoutenbos/KubeCompass/issues)
- 💡 Have a tool recommendation or review? [Submit a PR](https://github.com/vanhoutenbos/KubeCompass/pulls)
- 💬 Want to discuss? [Start a discussion](https://github.com/vanhoutenbos/KubeCompass/discussions)

---

## Quick Start

1. **🎨 Explore the [Visual Diagrams](DIAGRAMS.md)** or open [interactive-diagram.html](interactive-diagram.html) in your browser
2. **Start with the [Framework](FRAMEWORK.md)** to understand the decision landscape
3. **Read the [Production-Ready Definition](PRODUCTION_READY.md)** for enterprise compliance requirements
4. **Check the [Decision Matrix](MATRIX.md)** for tool recommendations across all layers
5. **Review the [Scenarios](SCENARIOS.md)** for architecture examples
6. **Dive into [Case Studies](case-studies/)** for layer-by-layer platform design guides
7. **Explore [Tool Reviews](reviews/)** for detailed hands-on testing results
8. **Check the [Gap Analysis](GAP_ANALYSIS.md)** to see what we're working on
9. **Review the [Testing Methodology](TESTING_METHODOLOGY.md)** to understand our approach
10. **Explore the [Vision](VISION.md)** to see where we're headed
11. **See [CNCF Alignment Analysis](CNCF_ALIGNMENT.md)** for comprehensive CNCF Cloud Native Landscape mapping

---

## License

This project is licensed under the **MIT License** — use it freely, contribute back if you find it useful.

---

**Built by [@vanhoutenbos](https://github.com/vanhoutenbos) and contributors.**

If you find KubeCompass useful, give it a ⭐ and spread the word!