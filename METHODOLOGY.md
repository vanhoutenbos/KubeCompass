# Methodology: Objectivity & Scoring

## Purpose
To maintain transparency and minimize bias, every tool and decision in KubeCompass is evaluated against **consistent, documented criteria**. 

When filters or preferences are not specified by the reader, they will receive **our honest, experienced opinion** — but that opinion is grounded in these objective dimensions.

---

## Scoring Rubric

Each tool is assessed across the following dimensions:

### 1. Maturity
**What it measures**: Project stability and production-readiness.

| Level | Description |
|-------|-------------|
| **Alpha** | Experimental, expect breaking changes |
| **Beta** | Usable, but not recommended for critical production |
| **Stable** | Production-ready, maintained actively |
| **CNCF Graduated** | Battle-tested, widely adopted, long-term support expected |

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

---

## How We Use These Scores

### When users apply filters:
- "Show me only CNCF Graduated tools"
- "Exclude single-vendor solutions"
- "Only Apache/MIT licensed"

→ The matrix adjusts recommendations accordingly.

### When no filters are applied:
→ You get **our personal recommendation**, but we show the scores so you can make your own informed choice.

### Example:

| Tool | Maturity | Community | Independence | Lock-in Risk | Complexity | License |
|------|----------|-----------|--------------|--------------|------------|------|
| Argo CD | CNCF Graduated | High | Foundation | Low | Medium | Apache 2.0 |
| Flux | CNCF Graduated | High | Foundation | Low | Medium | Apache 2.0 |
| Tool X | Beta | Medium | Single Vendor | High | Simple | Proprietary |

**Our take**: We prefer Argo CD for its UI and ease of use, but Flux is equally solid and more GitOps-pure. Tool X is easy to start with but risky long-term.

---

## Keeping Ourselves Honest

- **Version scoring over time**: As tools evolve, we re-score them
- **Declare biases**: If we have prior experience or strong preference, we state it upfront
- **Community input**: Corrections and alternative perspectives are welcomed via issues/PRs

---

This rubric ensures that even when we inject **opinion**, it's always backed by **transparent, measurable criteria**.