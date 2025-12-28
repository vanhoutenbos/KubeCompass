# Related Initiatives & Why KubeCompass is Different

This document provides an honest, unfiltered assessment of existing organizations, frameworks, and initiatives in the Kubernetes and cloud-native ecosystem — and explains why KubeCompass fills a unique gap that none of them address.

**The Short Version**: There are surprisingly few initiatives that do what you really need: provide neutral, structured, architecture-focused guidance for Kubernetes platform decisions. Most cover pieces of the puzzle, but none combine all the elements KubeCompass does.

---

## 1. CNCF Cloud Native Landscape

**What it is**: Comprehensive catalog of cloud-native projects  
**Score/Maturity**: ✅ Yes (Sandbox → Incubating → Graduated)

### Strengths
- **Objective status**: Clear project maturity indicators
- **Extremely complete**: Covers virtually every cloud-native tool
- **Vendor-neutral governance**: CNCF provides independent oversight

### Weaknesses
- **No "what should I choose"**: It's a directory, not a decision guide
- **No context per use case**: Lists tools without explaining when to use them
- **No architecture advice**: Doesn't tell you how tools fit together

### Verdict
**Inventory ≠ Guide.** This is a phonebook, not a map.

CNCF Landscape tells you what exists. KubeCompass tells you what to choose and why.

---

## 2. Apache Software Foundation

**What it is**: Open source governance organization  
**Score/Maturity**: ✅ Yes (Incubator → Top Level Project)

### Strengths
- **Strict governance**: Strong community health standards
- **Apache Way**: Proven model for sustainable open source

### Weaknesses
- **No architecture context**: Governance doesn't equal operational guidance
- **Not Kubernetes-specific**: Broad OSS focus, not platform engineering

### Verdict
**Useful as signal for mature OSS, not as platform guide.**

Apache projects are generally well-governed, but that doesn't tell you which one to use for your Kubernetes CNI or GitOps needs.

---

## 3. Linux Foundation (Beyond CNCF)

**Examples**: LF AI & Data, OpenSSF, eBPF Foundation

**Score/Maturity**: ⚠️ Sometimes (project status, security best practices)

### Strengths
- **Governance & compliance focus**: Strong foundation backing
- **Domain expertise**: Specialized knowledge in subdomains

### Weaknesses
- **Fragmented**: Multiple foundations, no unified story
- **No end-to-end guidance**: Each focuses on narrow domain

### Verdict
**Interesting as sub-domain input, not as complete picture.**

Useful for specific areas (like eBPF for networking), but doesn't provide integrated platform guidance.

---

## 4. OpenSSF Scorecard

**What it is**: Security maturity scoring for open source projects  
**Score/Maturity**: ✅ Yes (numerical score)

**Website**: [https://scorecard.dev](https://scorecard.dev)  
**GitHub**: [https://github.com/ossf/scorecard](https://github.com/ossf/scorecard)

### Strengths
- **Measurable**: Clear numerical security hygiene scores
- **Automated**: Continuous scanning and updates
- **Actionable**: Specific security practices checked

### Weaknesses
- **Security hygiene only**: Doesn't cover operational reality
- **No architecture guidance**: Tells you if a project is secure, not if it fits your needs
- **No tool selection advice**: High score doesn't mean right tool for you

### Verdict
**Perfect for "security maturity" dimension, but absolutely not sufficient alone.**

KubeCompass integrates OpenSSF Scorecard data as one of many decision factors — security hygiene is necessary but not sufficient for tool selection.

**How KubeCompass Uses It**:
- Security maturity is one scoring dimension in our methodology
- Combined with operational complexity, vendor lock-in, community health, etc.
- We answer: "Is this secure AND operationally viable AND right for your use case?"

---

## 5. SLSA (Supply-chain Levels for Software Artifacts)

**What it is**: Maturity model for software supply chain security  
**Score/Maturity**: ✅ Yes (Level 1–4)

**Website**: [https://slsa.dev](https://slsa.dev)

### Strengths
- **Clear maturity framework**: Well-defined progression levels
- **Perfect fit for CI/CD & GitOps**: Directly applicable to Kubernetes workflows
- **Industry adoption**: Growing standard for supply chain security

### Weaknesses
- **Abstract**: Framework, not tool recommendations
- **No tool selection**: Tells you *what* to achieve, not *how* or *with what*

### Verdict
**Ideal as reference framework, not as tool selector.**

SLSA is excellent for defining *requirements*. KubeCompass helps you *implement* those requirements with specific tool recommendations.

**How KubeCompass Uses It**:
- SLSA levels inform our "Production-Ready" definition
- We map tools to SLSA capabilities (e.g., "Argo CD supports SLSA Level 3")
- We provide implementation paths: "To achieve SLSA Level 3, use X for build provenance and Y for signing"

---

## 6. Gartner / Forrester / GigaOm

**What it is**: Commercial analyst firms  
**Score/Maturity**: "Magic Quadrants", "Waves", "Radar"

### Strengths
- **Market positioning**: Shows vendor competitive landscape
- **Enterprise context**: Useful for large organization decision-making
- **Analyst expertise**: Deep industry knowledge

### Weaknesses (Critical)
- **Paid content**: Expensive reports, access-restricted
- **Vendor-biased**: Pay-to-play influences rankings
- **Minimal open source focus**: Enterprise vendor products prioritized
- **No hands-on testing**: Based on vendor briefings, not real-world usage

### Verdict
**Architects read this, engineers ignore it. KubeCompass intentionally goes against this model.**

We're building the guide engineers actually trust — based on hands-on experience, not vendor marketing budgets.

---

## 7. ThoughtWorks Technology Radar

**What it is**: Adopt / Trial / Assess / Hold maturity model  
**Score/Maturity**: ✅ Yes (but subjective)

**Website**: [https://www.thoughtworks.com/radar](https://www.thoughtworks.com/radar)

### Strengths
- **Experience-driven**: Based on real consultancy projects
- **Honest about trade-offs**: Explains why recommendations change over time
- **Clear categories**: Easy to understand maturity progression

### Weaknesses
- **Not comprehensive**: Selective tool coverage based on ThoughtWorks projects
- **Not Kubernetes-specific**: Broad technology focus, not platform engineering
- **No structured framework**: No domain taxonomy or decision tree

### Verdict
**This comes very close to KubeCompass's mindset. Major inspiration source.**

ThoughtWorks Radar has the right *philosophy* (opinionated, honest, trade-off aware), but KubeCompass adds:
- Kubernetes-specific focus
- Complete domain coverage (networking, security, observability, etc.)
- Decision timing framework (Layer 0/1/2)
- Hands-on testing methodology
- "Choose X unless Y" decision rules

---

## 8. Awesome Lists / GitHub Landscapes

**Examples**:
- [awesome-kubernetes](https://github.com/ramitsurana/awesome-kubernetes)
- [awesome-cloud-native](https://github.com/rootsongjc/awesome-cloud-native)
- Platform engineering lists

**Score/Maturity**: ❌ No

### Strengths
- **Community-driven**: Crowdsourced knowledge
- **Comprehensive**: Broad tool coverage

### Weaknesses
- **Everything listed equally**: No prioritization or context
- **No decision guidance**: "Here are 50 tools, good luck"
- **No architecture advice**: Tools listed without explaining how they fit together
- **Maintenance challenges**: Often outdated or abandoned

### Verdict
**Good source, terrible guide.**

Awesome lists are useful for *discovering* tools, but useless for *choosing* between them.

KubeCompass uses awesome lists as input sources, then adds:
- Maturity scoring
- Architecture context
- Decision timing
- Trade-off analysis
- "Choose X unless Y" logic

---

## 9. Vendor "Reference Architectures"

**Examples**:
- AWS EKS Best Practices
- Azure AKS Landing Zones
- Red Hat OpenShift Architectures
- Google GKE Blueprints

**Score/Maturity**: ⚠️ Implicit

### Strengths
- **Production-tested**: Based on real deployments
- **Detailed guidance**: Step-by-step implementation
- **Integrated solutions**: Tools designed to work together

### Weaknesses (Critical)
- **Vendor lock-in by design**: Architectures optimize for vendor ecosystem
- **Exit strategy missing**: No guidance on migrating away
- **Biased tool selection**: Vendor products prioritized over alternatives
- **Hidden costs**: TCO not always transparent

### Verdict
**Useful to read, dangerous to follow blindly.**

Vendor architectures can teach you a lot about operational patterns, but you must extract the *principles* and apply them vendor-agnostically.

**How KubeCompass Differs**:
- Multi-cloud and on-prem guidance
- Explicit vendor lock-in risk scoring
- Exit strategy documentation for every tool
- Managed vs. self-hosted trade-off analysis

---

## The Hard Conclusion

**No single organization combines:**
- ✅ Domains (like CNCF Landscape)
- ✅ Maturity / scores (like OpenSSF, SLSA)
- ✅ Role and goal-oriented thinking
- ✅ Vendor-agnostic (unlike Gartner or vendor docs)
- ✅ Hands-on tested (unlike most guides)
- ✅ Architecture-focused, not marketing

**That gap is exactly where KubeCompass sits.**

---

## Why KubeCompass Has the Right to Exist

KubeCompass combines elements that currently exist separately:

| What Exists Today | What KubeCompass Adds |
|-------------------|----------------------|
| CNCF Landscape | Context & choices |
| OSS maturity frameworks | Architecture impact |
| ThoughtWorks Tech Radar | Kubernetes-first focus |
| Vendor documentation | Exit strategy |
| Awesome lists | Real opinions and testing |

---

## What KubeCompass Is Building

Not "yet another landscape," but an:

> **Architectural Decision System for Kubernetes**

Or, as we've said internally:

> **"The SAFe framework, but for Kubernetes platforms."**

---

## Our Position on Runtime Security

**Yes, runtime security deserves to be a domain.**

Not as a tool list, but as a capability with maturity levels:
- **Layer 0**: Pod Security Standards, basic RBAC
- **Layer 1**: Network policies, image scanning
- **Layer 2**: Runtime threat detection (Falco, Tetragon), anomaly detection

This is already reflected in KubeCompass's **Domain 1.4: Runtime Security** in the [Framework](FRAMEWORK.md).

---

## What KubeCompass Will NOT Do

**Don't try to be more complete than CNCF**  
→ We curate and opine, they catalog

**Don't score everything with numbers**  
→ Context matters more than arbitrary rankings

**Don't pretend to be neutral without opinion**  
→ Our strength = experienced, critical, tested, sometimes opinionated

---

## Our Competitive Advantage

**KubeCompass is:**
- ✅ Experienced (battle-tested knowledge)
- ✅ Critical (we'll call out BS)
- ✅ Tested (hands-on validation)
- ✅ Opinionated (we take a stand)
- ✅ Transparent (show the data, explain the reasoning)

**We're not trying to be the most neutral. We're trying to be the most useful.**

---

## Integration with KubeCompass

This comparative analysis informs several KubeCompass components:

1. **[Methodology](METHODOLOGY.md)**: Incorporates OpenSSF Scorecard and SLSA as scoring dimensions
2. **[Framework](FRAMEWORK.md)**: CNCF Landscape alignment for domain taxonomy
3. **[Vision](VISION.md)**: Philosophical distinction from analyst firms and vendor architectures
4. **[Decision Matrix](MATRIX.md)**: Maturity indicators from CNCF, Apache, OpenSSF

---

## References & Further Reading

- **CNCF Cloud Native Landscape**: [https://landscape.cncf.io](https://landscape.cncf.io)
- **Apache Software Foundation**: [https://www.apache.org](https://www.apache.org)
- **OpenSSF Scorecard**: [https://scorecard.dev](https://scorecard.dev)
- **SLSA**: [https://slsa.dev](https://slsa.dev)
- **ThoughtWorks Technology Radar**: [https://www.thoughtworks.com/radar](https://www.thoughtworks.com/radar)
- **awesome-kubernetes**: [https://github.com/ramitsurana/awesome-kubernetes](https://github.com/ramitsurana/awesome-kubernetes)

---

**Last Updated**: 2025-12-28

**Want to discuss?** [Open an issue](https://github.com/vanhoutenbos/KubeCompass/issues) or [start a discussion](https://github.com/vanhoutenbos/KubeCompass/discussions).
