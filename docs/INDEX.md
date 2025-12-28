# KubeCompass Documentation Index

**Complete guide to navigating KubeCompass documentation**

---

## 🚀 Quick Start Paths

### New to Kubernetes?
1. Start: [Getting Started Guide](GETTING_STARTED.md)
2. Understand: [Framework](architecture/FRAMEWORK.md) - What decisions you need to make
3. Learn: [Vision](architecture/VISION.md) - Philosophy behind KubeCompass
4. Explore: [Tool Selector Wizard](../tool-selector-wizard.html) - Interactive tool selection

### Planning a Migration?
1. Start: [Layer 0 Case Study](cases/LAYER_0_WEBSHOP_CASE.md) - Requirements analysis
2. Continue: [Layer 1 Case Study](cases/LAYER_1_WEBSHOP_CASE.md) - Tool selection
3. Advanced: [Layer 2 Case Study](cases/LAYER_2_WEBSHOP_CASE.md) - Enhancement decisions
4. Reference: [Architecture Review Summary](architecture/ARCHITECTURE_REVIEW_SUMMARY.md)

### Setting Up Locally?
1. Install: [Docker Installation Guide](DOCKER_INSTALLATION.md)
2. Setup: [Getting Started with Kind](GETTING_STARTED.md)
3. Test: [Smoke Tests](../tests/smoke/README.md)
4. Deploy: [Manifests Guide](../manifests/README.md)

### Choosing Tools?
1. Overview: [Decision Matrix](MATRIX.md) - All tool recommendations
2. Details: [Decision Rules](DECISION_RULES.md) - "Choose X unless Y" logic
3. Compare: [Planning Directory](#planning--comparisons) - Detailed comparisons
4. Validate: [Testing Methodology](implementation/TESTING_METHODOLOGY.md)

---

## 📁 Documentation Structure

### Architecture & Philosophy

| Document | Purpose | Audience |
|----------|---------|----------|
| [Framework](architecture/FRAMEWORK.md) | Complete domain structure, decision layers | All |
| [Vision](architecture/VISION.md) | Project philosophy and goals | All |
| [Methodology](architecture/METHODOLOGY.md) | How we evaluate tools | Contributors |
| [Architecture Review](architecture/ARCHITECTURE_REVIEW_SUMMARY.md) | Structured decision support | Architects |

### Case Studies & Examples

| Document | Purpose | Audience |
|----------|---------|----------|
| [Layer 0: Webshop](cases/LAYER_0_WEBSHOP_CASE.md) | Foundation requirements (Dutch) | Platform Engineers |
| [Layer 1: Webshop](cases/LAYER_1_WEBSHOP_CASE.md) | Tool selection (Dutch) | Platform Engineers |
| [Layer 2: Webshop](cases/LAYER_2_WEBSHOP_CASE.md) | Enhancement decisions (Dutch) | Senior Engineers |
| [Unified Case Structure](cases/UNIFIED_CASE_STRUCTURE.md) | Template for new cases | Contributors |
| [Case Analysis Template](cases/CASE_ANALYSIS_TEMPLATE.md) | How to create cases | Contributors |
| [Webshop Overview](cases/WEBSHOP_LAYERS_OVERVIEW.md) | All layers combined | All |
| [Layer 0→1 Mapping](cases/LAYER_0_LAYER_1_MAPPING.md) | Traceability matrix | Architects |

### Planning & Comparisons

| Document | Purpose | Audience |
|----------|---------|----------|
| [CNI Comparison](planning/CNI_COMPARISON.md) | Cilium vs Calico vs others | Network Engineers |
| [GitOps Comparison](planning/GITOPS_COMPARISON.md) | ArgoCD vs Flux vs GitLab | Platform Engineers |
| [Secrets Management](planning/SECRETS_MANAGEMENT.md) | ESO vs Sealed Secrets vs SOPS | Platform Engineers |
| [ArgoCD Guide](planning/ARGOCD_GUIDE.md) | Hands-on ArgoCD walkthrough | Platform Engineers |
| [Flux Guide](planning/FLUX_GUIDE.md) | Hands-on Flux walkthrough | Platform Engineers |
| [GitOps with GitLab](planning/GITOPS_GITLAB.md) | GitLab Agent guide | Platform Engineers |
| [Scenarios](planning/SCENARIOS.md) | Enterprise, startup, edge use cases | All |
| [Domain Roadmap](planning/DOMAIN_ROADMAP.md) | Implementation roadmap | Contributors |
| [Challenges](planning/CHALLENGES.md) | Project challenges | Contributors |
| [Gap Analysis](planning/GAP_ANALYSIS.md) | What's missing | Contributors |
| [Open Questions](planning/OPEN_QUESTIONS.md) | Unresolved decisions | Architects |
| [CNCF Alignment](planning/CNCF_ALIGNMENT.md) | CNCF landscape mapping | All |
| [Related Initiatives](planning/RELATED_INITIATIVES.md) | How we differ from others | All |

### Implementation Guides

| Document | Purpose | Audience |
|----------|---------|----------|
| [Getting Started](GETTING_STARTED.md) | Local Kind setup walkthrough | All |
| [Docker Installation](DOCKER_INSTALLATION.md) | Install Docker Desktop/Engine | Beginners |
| [Implementation Guide](IMPLEMENTATION_GUIDE.md) | Reference architecture patterns | Platform Engineers |
| [Testing Methodology](implementation/TESTING_METHODOLOGY.md) | How we test tools | Contributors |
| [Production Ready](implementation/PRODUCTION_READY.md) | Production criteria | Platform Engineers |
| [Launch Plan](implementation/LAUNCH_PLAN.md) | Month 1 roadmap | Contributors |
| [Implementation Complete](implementation/IMPLEMENTATION_COMPLETE.md) | Completion checklist | Platform Engineers |
| [Implementation Summary](implementation/IMPLEMENTATION_SUMMARY.md) | Quick reference | All |

### Infrastructure as Code

| Document | Purpose | Audience |
|----------|---------|----------|
| [TransIP IaC Guide](TRANSIP_INFRASTRUCTURE_AS_CODE.md) | TransIP Terraform patterns | DevOps |
| [TransIP Quick Start](TRANSIP_QUICK_START.md) | Fast TransIP setup | Platform Engineers |

### Decision Support

| Document | Purpose | Audience |
|----------|---------|----------|
| [Decision Matrix](MATRIX.md) | All tool recommendations | All |
| [Decision Rules](DECISION_RULES.md) | "Choose X unless Y" logic | All |
| [Improvement Points](IMPROVEMENT_POINTS.md) | Known gaps and inconsistencies | Contributors |
| [AI Case Advisor](AI_CASE_ADVISOR.md) | AI-guided recommendations | AI Assistants |
| [AI Chat Guide](AI_CHAT_GUIDE.md) | ChatGPT/Claude prompts | All |

### Operational Runbooks

| Document | Purpose | Audience |
|----------|---------|----------|
| [Deployment Runbook](runbooks/deployment.md) | Step-by-step deployment | DevOps |
| [Disaster Recovery](runbooks/disaster-recovery.md) | DR procedures | SRE |
| [Cluster Provisioning](runbooks/transip-cluster-provisioning.md) | TransIP cluster setup | Platform Engineers |

### Project Meta

| Document | Purpose | Audience |
|----------|---------|----------|
| [Executive Summary](EXECUTIVE_SUMMARY.md) | High-level overview | Management |
| [Documentation Status](DOCUMENTATION_STATUS.md) | What exists, what's missing | Contributors |
| [Gaps Analysis](GAPS_ANALYSIS.md) | Prioritized documentation gaps | Contributors |
| [Restructuring Summary](RESTRUCTURING_SUMMARY.md) | Recent changes | All |
| [Diagrams](DIAGRAMS.md) | Visual documentation | All |
| [Sponsors](SPONSORS.md) | Sponsorship info | Sponsors |
| [Contributing](../CONTRIBUTING.md) | How to contribute | Contributors |

---

## 🔧 Hands-On Resources

### Kind Clusters

| Resource | Purpose |
|----------|---------|
| [kind/README.md](../kind/README.md) | Complete Kind documentation |
| [kind/cluster-base.yaml](../kind/cluster-base.yaml) | Single-node cluster |
| [kind/cluster-cilium.yaml](../kind/cluster-cilium.yaml) | Cilium CNI testing |
| [kind/cluster-calico.yaml](../kind/cluster-calico.yaml) | Calico CNI testing |
| [kind/cluster-multinode.yaml](../kind/cluster-multinode.yaml) | Multi-node cluster |
| [kind/create-cluster.ps1](../kind/create-cluster.ps1) | Windows bootstrap script |
| [kind/create-cluster.sh](../kind/create-cluster.sh) | Linux bootstrap script |

### Manifests

| Resource | Purpose |
|----------|---------|
| [manifests/README.md](../manifests/README.md) | Manifests overview |
| [manifests/namespaces/](../manifests/namespaces/) | Namespace definitions |
| [manifests/base/](../manifests/base/) | Test workloads |
| [manifests/rbac/](../manifests/rbac/) | RBAC examples |
| [manifests/networking/](../manifests/networking/) | Network policies |

### Tests

| Resource | Purpose |
|----------|---------|
| [tests/README.md](../tests/README.md) | Testing overview |
| [tests/smoke/](../tests/smoke/) | Smoke test suite |
| [tests/policy/](../tests/policy/) | Policy validation |
| [tests/chaos/](../tests/chaos/) | Chaos engineering |

### Interactive Tools

| Resource | Purpose |
|----------|---------|
| [tool-selector-wizard.html](../tool-selector-wizard.html) | Webshop-style tool picker |
| [interactive-diagram.html](../interactive-diagram.html) | Visual domain navigation |
| [landscape.html](../landscape.html) | CNCF landscape view |

---

## 📚 By Role

### Platform Engineer

**Getting Started:**
1. [Getting Started Guide](GETTING_STARTED.md)
2. [Docker Installation](DOCKER_INSTALLATION.md)
3. [Kind Setup](../kind/README.md)

**Planning:**
1. [Layer 0 Case Study](cases/LAYER_0_WEBSHOP_CASE.md)
2. [Layer 1 Case Study](cases/LAYER_1_WEBSHOP_CASE.md)
3. [Decision Matrix](MATRIX.md)

**Implementation:**
1. [Implementation Guide](IMPLEMENTATION_GUIDE.md)
2. [Production Ready Criteria](implementation/PRODUCTION_READY.md)
3. [Deployment Runbook](runbooks/deployment.md)

**Tool Selection:**
1. [CNI Comparison](planning/CNI_COMPARISON.md)
2. [GitOps with GitLab](planning/GITOPS_GITLAB.md)
3. [Decision Rules](DECISION_RULES.md)

### Architect

**Strategy:**
1. [Framework](architecture/FRAMEWORK.md)
2. [Vision](architecture/VISION.md)
3. [Architecture Review](architecture/ARCHITECTURE_REVIEW_SUMMARY.md)

**Decision Support:**
1. [Decision Matrix](MATRIX.md)
2. [Layer 0→1 Mapping](cases/LAYER_0_LAYER_1_MAPPING.md)
3. [Open Questions](planning/OPEN_QUESTIONS.md)

**Scenarios:**
1. [Enterprise Multi-tenant](planning/SCENARIOS.md)
2. [Webshop Case Studies](cases/)
3. [CNCF Alignment](planning/CNCF_ALIGNMENT.md)

### Developer

**Getting Started:**
1. [Getting Started Guide](GETTING_STARTED.md)
2. [Quick Reference](QUICK_REFERENCE.md) *(coming soon)*
3. [Manifests Guide](../manifests/README.md)

**Tools:**
1. [Tool Selector Wizard](../tool-selector-wizard.html)
2. [GitOps Guide](planning/GITOPS_GITLAB.md)
3. [Testing Guide](../tests/README.md)

### Manager / Decision Maker

**Overview:**
1. [Executive Summary](EXECUTIVE_SUMMARY.md)
2. [Vision](architecture/VISION.md)
3. [Scenarios](planning/SCENARIOS.md)

**Business Case:**
1. [Layer 0 Case Study](cases/LAYER_0_WEBSHOP_CASE.md) (Requirements)
2. [Challenges](planning/CHALLENGES.md) (Risks)
3. [Launch Plan](implementation/LAUNCH_PLAN.md) (Timeline)

### Contributor

**Start Here:**
1. [Contributing Guide](../CONTRIBUTING.md)
2. [Documentation Status](DOCUMENTATION_STATUS.md)
3. [Gaps Analysis](GAPS_ANALYSIS.md)

**Understand Project:**
1. [Framework](architecture/FRAMEWORK.md)
2. [Methodology](architecture/METHODOLOGY.md)
3. [Testing Methodology](implementation/TESTING_METHODOLOGY.md)

**Create Content:**
1. [Case Analysis Template](cases/CASE_ANALYSIS_TEMPLATE.md)
2. [Domain Roadmap](planning/DOMAIN_ROADMAP.md)
3. [Challenges](planning/CHALLENGES.md)

---

## 🎯 By Task

### "I need to choose a CNI"
→ [CNI Comparison](planning/CNI_COMPARISON.md)

### "I need to choose a GitOps tool"
→ [GitOps Comparison](planning/GITOPS_COMPARISON.md) - ArgoCD vs Flux vs GitLab  
→ [ArgoCD Guide](planning/ARGOCD_GUIDE.md) - Hands-on walkthrough  
→ [Flux Guide](planning/FLUX_GUIDE.md) - Bootstrap to production  
→ [GitOps with GitLab](planning/GITOPS_GITLAB.md) - GitLab Agent specific

### "I need to set up a local test cluster"
→ [Getting Started Guide](GETTING_STARTED.md)  
→ [Kind Documentation](../kind/README.md)

### "I need to understand the framework"
→ [Framework](architecture/FRAMEWORK.md)  
→ [Vision](architecture/VISION.md)

### "I need a real-world example"
→ [Webshop Case Studies](cases/)  
→ [Scenarios](planning/SCENARIOS.md)

### "I need to make a decision"
→ [Decision Matrix](MATRIX.md)  
→ [Decision Rules](DECISION_RULES.md)

### "I need to deploy something"
→ [Manifests Guide](../manifests/README.md)  
→ [Deployment Runbook](runbooks/deployment.md)

### "I need to manage secrets securely"
→ [Secrets Management Guide](planning/SECRETS_MANAGEMENT.md) - Complete ESO vs Sealed Secrets vs SOPS comparison

### "I need to test security policies"
→ [RBAC Examples](../manifests/rbac/README.md) - 8 production-ready patterns  
→ [Network Policy Examples](../manifests/networking/README.md) - Zero-trust networking  
→ [Security Tests](../tests/security/README.md) - Automated RBAC & NetworkPolicy validation

### "I need production criteria"
→ [Production Ready](implementation/PRODUCTION_READY.md)  
→ [Implementation Guide](IMPLEMENTATION_GUIDE.md)

### "I need to understand vendor lock-in"
→ [Layer 0 Case Study](cases/LAYER_0_WEBSHOP_CASE.md)  
→ [TransIP IaC Guide](TRANSIP_INFRASTRUCTURE_AS_CODE.md)

### "I need to contribute"
→ [Contributing Guide](../CONTRIBUTING.md)  
→ [Documentation Status](DOCUMENTATION_STATUS.md)

---

## 🔍 Search by Topic

### Networking
- [CNI Comparison](planning/CNI_COMPARISON.md) - Cilium, Calico, Flannel
- [Network Policy Examples](../manifests/networking/README.md) - Zero-trust patterns
- Framework: Domain 0.1 (CNI), 0.2 (Ingress)

### GitOps
- [GitOps Comparison](planning/GITOPS_COMPARISON.md) - ArgoCD vs Flux vs GitLab
- [ArgoCD Guide](planning/ARGOCD_GUIDE.md) - Complete implementation walkthrough
- [Flux Guide](planning/FLUX_GUIDE.md) - Bootstrap to production
- [GitOps with GitLab](planning/GITOPS_GITLAB.md) - GitLab Agent specific
- Framework: Domain 0.3 (GitOps)

### Security
- [Secrets Management Guide](planning/SECRETS_MANAGEMENT.md) - ESO vs Sealed Secrets vs SOPS
- [RBAC Examples](../manifests/rbac/README.md) - 8 production-ready patterns
- [Network Policy Examples](../manifests/networking/README.md) - Zero-trust networking
- [Security Tests](../tests/security/README.md) - Automated validation
- [Decision Rules](DECISION_RULES.md) - Security tool choices
- Framework: Domain 1.4 (Runtime Security)

### Observability
- Framework: Domain 1.1 (Observability)
- [Decision Matrix](MATRIX.md) - Prometheus, Grafana, Loki
- *(Detailed guide coming soon)*

### Databases
- [Layer 1 Case Study](cases/LAYER_1_WEBSHOP_CASE.md) - Managed vs StatefulSet
- Framework: Domain 1.3 (Data Services)

### CI/CD
- [GitOps with GitLab](planning/GITOPS_GITLAB.md) - CI/CD integration
- Framework: Domain 0.4 (CI/CD)
- *(GitHub Actions guide coming soon)*

### Disaster Recovery
- [Disaster Recovery Runbook](runbooks/disaster-recovery.md)
- [Production Ready](implementation/PRODUCTION_READY.md) - DR criteria

### Cost Management
- [Webshop Case Studies](cases/) - Cost analysis
- Framework: Domain 2.5 (Cost Visibility)

---

## 📖 Reading Paths

### Beginner Path (8-12 hours)
1. [Vision](architecture/VISION.md) - 20 min
2. [Framework](architecture/FRAMEWORK.md) - 1 hour
3. [Getting Started](GETTING_STARTED.md) - 2 hours
4. [Kind Setup](../kind/README.md) - 2 hours
5. [Smoke Tests](../tests/smoke/README.md) - 30 min
6. [Decision Matrix](MATRIX.md) - 1 hour
7. [CNI Comparison](planning/CNI_COMPARISON.md) - 1 hour
8. [Layer 1 Case Study](cases/LAYER_1_WEBSHOP_CASE.md) - 2 hours

### Intermediate Path (4-6 hours)
*(Assumes K8s knowledge)*
1. [Framework](architecture/FRAMEWORK.md) - 30 min
2. [Decision Matrix](MATRIX.md) - 30 min
3. [Decision Rules](DECISION_RULES.md) - 30 min
4. [CNI Comparison](planning/CNI_COMPARISON.md) - 45 min
5. [GitOps Guide](planning/GITOPS_GITLAB.md) - 45 min
6. [Layer 1 Case Study](cases/LAYER_1_WEBSHOP_CASE.md) - 1.5 hours
7. [Production Ready](implementation/PRODUCTION_READY.md) - 30 min

### Advanced Path (2-3 hours)
*(Assumes K8s + Platform experience)*
1. [Architecture Review](architecture/ARCHITECTURE_REVIEW_SUMMARY.md) - 30 min
2. [Layer 0→1 Mapping](cases/LAYER_0_LAYER_1_MAPPING.md) - 30 min
3. [Decision Rules](DECISION_RULES.md) - 20 min
4. [Open Questions](planning/OPEN_QUESTIONS.md) - 20 min
5. [Improvement Points](IMPROVEMENT_POINTS.md) - 20 min
6. [Domain Roadmap](planning/DOMAIN_ROADMAP.md) - 30 min

### Contributor Path (3-4 hours)
1. [Contributing Guide](../CONTRIBUTING.md) - 30 min
2. [Methodology](architecture/METHODOLOGY.md) - 30 min
3. [Testing Methodology](implementation/TESTING_METHODOLOGY.md) - 30 min
4. [Documentation Status](DOCUMENTATION_STATUS.md) - 20 min
5. [Gaps Analysis](GAPS_ANALYSIS.md) - 20 min
6. [Domain Roadmap](planning/DOMAIN_ROADMAP.md) - 30 min
7. [Case Analysis Template](cases/CASE_ANALYSIS_TEMPLATE.md) - 30 min

---

## 🆘 Help & Support

### Common Questions
- **"Where do I start?"** → [Getting Started Guide](GETTING_STARTED.md)
- **"What is KubeCompass?"** → [Vision](architecture/VISION.md)
- **"How do I contribute?"** → [Contributing Guide](../CONTRIBUTING.md)
- **"What tools should I use?"** → [Decision Matrix](MATRIX.md)
- **"How do I test locally?"** → [Kind Setup](../kind/README.md)

### Troubleshooting
- **Docker issues** → [Docker Installation](DOCKER_INSTALLATION.md)
- **Kind issues** → [Kind README](../kind/README.md#troubleshooting)
- **Test failures** → [Testing Guide](../tests/README.md)
- **Documentation gaps** → [Gaps Analysis](GAPS_ANALYSIS.md)

### Get Involved
- **GitHub Issues**: https://github.com/vanhoutenbos/KubeCompass/issues
- **Discussions**: https://github.com/vanhoutenbos/KubeCompass/discussions
- **Contributing**: [Contributing Guide](../CONTRIBUTING.md)

---

## 📅 Last Updated

**Date**: December 28, 2025  
**Version**: 1.0  
**Maintainer**: [@vanhoutenbos](https://github.com/vanhoutenbos)

---

**Need something not listed here?**  
Check [Gaps Analysis](GAPS_ANALYSIS.md) for planned documentation or [open an issue](https://github.com/vanhoutenbos/KubeCompass/issues).
