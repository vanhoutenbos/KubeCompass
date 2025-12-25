# Tool Reviews

This directory contains hands-on reviews of Kubernetes ecosystem tools. Each review follows the [Testing Methodology](../TESTING_METHODOLOGY.md) to ensure consistency and thoroughness.

---

## Available Reviews

### Layer 0: Foundational (CNI, GitOps, Identity, Secrets, Storage)

- **[Cilium](cilium.md)** — eBPF-based CNI with L7 policies and Hubble observability
- 🚧 **Argo CD** *(coming soon)* — GitOps with multi-tenant support and rich UI
- 🚧 **Flux** *(coming soon)* — GitOps-pure toolkit approach
- 🚧 **Vault + External Secrets Operator** *(coming soon)* — Enterprise secrets management

### Layer 1: Core Operations (Observability, Ingress, Backup)

- 🚧 **Prometheus** *(coming soon)* — Industry-standard metrics collection
- 🚧 **Loki** *(coming soon)* — Cost-effective logging with Grafana integration
- 🚧 **NGINX Ingress** *(coming soon)* — Battle-tested ingress controller
- 🚧 **Velero** *(coming soon)* — Backup and disaster recovery

### Layer 2: Enhancements (Security, Policy, Cost)

- 🚧 **Trivy** *(coming soon)* — Container image vulnerability scanning
- 🚧 **Kyverno** *(coming soon)* — Kubernetes-native policy enforcement
- 🚧 **Falco** *(coming soon)* — Runtime threat detection

---

## How to Read a Review

Each review follows this structure:

1. **Overview** — What the tool does and why it exists
2. **Installation & Setup** — How easy is it to get started?
3. **Core Functionality** — Does it work as advertised?
4. **Integration** — How does it fit with the rest of your stack?
5. **Failure Scenarios** — What happens when things break?
6. **Upgrade Path** — Can you update safely?
7. **Operational Overhead** — How much effort to maintain?
8. **Exit Strategy** — How hard is it to migrate away?
9. **Verdict** — Strengths, weaknesses, recommendations
10. **Personal Opinion** — Unfiltered take from the reviewer

---

## Review Criteria

Reviews are scored across these dimensions:

| Dimension | What It Measures |
|-----------|------------------|
| **Maturity** | Alpha, Beta, Stable, CNCF Graduated |
| **Community Activity** | Commit frequency, issue response time, contributor diversity |
| **Vendor Independence** | Single vendor, multi-vendor, foundation-hosted |
| **Migration Risk** | How hard to remove or replace? |
| **Operational Complexity** | Simple, medium, or expert-level skill required |
| **License** | Open-source (Apache, MIT) vs. proprietary |

See [METHODOLOGY.md](../METHODOLOGY.md) for full scoring rubric.

---

## Contributing Reviews

Want to contribute a tool review? Here's how:

1. **Pick a tool** that's not yet reviewed (or update an outdated one)
2. **Follow the [Testing Methodology](../TESTING_METHODOLOGY.md)** — hands-on testing required
3. **Use the review template** from TESTING_METHODOLOGY.md
4. **Submit a PR** with your review

**Quality standards**:
- Must include hands-on testing (no copy-pasted marketing materials)
- Must test failure scenarios (not just happy path)
- Must declare biases upfront (e.g., "I've used this tool for 2 years")
- Must version your review (tool version + test date)

---

## Review Lifecycle

- **New reviews**: Accepted when tool is mature enough for production consideration (1000+ GitHub stars recommended)
- **Updates**: Reviews are re-tested periodically (target: every 6-12 months)
- **Deprecation**: Reviews are marked outdated if tool is abandoned or superseded

---

**Questions?** Open an issue or start a discussion on GitHub.
