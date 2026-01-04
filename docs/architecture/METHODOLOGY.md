# Methodology: Objectivity & Scoring

## Purpose
To maintain transparency and minimize bias, every tool and decision in KubeCompass is evaluated against **consistent, documented criteria**. 

When filters or preferences are not specified by the reader, they will receive **our honest, experienced opinion** — but that opinion is grounded in these objective dimensions.

---

## Scoring Rubric

Each tool is assessed across the following dimensions:

### 1. Maturity
**What it measures**: Project stability and production-readiness.

Multiple indicators contribute to maturity assessment:

**Project Status:**
| Level | Description |
|-------|-------------|
| **Alpha** | Experimental, expect breaking changes |
| **Beta** | Usable, but not recommended for critical production |
| **Stable** | Production-ready, maintained actively |
| **CNCF Graduated** | Battle-tested, widely adopted, long-term support expected |

**Additional Maturity Indicators:**
- **GitHub Stars**: Reflects adoption and community interest
  - < 500: Emerging project
  - 500-2000: Growing adoption
  - 2000-5000: Established project
  - 5000+: Widely adopted
  - **Note**: Stars alone don't determine production-readiness; consider in context with other factors
- **CNCF Status**: Indicates vendor-neutral governance and community maturity
  - **Sandbox**: Early-stage, community interest
  - **Incubating**: Growing adoption, meets CNCF standards
  - **Graduated**: Production-proven, sustainable
  - **Note**: Non-CNCF projects can be equally mature; this is an additional quality signal, not a requirement

### 2. Community Activity
**What it measures**: Health and responsiveness of the project.

- **Commit frequency**: Active development in the last 6 months?
- **Issue response time**: How quickly are issues acknowledged/resolved?
- **Contributor diversity**: Single maintainer or broad community?

| Level | Description |
|-------|-------------|
| **Low** | Stale repo, slow or no responses |
| **Medium** | Regular commits, moderate engagement |
| **High** | Very active, fast responses, diverse contributors |

### 3. Vendor Independence
**What it measures**: Risk of commercial influence or control.

- Who funds/controls the project?
- Is it a single-vendor product, or a true multi-org collaboration?

| Level | Description |
|-------|-------------|
| **Single Vendor** | Controlled by one company (risk of direction change or abandonment) |
| **Multi-Vendor** | Supported by multiple organizations |
| **Foundation-hosted** | Neutral home (e.g., CNCF, Apache) |

### 4. Migration Risk / Vendor Lock-in
**What it measures**: How hard is it to move away from this tool?

| Level | Description |
|-------|-------------|
| **Low** | Standard APIs, easy to replace, portable data |
| **Medium** | Some proprietary elements, moderate effort to migrate |
| **High** | Proprietary formats, tight integration, expensive to leave |

### 5. Operational Complexity
**What it measures**: Effort required to run and maintain.

| Level | Description |
|-------|-------------|
| **Simple** | Minimal config, easy to understand and operate |
| **Medium** | Requires some expertise, moderate configuration |
| **Expert** | Complex setup, deep knowledge required, high maintenance |

### 6. License
**What it measures**: Legal and philosophical considerations.

Common licenses and implications:
- **Apache 2.0 / MIT**: Permissive, business-friendly
- **GPL / AGPL**: Copyleft, may affect derivative works
- **Proprietary / Source-available**: Usage restrictions, potential costs

### 7. Installation Methods
**What it measures**: Ease of deployment and operational maturity.

| Method | Description | Benefits |
|--------|-------------|----------|
| **Helm Chart** | Kubernetes package manager | Templating, versioning, easy upgrades |
| **Operator** | Kubernetes-native automation | Self-healing, day-2 operations, lifecycle management |
| **Raw Manifests** | Direct YAML application | Simple, transparent, full control |
| **CLI Tool** | Command-line installer | Quick setup, guided installation |

**Evaluation criteria**:
- **Multiple options available**: More flexibility for different use cases
- **Operator support**: Indicates mature automation and operational best practices
- **Official vs. community**: Vendor-maintained preferred for reliability

### 8. Container Image Security
**What it measures**: Security posture of distributed container images.

| Indicator | Description | Importance |
|-----------|-------------|------------|
| **Hardened Images** | Minimal attack surface (distroless, scratch-based) | Reduces vulnerability exposure |
| **Image Signing** | Cryptographically signed images (Sigstore, Notary) | Verifies authenticity and integrity |
| **Regular Scanning** | Automated CVE scanning by maintainers | Ensures timely security patches |
| **Non-root by Default** | Runs as non-privileged user | Defense-in-depth security |
| **SBOM Available** | Software Bill of Materials provided | Supply chain transparency |

**Evaluation criteria**:
- **Best practice**: Hardened images + signing + regular updates
- **Acceptable**: Standard images with regular security updates
- **Concern**: Outdated images, runs as root, no security updates

---

## How We Use These Scores

### When users apply filters:
- "Show me only CNCF Graduated tools"
- "Exclude single-vendor solutions"
- "Only Apache/MIT licensed"
- "Show tools with Operator support"
- "Only hardened container images"

→ The matrix adjusts recommendations accordingly.

### When no filters are applied:
→ You get **our personal recommendation**, but we show the scores so you can make your own informed choice.

### Example:

| Tool | Maturity | Stars | Community | Independence | Lock-in Risk | Complexity | Install Methods | License |
|------|----------|-------|-----------|--------------|--------------|------------|----------------|------|
| Argo CD | CNCF Graduated | 20,000+ | High | Foundation | Low | Medium | Helm, Operator | Apache 2.0 |
| Flux | CNCF Graduated | 7,500+ | High | Foundation | Low | Medium | CLI, Helm | Apache 2.0 |
| Tool X | Beta | 800 | Medium | Single Vendor | High | Simple | Helm | Proprietary |

**Our take**: We prefer Argo CD for its UI and ease of use, but Flux is equally solid and more GitOps-pure. Tool X is easy to start with but risky long-term.

---

## Keeping Ourselves Honest

- **Version scoring over time**: As tools evolve, we re-score them
- **Declare biases**: If we have prior experience or strong preference, we state it upfront
- **Community input**: Corrections and alternative perspectives are welcomed via issues/PRs

---

## External References & Sources

KubeCompass is built on a foundation of hands-on testing, but we also learn from and reference the broader community's knowledge.

### What We Reference

We actively cite and link to:
- **Official documentation**: Primary source for tool capabilities and installation
- **Community awesome lists**: [awesome-k8s-resources](https://github.com/tomhuang12/awesome-k8s-resources) for tool discovery and learning resources
- **Blog posts**: Real-world experiences and lessons learned from practitioners
- **Conference talks**: Architecture patterns and case studies (e.g., KubeCon, Cloud Native Rejekts)
- **YouTube videos**: Technical deep-dives and tutorials
- **GitHub discussions**: Community debates and issue threads
- **Comparative analyses**: Existing tool comparisons and benchmarks

### Quality Criteria for External Sources

We evaluate external references based on:
- **Recency**: Is the information current? (Tools evolve quickly)
- **Hands-on nature**: Does it show real usage, not just theory?
- **Technical depth**: Does it explain *why*, not just *what*?
- **Author credibility**: Is the author a practitioner with real experience?
- **Bias transparency**: Does the author disclose affiliations/conflicts?

### How We Cite Sources

**Format**:
- **Inline links**: Embedded in text where relevant
- **Reference sections**: Collected at end of documents for further reading
- **Attribution**: Clear author/organization credit with publish date
- **Archive links**: For critical references, we may archive to prevent link rot

**Example**:
```markdown
> "Cilium provides eBPF-based networking with built-in observability"  
> — [Cilium Documentation](https://docs.cilium.io), 2024

**Further Reading**:
- [Life of a Packet in Cilium](https://cilium.io/blog/...) — Blog post explaining Cilium's packet flow
- [KubeCon Talk: Scaling Cilium to 10,000 Nodes](https://youtube.com/...) — Production experience from Datadog
```

### What We Don't Do

- ❌ **Uncited opinions**: Every claim should be testable or referenced
- ❌ **Vendor whitepapers without disclosure**: Marketing materials clearly labeled
- ❌ **Outdated content without warning**: If referencing old content, we note it
- ❌ **Anonymous sources**: We attribute knowledge to identifiable authors/orgs

### Contributing External References

When contributing to KubeCompass, please:
1. **Include source links**: Cite where you learned something
2. **Check publication dates**: Prefer recent content (< 2 years for tools)
3. **Verify hands-on testing**: Ensure referenced content is practical, not theoretical
4. **Disclose affiliations**: If you're citing your own work or your employer's

### Relationship with Related Initiatives

KubeCompass learns from and complements other initiatives. See **[RELATED_INITIATIVES.md](RELATED_INITIATIVES.md)** for our position relative to:
- CNCF Landscape
- OpenSSF Scorecard
- SLSA Framework
- ThoughtWorks Technology Radar
- And more

---

This rubric ensures that even when we inject **opinion**, it's always backed by **transparent, measurable criteria**.