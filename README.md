# KubeCompass

![Status](https://img.shields.io/badge/Status-POC%20%2F%20Research-yellow) ![License](https://img.shields.io/badge/License-MIT-blue) ![Contributions](https://img.shields.io/badge/Contributions-Welcome-green)

**Opinionated, hands-on guidance for building production-ready Kubernetes platforms — without the vendor fluff.**

> ⚠️ **Current Status**: This project is in **POC/Research phase**. We're actively testing tools, gathering data, and refining the framework. Not all comparisons are complete yet. See [Project Status](#project-status) below.

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
🏦 **[Example: Enterprise Financial Services](cases/enterprise/ENTERPRISE_UNIFIED_CASE.md)** - Complete enterprise case study

**What you get:**
- Structured requirements extraction (Priority methodology)
- "Choose X unless Y" decision rules for all domains
- Provider recommendations mapped to scenarios
- Prioritized question list (Critical/Important/Defer)
- Risk assessment with mitigations
- Machine-readable JSON for automation

### 4. Interactive Visual Diagrams 🎨
Explore our visual diagrams showing domains, subdomains, and decision layers across different scales (single team, multi-team, enterprise):

🌊 **[Complete Deployment Flow](deployment-flow.html)** (Open in browser) — All 18 domains in implementation order  
📊 **[Domain Overview by Priority](domain-overview.html)** (Open in browser) — Interactive cards organized by Critical/Operations/Enhancement  
🗓️ **[Timeline View](deployment-order.html)** (Open in browser) — Week-by-week roadmap  
🚢 **[Kubernetes Ecosystem Infographic](kubernetes-ecosystem.html)** (Open in browser)  
⚙️ **[Kubernetes Architecture Infographic](kubernetes-architecture.html)** (Open in browser)  
🖼️ **[View Interactive Diagram](interactive-diagram.html)** (Open in browser)  
📊 **[See All Diagrams](DIAGRAMS.md)** (Complete visual guide)

**What you'll find:**
- **🚢 Ecosystem Infographic**: Colorful character-driven design showing *which domains* to implement (Priority 0/1/2)
- **⚙️ Architecture Infographic (NEW!)**: Technical visualization showing *how Kubernetes works* - all components (Pods, Services, Deployments), where Service Mesh lives, managed K8s options (AKS/EKS/GKE), and CI/CD pipeline with GitOps
- Domain architecture overview with dependency flows
- Decision layer timing model (when to decide what)
- Scale-based deployment models (1 team → multi-team → enterprise)
- CNCF alignment mapping
- Interactive navigation (click domains to learn more)

### 5. The Framework
We map the entire Kubernetes operational landscape into **domains** (CI/CD, security, networking, observability, etc.), then identify the key **decision points** within each.

📖 **[Read the Framework](docs/architecture/FRAMEWORK.md)**

### 6. The Decision Matrix
An interactive guide that maps domains to tools, with filters for:
- Maturity (Alpha / Beta / Stable / CNCF Graduated)
- Vendor independence
- Operational complexity
- License type

🔧 **[Explore the Matrix](docs/MATRIX.md)**

### 6. Testing Methodology
Every tool recommendation is backed by **hands-on testing** using a consistent methodology:
- Installation & setup
- Core functionality
- Failure scenarios
- Upgrade path
- Exit strategy

📋 **[See the Testing Methodology](docs/implementation/TESTING_METHODOLOGY.md)**

### 7. Real-World Scenarios
Example architectures for common use cases:
- Startup MVP (cost-optimized, fast iteration)
- Enterprise multi-tenant (compliance, governance, scale)
- Edge computing (resource-constrained, intermittent connectivity)

📚 **[Browse Scenarios](docs/planning/SCENARIOS.md)**

### 8. Priority 0, 1 & 2 Case Studies
Deep-dive analysis for real-world Kubernetes adoption scenarios:

#### Original Case Study Documents
- **Priority 0: [Dutch Webshop Migration - Foundational Requirements](docs/cases/PRIORITY_0_WEBSHOP_CASE.md)** (in Dutch): E-commerce platform foundational analysis
  - Availability requirements and downtime expectations
  - Data criticality with RPO/RTO definitions
  - Security baseline and ownership models
  - Vendor independence principles
  - Foundational architecture decisions
- **Priority 1: [Dutch Webshop Migration - Tool Selection](docs/cases/PRIORITY_1_WEBSHOP_CASE.md)** (in Dutch): Concrete tool choices and platform capabilities
  - Managed Kubernetes selection criteria
  - CNI, GitOps, and CI/CD tool decisions
  - Observability stack (Prometheus, Grafana, Loki)
  - Security implementation (RBAC, secrets management, network policies)
  - Migration roadmap and open questions for implementation
- **Priority 2: [Platform Enhancements & Resilience - Decision Framework](docs/cases/PRIORITY_2_WEBSHOP_CASE.md)** (in Dutch): Advanced capability decisions
  - **NOT an implementation guide** - this is a decision framework
  - When to add service mesh, distributed tracing, chaos engineering
  - Trade-offs and timing considerations for each capability
  - Policy enforcement, cost visibility, multi-region readiness
  - "When does this complexity investment become worthwhile?"

#### 🆕 Architecture Review Documents (NEW!)
Structured decision support documentation for audit-proof, interactive architecture decisions:

- **📊 [Architecture Review Summary](docs/architecture/ARCHITECTURE_REVIEW_SUMMARY.md)** — Start here! Executive summary + navigation guide
  - Overview of restructured documentation
  - Stakeholder-specific reading paths (Management, Architects, Engineers, AI Agents)
  - Decision flow from week 1 to implementation
  - Validation checklist for audit-proof documentation

- **🔗 [Priority 0 → Priority 1 Mapping](docs/cases/PRIORITY_0_PRIORITY_1_MAPPING.md)** — Complete traceability matrix
  - Every Priority 1 tool choice traced back to Priority 0 requirements
  - Dependency chains: Business → Technical → Platform → Tooling
  - Trade-off analysis for conflicting requirements
  - Decision logic for interactive filtering and AI agents

- **❓ [Open Questions](docs/OPEN_QUESTIONS.md)** — Categorized by priority (Critical/Important/Can Later)
  - 🔴 Critical questions blocking implementation (9 questions, week 1)
  - 🟠 Important questions for first month (8 questions)
  - 🟢 Can be decided later iteratively (10+ questions)
  - Impact analysis and decision timeline per question

- **🎯 [Decision Rules](docs/DECISION_RULES.md)** — "Choose X unless Y" per tool/function
  - CNI Plugin: Use Cilium unless (Calico expertise OR BGP requirements)
  - GitOps: Use Argo CD unless (GitOps-pure without UI)
  - Observability: Use Prometheus+Grafana unless (enterprise SaaS budget)
  - Database: Use Managed PostgreSQL unless (DBA expertise AND vendor independence absolute)
  - Complete decision trees with JavaScript-like pseudocode for automation

- **🔍 [Improvement Points](docs/IMPROVEMENT_POINTS.md)** — Inconsistencies, gaps & risks
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
- **[Reference Architecture and Patterns](docs/IMPLEMENTATION_README.md)**: Documentation-first implementation guide
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

📖 **[Read the Full Vision](docs/architecture/VISION.md)**  
🔍 **[See How We Compare to Other Initiatives](docs/planning/RELATED_INITIATIVES.md)** — Why KubeCompass is different from CNCF Landscape, OpenSSF, ThoughtWorks Tech Radar, and others

---

## Project Status

🚧 **Early Stage** — actively building the foundation.

�️ **[Interactive Deployment Order](deployment-order.html)** — Visual timeline: what to deploy when  
📊 **[Complete Domain Coverage Overview](docs/DOMAIN_COVERAGE_MASTER_V2.md)** — Master plan with 18 domains, testing targets  
🚀 **[Launch Roadmap](LAUNCH_ROADMAP.md)** — 12-week roadmap to go live with tested tools

**Domain Coverage Progress**:
- ✅ **Fully Tested**: 0/18 domains (all need practical validation)
- 📝 **Theory Documented**: 2/18 domains (CNI, GitOps - need practical testing)
- 🚧 **In Progress**: 4/18 domains (RBAC, Network Policies, Observability, CI/CD)
- ❌ **Not Started**: 12/18 domains
- 🎯 **MVP Goal**: 6-8 critical domains with minimum 2 tested tools each
- 📅 **Target Launch**: Week 12 (mid-March 2026)

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
- 🚀 **[Launch Plan](docs/implementation/LAUNCH_PLAN.md)** — month 1 launch roadmap with weekly execution plan
  - Domain-by-domain tool evaluation strategy
  - AI transparency and validation policy
  - Dataset creation and maintenance approach
  - Step-by-step implementation guide
- 🗺️ **[Domain Roadmap](docs/planning/DOMAIN_ROADMAP.md)** — comprehensive domain-by-domain implementation roadmap **NEW!**
  - All 15 domains with tool options and selection criteria
  - Testing plans for 2+ options per domain (kind/minikube)
  - Week-by-week implementation schedule
  - Decision rules ("Choose X unless Y") for each domain
  - Progress tracking and success criteria
- 📋 **[Documentation Status](docs/DOCUMENTATION_STATUS.md)** — what exists, what's missing, what's next
  - Complete documentation inventory
  - Gap analysis and priorities
  - Week-by-week progress tracking
  - Launch requirements checklist

**Project challenges & opportunities:**
- 📋 **[Project Challenges](docs/planning/CHALLENGES.md)** — see what we're struggling with and how you can help
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
- 💰 **[Sponsor Benefits](docs/SPONSORS.md)** — help us test at production scale
  - Cloud infrastructure credits for managed Kubernetes testing
  - CI/CD infrastructure for automated validation
  - Website hosting and global CDN
  - Complete editorial independence guarantee

---

## Local Testing Platform 🧪 NEW!

**Test Kubernetes platform concepts locally without cloud dependencies.**

We provide a complete Kind-based testing environment to validate platform decisions:

- ✅ **Multiple cluster configurations** (base, Cilium, Calico, multi-node)
- ✅ **Bootstrap scripts** (Windows PowerShell + Linux Bash)
- ✅ **Smoke test suite** for cluster validation
- ✅ **Layered manifests** (Priority 0/1/2 structure)
- ✅ **Reproducible and declarative** (Git-first, IaC approach)

### Quick Start - Local Testing

```bash
# Clone repository
git clone https://github.com/vanhoutenbos/KubeCompass.git
cd KubeCompass

# Create base cluster (Windows)
.\kind\create-cluster.ps1

# Create base cluster (Linux/WSL)
./kind/create-cluster.sh

# Run smoke tests
.\tests\smoke\run-tests.ps1     # Windows
./tests/smoke/run-tests.sh       # Linux

# Deploy test workloads
kubectl apply -f manifests/namespaces/
kubectl apply -f manifests/base/
```

📖 **[Complete Getting Started Guide](docs/GETTING_STARTED.md)**  
📁 **[Kind Configuration Reference](kind/README.md)**  
🧪 **[Testing Documentation](tests/README.md)**

**Testing different CNIs:**
```bash
# Each CNI needs its own cluster
./kind/create-cluster.sh cilium
cilium install

./kind/create-cluster.sh calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

**Testing security policies (NEW!):**
```bash
# Apply RBAC examples (8 patterns)
kubectl apply -f manifests/rbac/

# Apply Network Policies (8 patterns)
kubectl apply -f manifests/networking/

# Run automated security tests
./tests/security/test-rbac.sh
./tests/security/test-network-policies.sh
```

📖 **[RBAC Examples Guide](manifests/rbac/README.md)** — 8 production-ready RBAC patterns  
📖 **[Network Policy Examples Guide](manifests/networking/README.md)** — Zero-trust networking with Cilium/Calico  
🧪 **[Security Testing Guide](tests/security/README.md)** — Automated RBAC and NetworkPolicy validation

**Why local testing?**
- ✅ Validate platform concepts **before** cloud deployment
- ✅ Test tool combinations in **isolated environments**
- ✅ Learn Kubernetes **without cloud costs**
- ✅ Reproduce issues **consistently**
- ✅ Practice IaC and GitOps workflows **locally**

---

## Quick Start

📖 **[Complete Documentation Index](docs/INDEX.md)** — Navigate all documentation by role, task, or topic **NEW!**

### Getting Started Paths

**New to KubeCompass?**
1. **🧪 Set up [Local Testing Environment](docs/GETTING_STARTED.md)** — validate concepts with Kind clusters
2. **🛒 Try the [Interactive Tool Selector](tool-selector-wizard.html)** — webshop-style tool selection
3. **🤖 Use the [AI Chat Guide](docs/AI_CHAT_GUIDE.md)** — get "Use X unless Y" recommendations from AI
4. **🎨 Explore the [Visual Diagrams](docs/DIAGRAMS.md)** or open [interactive-diagram.html](interactive-diagram.html) in your browser

**Ready to dive deep?**
5. **Start with the [Framework](docs/architecture/FRAMEWORK.md)** to understand the decision landscape
6. **Read the [Production-Ready Definition](docs/implementation/PRODUCTION_READY.md)** for enterprise compliance requirements
7. **Check the [Decision Matrix](docs/MATRIX.md)** for tool recommendations across all layers
8. **Review the [Scenarios](docs/planning/SCENARIOS.md)** for architecture examples
9. **🗺️ Check the [Domain Roadmap](docs/planning/DOMAIN_ROADMAP.md)** for step-by-step implementation guidance
   - Complete tool options for all 15 domains (Priority 0, 1, 2)
   - Testing plans with 2+ options per domain
   - Week-by-week schedule for hands-on testing
   - Decision rules to guide tool selection
10. **Study the Priority 0/1/2 Case Studies** — real-world decision frameworks (Dutch webshop migration):
   - **[Priority 0: Foundational Requirements](docs/cases/PRIORITY_0_WEBSHOP_CASE.md)** — Why & constraints
   - **[Priority 1: Tool Selection](docs/cases/PRIORITY_1_WEBSHOP_CASE.md)** — What & how (basic platform)
   - **[Priority 2: Enhancement Decisions](docs/cases/PRIORITY_2_WEBSHOP_CASE.md)** — When to add complexity
   - **🆕 [Architecture Review Summary](docs/architecture/ARCHITECTURE_REVIEW_SUMMARY.md)** — Structured decision support
   - **🏗️ [TransIP IaC Guide](docs/TRANSIP_INFRASTRUCTURE_AS_CODE.md)** — Infrastructure as Code for TransIP
11. **Explore [Tool Reviews](reviews/)** for detailed hands-on testing results

**Need to find specific documentation?**
- 📖 **[Documentation Index](docs/INDEX.md)** — Complete navigation by role, task, and topic
- 📋 **[Documentation Status](docs/DOCUMENTATION_STATUS.md)** — What exists, what's missing
- 🔍 **[Gap Analysis](docs/GAPS_ANALYSIS.md)** — Prioritized documentation work

---

## Repository Structure

```
KubeCompass/
├── kind/                  # Kind cluster configurations
│   ├── cluster-*.yaml     # Cluster configs (base, cilium, calico, multinode)
│   ├── create-cluster.*   # Bootstrap scripts (PowerShell + Bash)
│   └── README.md          # Kind documentation
├── manifests/             # Kubernetes manifests (layered)
│   ├── base/              # Priority 2 - Test workloads
│   ├── namespaces/        # Priority 0 - Namespace definitions
│   ├── rbac/              # Priority 0 - RBAC policies
│   ├── networking/        # Priority 0/1 - Network policies
│   └── README.md          # Manifests documentation
├── tests/                 # Test suites
│   ├── smoke/             # Basic cluster validation
│   ├── policy/            # Policy engine testing
│   ├── chaos/             # Chaos engineering tests
│   └── README.md          # Testing documentation
├── docs/                  # Documentation
│   ├── architecture/      # Framework, vision, methodology
│   ├── cases/             # Priority 0/1/2 case studies
│   ├── planning/          # Roadmaps, challenges, scenarios
│   ├── implementation/    # Implementation guides, production ready
│   ├── runbooks/          # Operational runbooks
│   ├── GETTING_STARTED.md # Local setup guide
│   └── *.md               # Other documentation
├── cases/                 # Use case definitions (JSON + MD)
├── reviews/               # Hands-on tool reviews
├── *.html                 # Interactive tools (wizard, diagrams)
├── README.md              # This file
└── CONTRIBUTING.md        # Contribution guidelines
```

---

## License

This project is licensed under the **MIT License** — use it freely, contribute back if you find it useful.

---

**Built by [@vanhoutenbos](https://github.com/vanhoutenbos) and contributors.**

If you find KubeCompass useful, give it a ⭐ and spread the word!