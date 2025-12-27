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

### 1. Interactive Tool Selector Wizard 🛒 NEW!
Shop for Kubernetes tools like picking a new computer! Answer a few questions and get personalized recommendations:

🧭 **[Open Tool Selector Wizard](tool-selector-wizard.html)** (Open in browser)

**Features:**
- Webshop-style interactive filtering
- Select your scale, priorities, and preferences
- Get instant personalized tool recommendations
- Export results to Markdown or JSON
- "Use X unless Y" decision guidance
- Complete stack recommendations with rationale

### 2. AI Chat Integration 🤖 NEW!
Describe your use case to an AI assistant and get intelligent "Use X unless..." recommendations:

💬 **[AI Chat Integration Guide](AI_CHAT_GUIDE.md)**

**What you get:**
- Copy-paste prompts for ChatGPT, Claude, Gemini
- Scenario-based templates (startup, enterprise, performance-critical)
- Structured output formats (JSON, Markdown, checklists)
- Interactive workflow patterns
- "Use X unless Y" decision trees
- Integration with KubeCompass framework

### 3. Interactive Visual Diagrams 🎨
Explore our visual diagrams showing domains, subdomains, and decision layers across different scales (single team, multi-team, enterprise):

🖼️ **[View Interactive Diagram](interactive-diagram.html)** (Open in browser)  
📊 **[See All Diagrams](DIAGRAMS.md)** (Complete visual guide)

**What you'll find:**
- Domain architecture overview with dependency flows
- Decision layer timing model (when to decide what)
- Scale-based deployment models (1 team → multi-team → enterprise)
- CNCF alignment mapping
- Interactive navigation (click domains to learn more)

### 4. The Framework
We map the entire Kubernetes operational landscape into **domains** (CI/CD, security, networking, observability, etc.), then identify the key **decision points** within each.

📖 **[Read the Framework](FRAMEWORK.md)**

### 5. The Decision Matrix
An interactive guide that maps domains to tools, with filters for:
- Maturity (Alpha / Beta / Stable / CNCF Graduated)
- Vendor independence
- Operational complexity
- License type

🔧 **[Explore the Matrix](MATRIX.md)**

### 6. Testing Methodology
Every tool recommendation is backed by **hands-on testing** using a consistent methodology:
- Installation & setup
- Core functionality
- Failure scenarios
- Upgrade path
- Exit strategy

📋 **[See the Testing Methodology](TESTING_METHODOLOGY.md)**

### 7. Real-World Scenarios
Example architectures for common use cases:
- Startup MVP (cost-optimized, fast iteration)
- Enterprise multi-tenant (compliance, governance, scale)
- Edge computing (resource-constrained, intermittent connectivity)

📚 **[Browse Scenarios](SCENARIOS.md)**

### 8. Layer 0 & Layer 1 Case Studies
Deep-dive analysis for real-world Kubernetes adoption scenarios:
- **Layer 0: [Dutch Webshop Migration - Foundational Requirements](LAYER_0_WEBSHOP_CASE.md)** (in Dutch): E-commerce platform foundational analysis
  - Availability requirements and downtime expectations
  - Data criticality with RPO/RTO definitions
  - Security baseline and ownership models
  - Vendor independence principles
  - Foundational architecture decisions
- **Layer 1: [Dutch Webshop Migration - Tool Selection](LAYER_1_WEBSHOP_CASE.md)** (in Dutch): Concrete tool choices and platform capabilities
  - Managed Kubernetes selection criteria
  - CNI, GitOps, and CI/CD tool decisions
  - Observability stack (Prometheus, Grafana, Loki)
  - Security implementation (RBAC, secrets management, network policies)
  - Migration roadmap and open questions for implementation
- **🚀 NEW: [Complete Layer 1 Implementation](IMPLEMENTATION_README.md)**: Production-ready implementation
  - **52 files** with 7,800+ lines of Terraform, Kubernetes manifests, CI/CD pipelines
  - **Terraform modules** for infrastructure (cluster, networking, storage)
  - **Kubernetes manifests** for platform and applications (ArgoCD, Cilium, NGINX, Prometheus, Harbor)
  - **GitHub Actions workflows** for automation
  - **Comprehensive documentation** with runbooks and DR procedures
  - **Ready to deploy**: Complete 20-week roadmap to production

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
- [x] Interactive Tool Selector Wizard (webshop-style filtering)
- [x] AI Chat Integration Guide with prompt templates

**What's in progress:**
- [ ] Additional tool reviews (GitOps, secrets management, observability)
- [ ] Additional scenarios (startup MVP, edge computing)
- [ ] Community-contributed AI chat patterns

**Project challenges & opportunities:**
- 📋 **[Project Challenges](CHALLENGES.md)** — see what we're struggling with and how you can help
  - Keeping up with rapidly changing tools
  - Testing across all environments and variants
  - Finding contributors and building community

**How to contribute:**
- 🐛 Found a gap or error? [Open an issue](https://github.com/vanhoutenbos/KubeCompass/issues)
- 💡 Have a tool recommendation or review? [Submit a PR](https://github.com/vanhoutenbos/KubeCompass/pulls)
- 💬 Want to discuss? [Start a discussion](https://github.com/vanhoutenbos/KubeCompass/discussions)

---

## Quick Start

1. **🛒 Try the [Interactive Tool Selector](tool-selector-wizard.html)** — webshop-style tool selection
2. **🤖 Use the [AI Chat Guide](AI_CHAT_GUIDE.md)** — get "Use X unless Y" recommendations from AI
3. **🎨 Explore the [Visual Diagrams](DIAGRAMS.md)** or open [interactive-diagram.html](interactive-diagram.html) in your browser
4. **Start with the [Framework](FRAMEWORK.md)** to understand the decision landscape
5. **Read the [Production-Ready Definition](PRODUCTION_READY.md)** for enterprise compliance requirements
6. **Check the [Decision Matrix](MATRIX.md)** for tool recommendations across all layers
7. **Review the [Scenarios](SCENARIOS.md)** for architecture examples
8. **Study the [Layer 0 Case Studies](LAYER_0_WEBSHOP_CASE.md)** — real-world foundational analysis (Dutch webshop migration)
9. **Explore [Tool Reviews](reviews/)** for detailed hands-on testing results
10. **Check the [Gap Analysis](GAP_ANALYSIS.md)** to see what we're working on
11. **Review the [Testing Methodology](TESTING_METHODOLOGY.md)** to understand our approach
12. **Explore the [Vision](VISION.md)** to see where we're headed
13. **See [CNCF Alignment Analysis](CNCF_ALIGNMENT.md)** for comprehensive CNCF Cloud Native Landscape mapping
14. **Read [Project Challenges](CHALLENGES.md)** to understand our struggles and how you can help

---

## License

This project is licensed under the **MIT License** — use it freely, contribute back if you find it useful.

---

**Built by [@vanhoutenbos](https://github.com/vanhoutenbos) and contributors.**

If you find KubeCompass useful, give it a ⭐ and spread the word!