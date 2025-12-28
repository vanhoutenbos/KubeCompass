# Layer 1 Webshop Migration - Reference Architecture

This document provides a **reference architecture and design patterns** for migrating a Dutch webshop to Kubernetes, following Layer 0 requirements and Layer 1 tool selections.

## ⚠️ Important Note

**KubeCompass is a documentation-first project.** This repository contains architectural guidance, decision frameworks, and best practices—not runnable implementation code.

**Why documentation-only?**
- Focus on teaching principles and decision-making, not prescriptive solutions
- Avoid tight coupling to specific provider APIs or versions
- Allow you to adapt patterns to your specific context and requirements
- Prevent copy-paste implementations without understanding trade-offs

**You should create your own implementation based on these patterns and your specific requirements.**

## 🎯 What's Documented

This reference architecture covers all aspects needed to migrate to Kubernetes:

### ✅ Infrastructure as Code Patterns
- **Module structure**: Kubernetes cluster, networking (Cilium), storage organization
- **Environment strategy**: dev, staging, production separation patterns
- **State management**: S3-compatible backend best practices
- **Documentation templates**: Setup and usage guide patterns

### ✅ Kubernetes Manifest Patterns
- **ArgoCD**: GitOps setup patterns with App-of-Apps approach
- **Platform components**: Cilium, NGINX Ingress, cert-manager, Harbor, External Secrets patterns
- **Observability**: Prometheus, Grafana, Loki configuration patterns
- **Security**: RBAC, Network Policies, Pod Security Standards patterns
- **Applications**: Deployment patterns with Kustomize overlay structure
- **Backup**: Velero configuration patterns

### ✅ CI/CD Pipeline Patterns
- **Infrastructure automation**: Terraform workflow patterns
- **Application pipelines**: Build, scan, push, deploy patterns
- **Security integration**: Image scanning and vulnerability check patterns
- **GitOps workflows**: Automatic sync patterns

### ✅ Comprehensive Documentation
- **Implementation guide**: 20-week roadmap with clear phases
- **Deployment patterns**: Step-by-step operational patterns
- **Disaster recovery**: DR procedure patterns with RPO/RTO considerations
- **Cost estimation**: Calculation methodologies
- **Training approach**: Team onboarding structure

## 🚀 How to Use This Reference Architecture

### Step 1: Understand the Patterns

Study the architectural documentation:
- [📋 Layer 0 Foundation](LAYER_0_WEBSHOP_CASE.md) - Requirements and constraints
- [🔧 Layer 1 Tool Selection](LAYER_1_WEBSHOP_CASE.md) - Tool choices and rationale
- [🔍 Layer 0→1 Mapping](LAYER_0_LAYER_1_MAPPING.md) - Traceability matrix

### Step 2: Adapt to Your Context

Based on the patterns, create your own implementation:
- Choose your specific managed Kubernetes provider
- Adapt Terraform modules to your provider's API
- Customize Kubernetes manifests for your requirements
- Implement CI/CD pipelines in your environment

### Step 3: Follow Best Practices

Use the documented patterns as guidance:
- Security patterns for RBAC and network policies
- Observability patterns for metrics and logging
- Backup and DR patterns for resilience
- GitOps patterns for deployment automation

## 📁 Documentation Structure

The architecture is documented across multiple files:

```
.
├── LAYER_0_WEBSHOP_CASE.md          # Foundational requirements
├── LAYER_1_WEBSHOP_CASE.md          # Tool selection with managed K8s nuances
├── LAYER_2_WEBSHOP_CASE.md          # Advanced capabilities
├── LAYER_0_LAYER_1_MAPPING.md       # Traceability matrix
├── DECISION_RULES.md                # "Choose X unless Y" rules
├── OPEN_QUESTIONS.md                # Critical questions to answer
├── IMPROVEMENT_POINTS.md            # Known gaps and risks
├── IMPLEMENTATION_README.md         # This file
├── IMPLEMENTATION_SUMMARY.md        # Summary of patterns
├── IMPLEMENTATION_COMPLETE.md       # Completion checklist
└── docs/
    └── TRANSIP_INFRASTRUCTURE_AS_CODE.md  # Provider-specific guidance
```

## 🎓 Key Documentation

### Getting Started
- [📖 Layer 0 Foundation](LAYER_0_WEBSHOP_CASE.md) - **START HERE**: Understand requirements first
- [🔧 Layer 1 Tool Selection](LAYER_1_WEBSHOP_CASE.md) - Tool choices with managed Kubernetes nuances
- [🔗 Layer 0→1 Mapping](LAYER_0_LAYER_1_MAPPING.md) - How tools map to requirements

### Decision Support
- [🎯 Decision Rules](DECISION_RULES.md) - "Choose X unless Y" for all domains
- [❓ Open Questions](OPEN_QUESTIONS.md) - Critical questions to answer before implementation
- [🔍 Improvement Points](IMPROVEMENT_POINTS.md) - Known gaps and risk mitigations

### Architecture Patterns
- [📋 Layer 0 Foundation](LAYER_0_WEBSHOP_CASE.md) - Requirements and constraints
- [🔧 Layer 1 Tool Selection](LAYER_1_WEBSHOP_CASE.md) - Tool choices and rationale
- [🚀 Layer 2 Enhancements](LAYER_2_WEBSHOP_CASE.md) - Advanced capability patterns

## 🎯 Success Criteria

This reference architecture addresses all Layer 0 success criteria:

| Criterion | Target | Pattern |
|-----------|--------|---------|
| **Deployment downtime** | 0 minutes | Rolling updates + readiness probes pattern |
| **Incident detection** | < 2 minutes | Prometheus alerts + notification pattern |
| **Data recovery** | < 15 minutes | Backup automation + managed DB PITR pattern |
| **Vendor migration** | < 1 quarter | Standard K8s API + IaC pattern |
| **Developer self-service** | Via Git PR | GitOps + automated pipeline pattern |

## 🔐 Security Patterns

### Recommended Controls

- ✅ **RBAC**: Role-based access control with least privilege principle
- ✅ **Network Policies**: Default deny with explicit allows (L3/L4/L7) pattern
- ✅ **Pod Security**: Restricted profile enforcement pattern
- ✅ **Secrets Management**: External Secrets Operator pattern (no secrets in Git)
- ✅ **Image Scanning**: Trivy in CI/CD pipeline pattern
- ✅ **Audit Logging**: RBAC and break-glass action logging pattern

### Security Best Practices

- All containers run as non-root
- Read-only root filesystem where possible
- No privileged containers
- Capabilities dropped
- Network segmentation enforced
- TLS everywhere (Let's Encrypt)

## 📊 Observability Patterns

### Metrics (Prometheus)
- Infrastructure: CPU, memory, disk, network monitoring
- Application: Request rate, error rate, latency metrics
- Business: Checkout conversion, order processing, payment success metrics

### Logs (Loki)
- Centralized log aggregation pattern
- GDPR compliance (no PII logging) pattern
- Retention policy patterns

### Dashboards (Grafana)
- Webshop overview (business metrics) dashboard pattern
- Infrastructure overview dashboard pattern
- Application performance dashboard pattern
- Security events dashboard pattern

### Alert Patterns
- **Critical**: Page ops immediately (app down, high error rate)
- **Warning**: Slack notification (slow response, high resource usage)
- **Info**: Dashboard only (traffic spike, deployments)

## 💰 Cost Estimation Methodology

### Monthly Infrastructure Cost Patterns

- **Dev**: ~€175/month (3 small nodes pattern)
- **Staging**: ~€465/month (5 medium nodes pattern)
- **Production**: ~€1,780-2,580/month (6-10 large nodes, autoscaling pattern)

**Annual Total Estimate**: €29,000-38,000/year

*Note: Actual costs depend on your specific provider, node sizes, and usage patterns.*

## 🛠️ Reference Technology Stack

### Infrastructure
- **Cloud Provider**: EU-based managed Kubernetes (see Layer 1 for nuances)
- **IaC**: Terraform (provider-agnostic pattern)
- **Kubernetes**: 1.28+ (N-1 version strategy)

### Networking
- **CNI**: Cilium (eBPF-based, see alternatives in Layer 1)
- **Ingress**: NGINX Ingress Controller
- **SSL/TLS**: cert-manager + Let's Encrypt

### GitOps & CI/CD
- **GitOps**: ArgoCD (see Flux alternative in Layer 1)
- **CI/CD**: GitHub Actions (adaptable to other CI systems)
- **Registry**: Harbor (self-hosted pattern)

### Observability
- **Metrics**: Prometheus + Grafana
- **Logs**: Grafana Loki
- **Alerting**: Alertmanager

### Security
- **Secrets**: External Secrets Operator
- **Scanning**: Trivy
- **Policies**: Network Policies (OPA Gatekeeper optional)

### Storage & Backup
- **Storage**: Cloud provider CSI (see lock-in analysis in Layer 1)
- **Backup**: Velero pattern
- **Database**: Managed PostgreSQL (see trade-offs in Layer 1)

## 🚦 Documentation Status

- [x] Layer 0 foundational requirements
- [x] Layer 1 tool selection with managed K8s nuances
- [x] Layer 2 enhancement patterns
- [x] Decision rules and traceability
- [x] Open questions framework
- [x] Implementation patterns and best practices

**Status**: ✅ **Reference architecture complete**

## 🔄 Migration Roadmap Pattern

### Phase 1: Foundation (Week 1-4)
- Infrastructure provisioning patterns
- Core platform component installation
- GitOps setup patterns

### Phase 2: Platform Hardening (Week 5-8)
- Security implementation patterns
- Registry and backup setup
- Monitoring and alerting configuration

### Phase 3: Application Migration (Week 9-12)
- Application containerization approach
- Database migration patterns
- Dev deployment validation

### Phase 4: Staging & Testing (Week 13-16)
- Staging deployment patterns
- Load testing approaches
- DR testing procedures

### Phase 5: Production Cutover (Week 17-20)
- Production deployment strategy
- Blue-green cutover pattern
- Legacy infrastructure decommissioning

See architectural documentation for detailed considerations at each phase.

## ❓ Questions to Answer Before Implementation

These are critical decisions from the documentation you must answer:

1. **Which managed Kubernetes provider?** (See Layer 1 lock-in analysis)
2. **Kubernetes version strategy?** (N-1, upgrade frequency)
3. **Multi-region from day 1?** (Single region initially?)
4. **Database strategy?** (Managed vs. StatefulSet, see trade-offs)
5. **Secrets management?** (Vault vs. cloud KMS)

See [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md) for complete list and prioritization.

## 🤝 Using This Reference Architecture

This reference architecture is part of the KubeCompass framework. To implement:

1. **Study the patterns** documented across Layer 0, 1, and 2
2. **Adapt to your context** - provider, requirements, constraints
3. **Build your own implementation** based on these proven patterns
4. **Contribute back** - share learnings and improvements

## 📞 Support

For questions about the reference architecture:

- **GitHub Issues**: [vanhoutenbos/KubeCompass/issues](https://github.com/vanhoutenbos/KubeCompass/issues)
- **Discussions**: [vanhoutenbos/KubeCompass/discussions](https://github.com/vanhoutenbos/KubeCompass/discussions)

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🎉 What Makes This Reference Architecture Special?

### 1. **Documentation-First Approach**
Focus on teaching principles and decision-making rather than prescriptive copy-paste solutions.

### 2. **Vendor-Independent Patterns**
Built on open-source tools and standard Kubernetes API patterns with clear lock-in analysis.

### 3. **Decision Traceability**
Every tool choice traced back to Layer 0 requirements with "Choose X unless Y" rules.

### 4. **Real-World Trade-offs**
Honest analysis of managed vs. self-managed Kubernetes, including lock-in points.

### 5. **Comprehensive Coverage**
Security, observability, GitOps, disaster recovery—all patterns documented.

### 6. **Scenario-Based Guidance**
Different patterns for startups, enterprises, and multi-cloud scenarios.

### 7. **Tested and Validated Patterns**
Based on real-world Layer 0/Layer 1 analysis with clear success criteria.

---

**Built with ❤️ by [@vanhoutenbos](https://github.com/vanhoutenbos) and the KubeCompass community**

If you find this useful, give it a ⭐ and share it with others!
