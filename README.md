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

### 2. AI Case Advisor: Interactive Decision Support 🤖 NEW!
Get personalized Kubernetes platform recommendations through an AI-guided conversation:

💬 **[AI Case Advisor](AI_CASE_ADVISOR.md)** - Answer 5 critical questions, receive tailored architecture

**Interactive workflow:**
- AI asks critical questions one at a time
- Explains why each question matters for your architecture
- Provides context-aware responses based on your answers
- Generates personalized provider recommendations and tool stack
- Includes "Choose X unless Y" decision rules specific to your organization

**Also available:**
- **[AI Chat Integration Guide](AI_CHAT_GUIDE.md)** - Copy-paste prompts for ChatGPT, Claude, Gemini
- Scenario-based templates and structured output formats

### 3. Unified Case Analysis Framework 📋 NEW!
Transform raw requirements into structured, AI-friendly decision frameworks:

📖 **[Unified Case Structure](UNIFIED_CASE_STRUCTURE.md)** - Template for case analysis  
📘 **[Case Analysis Template](CASE_ANALYSIS_TEMPLATE.md)** - Step-by-step guide for creating new cases  
📚 **[Example: Webshop Migration](cases/webshop/WEBSHOP_UNIFIED_CASE.md)** - Complete SME case study

**What you get:**
- Structured requirements extraction (Layer 0/1/2 methodology)
- "Choose X unless Y" decision rules for all domains
- Provider recommendations mapped to scenarios
- Prioritized question list (Critical/Important/Defer)
- Risk assessment with mitigations
- Machine-readable JSON for automation

### 4. Interactive Visual Diagrams 🎨
Explore our visual diagrams showing domains, subdomains, and decision layers across different scales (single team, multi-team, enterprise):

🖼️ **[View Interactive Diagram](interactive-diagram.html)** (Open in browser)  
📊 **[See All Diagrams](DIAGRAMS.md)** (Complete visual guide)

**What you'll find:**
- Domain architecture overview with dependency flows
- Decision layer timing model (when to decide what)
- Scale-based deployment models (1 team → multi-team → enterprise)
- CNCF alignment mapping
- Interactive navigation (click domains to learn more)

### 5. The Framework
We map the entire Kubernetes operational landscape into **domains** (CI/CD, security, networking, observability, etc.), then identify the key **decision points** within each.

📖 **[Read the Framework](FRAMEWORK.md)**

### 6. The Decision Matrix
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

### 8. Layer 0, 1 & 2 Case Studies
Deep-dive analysis for real-world Kubernetes adoption scenarios:

#### Original Case Study Documents
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
- **Layer 2: [Platform Enhancements & Resilience - Decision Framework](LAYER_2_WEBSHOP_CASE.md)** (in Dutch): Advanced capability decisions
  - **NOT an implementation guide** - this is a decision framework
  - When to add service mesh, distributed tracing, chaos engineering
  - Trade-offs and timing considerations for each capability
  - Policy enforcement, cost visibility, multi-region readiness
  - "When does this complexity investment become worthwhile?"

#### 🆕 Architecture Review Documents (NEW!)
Structured decision support documentation for audit-proof, interactive architecture decisions:

- **📊 [Architecture Review Summary](ARCHITECTURE_REVIEW_SUMMARY.md)** — Start here! Executive summary + navigation guide
  - Overview of restructured documentation
  - Stakeholder-specific reading paths (Management, Architects, Engineers, AI Agents)
  - Decision flow from week 1 to implementation
  - Validation checklist for audit-proof documentation

- **🔗 [Layer 0 → Layer 1 Mapping](LAYER_0_LAYER_1_MAPPING.md)** — Complete traceability matrix
  - Every Layer 1 tool choice traced back to Layer 0 requirements
  - Dependency chains: Business → Technical → Platform → Tooling
  - Trade-off analysis for conflicting requirements
  - Decision logic for interactive filtering and AI agents

- **❓ [Open Questions](OPEN_QUESTIONS.md)** — Categorized by priority (Critical/Important/Can Later)
  - 🔴 Critical questions blocking implementation (9 questions, week 1)
  - 🟠 Important questions for first month (8 questions)
  - 🟢 Can be decided later iteratively (10+ questions)
  - Impact analysis and decision timeline per question

- **🎯 [Decision Rules](DECISION_RULES.md)** — "Choose X unless Y" per tool/function
  - CNI Plugin: Use Cilium unless (Calico expertise OR BGP requirements)
  - GitOps: Use Argo CD unless (GitOps-pure without UI)
  - Observability: Use Prometheus+Grafana unless (enterprise SaaS budget)
  - Database: Use Managed PostgreSQL unless (DBA expertise AND vendor independence absolute)
  - Complete decision trees with JavaScript-like pseudocode for automation

- **🔍 [Improvement Points](IMPROVEMENT_POINTS.md)** — Inconsistencies, gaps & risks
  - 4 critical inconsistencies requiring resolution
  - 5 missing assumptions that need validation
  - 3 conflicting requirements with resolution options
  - 5 documentation gaps (missing runbooks, procedures)
  - 5 insufficiently mitigated risks

- **🏗️ [TransIP Infrastructure as Code Guide](docs/TRANSIP_INFRASTRUCTURE_AS_CODE.md)** — Practical IaC approach for TransIP Kubernetes
  - Hybrid IaC strategy (manual cluster + Terraform for in-cluster resources)
  - Node scaling solutions without native autoscaler
  - Provider comparison with Terraform support status
  - Migration paths and vendor independence strategies
  - Complete implementation examples and decision rules

**Use Cases:**
- **Architecture Review**: Validate decision traceability and consistency
- **Project Planning**: Prioritize questions and decisions (critical first)
- **AI Decision Agents**: Structured input for automated recommendations
- **Interactive Site**: Foundation for user-guided architecture decisions
- **Compliance/Audit**: Proof that all decisions are traceable to requirements

#### Implementation Reference
- **[Reference Architecture and Patterns](IMPLEMENTATION_README.md)**: Documentation-first implementation guide
  - **Architecture patterns** for infrastructure, platform, and application layers
  - **Decision frameworks** with "Choose X unless Y" rules
  - **Best practices** for security, observability, GitOps, and disaster recovery
  - **Reference architecture**: Complete patterns and guidance, adaptable to your context
  - **Managed Kubernetes nuances**: Clear lock-in analysis and mitigation strategies
  - **Note**: KubeCompass is documentation-first. Create your own implementation based on these patterns.

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
🔍 **[See How We Compare to Other Initiatives](RELATED_INITIATIVES.md)** — Why KubeCompass is different from CNCF Landscape, OpenSSF, ThoughtWorks Tech Radar, and others

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

**Project planning & strategy:**
- 🚀 **[Launch Plan](LAUNCH_PLAN.md)** — month 1 launch roadmap with weekly execution plan
  - Domain-by-domain tool evaluation strategy
  - AI transparency and validation policy
  - Dataset creation and maintenance approach
  - Step-by-step implementation guide
- 📋 **[Documentation Status](DOCUMENTATION_STATUS.md)** — what exists, what's missing, what's next
  - Complete documentation inventory
  - Gap analysis and priorities
  - Week-by-week progress tracking
  - Launch requirements checklist

**Project challenges & opportunities:**
- 📋 **[Project Challenges](CHALLENGES.md)** — see what we're struggling with and how you can help
  - Keeping up with rapidly changing tools
  - Testing across all environments and variants
  - Finding contributors and building community

**How to contribute:**
- 📖 **[Contributing Guide](CONTRIBUTING.md)** — comprehensive contributor onboarding
  - Quick contributions (typos, links, examples)
  - Tool reviews with testing methodology
  - Real-world scenarios from your experience
  - Domain ownership opportunities
- 🐛 Found a gap or error? [Open an issue](https://github.com/vanhoutenbos/KubeCompass/issues)
- 💡 Have a tool recommendation or review? [Submit a PR](https://github.com/vanhoutenbos/KubeCompass/pulls)
- 💬 Want to discuss? [Start a discussion](https://github.com/vanhoutenbos/KubeCompass/discussions)

**Seeking sponsors:**
- 💰 **[Sponsor Benefits](SPONSORS.md)** — help us test at production scale
  - Cloud infrastructure credits for managed Kubernetes testing
  - CI/CD infrastructure for automated validation
  - Website hosting and global CDN
  - Complete editorial independence guarantee

---

## Quick Start

1. **🛒 Try the [Interactive Tool Selector](tool-selector-wizard.html)** — webshop-style tool selection
2. **🤖 Use the [AI Chat Guide](AI_CHAT_GUIDE.md)** — get "Use X unless Y" recommendations from AI
3. **🎨 Explore the [Visual Diagrams](DIAGRAMS.md)** or open [interactive-diagram.html](interactive-diagram.html) in your browser
4. **Start with the [Framework](FRAMEWORK.md)** to understand the decision landscape
5. **Read the [Production-Ready Definition](PRODUCTION_READY.md)** for enterprise compliance requirements
6. **Check the [Decision Matrix](MATRIX.md)** for tool recommendations across all layers
7. **Review the [Scenarios](SCENARIOS.md)** for architecture examples
8. **Study the Layer 0/1/2 Case Studies** — real-world decision frameworks (Dutch webshop migration):
   - **[Layer 0: Foundational Requirements](LAYER_0_WEBSHOP_CASE.md)** — Why & constraints
   - **[Layer 1: Tool Selection](LAYER_1_WEBSHOP_CASE.md)** — What & how (basic platform)
   - **[Layer 2: Enhancement Decisions](LAYER_2_WEBSHOP_CASE.md)** — When to add complexity
   - **🆕 [Architecture Review Summary](ARCHITECTURE_REVIEW_SUMMARY.md)** — Structured decision support (NEW!)
   - **🏗️ [TransIP IaC Guide](docs/TRANSIP_INFRASTRUCTURE_AS_CODE.md)** — Infrastructure as Code for TransIP (NEW!)
9. **Explore [Tool Reviews](reviews/)** for detailed hands-on testing results
10. **Check the [Gap Analysis](GAP_ANALYSIS.md)** to see what we're working on
11. **Review the [Testing Methodology](TESTING_METHODOLOGY.md)** to understand our approach
12. **Explore the [Vision](VISION.md)** to see where we're headed
13. **See [CNCF Alignment Analysis](CNCF_ALIGNMENT.md)** for comprehensive CNCF Cloud Native Landscape mapping
14. **Read [Related Initiatives](RELATED_INITIATIVES.md)** to understand how KubeCompass differs from CNCF Landscape, OpenSSF, ThoughtWorks Tech Radar, and others
15. **Read [Project Challenges](CHALLENGES.md)** to understand our struggles and how you can help

---

## License

This project is licensed under the **MIT License** — use it freely, contribute back if you find it useful.

---

**Built by [@vanhoutenbos](https://github.com/vanhoutenbos) and contributors.**

If you find KubeCompass useful, give it a ⭐ and spread the word!