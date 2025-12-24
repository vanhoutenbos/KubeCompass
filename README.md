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

### 1. The Framework
We map the entire Kubernetes operational landscape into **domains** (CI/CD, security, networking, observability, etc.), then identify the key **decision points** within each.

📖 **[Read the Framework](FRAMEWORK.md)**

### 2. The Decision Matrix
An interactive guide that maps domains to tools, with filters for:
- Maturity (Alpha / Beta / Stable / CNCF Graduated)
- Vendor independence
- Operational complexity
- License type

🔧 **[Explore the Matrix](MATRIX.md)** *(coming soon)*

### 3. Testing Methodology
Every tool recommendation is backed by **hands-on testing** using a consistent methodology:
- Installation & setup
- Core functionality
- Failure scenarios
- Upgrade path
- Exit strategy

📋 **[See the Testing Methodology](TESTING_METHODOLOGY.md)**

### 4. Real-World Scenarios
Example architectures for common use cases:
- Startup MVP (cost-optimized, fast iteration)
- Enterprise multi-tenant (compliance, governance, scale)
- Edge computing (resource-constrained, intermittent connectivity)

📚 **[Browse Scenarios](SCENARIOS.md)** *(coming soon)*

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

**What's in progress:**
- [ ] Decision matrix (interactive tool)
- [ ] First tool reviews (starting with CI/CD and security)
- [ ] Real-world scenario examples

**How to contribute:**
- 🐛 Found a gap or error? [Open an issue](https://github.com/vanhoutenbos/KubeCompass/issues)
- 💡 Have a tool recommendation or review? [Submit a PR](https://github.com/vanhoutenbos/KubeCompass/pulls)
- 💬 Want to discuss? [Start a discussion](https://github.com/vanhoutenbos/KubeCompass/discussions)

---

## Quick Start

1. **Start with the [Framework](FRAMEWORK.md)** to understand the decision landscape
2. **Check the [Gap Analysis](GAP_ANALYSIS.md)** to see what we're working on
3. **Review the [Testing Methodology](TESTING_METHODOLOGY.md)** to understand our approach
4. **Explore the [Vision](VISION.md)** to see where we're headed

---

## License

This project is licensed under the **MIT License** — use it freely, contribute back if you find it useful.

---

**Built by [@vanhoutenbos](https://github.com/vanhoutenbos) and contributors.**

If you find KubeCompass useful, give it a ⭐ and spread the word!