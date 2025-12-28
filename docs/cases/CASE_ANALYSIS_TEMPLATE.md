# Case Analysis Template: Creating Unified Decision Frameworks

**Purpose**: Guide for analyzing new Kubernetes migration cases and transforming them into structured decision frameworks  
**Audience**: Architects, consultants, and AI agents creating new case studies  
**Output**: Unified case document following [UNIFIED_CASE_STRUCTURE.md](UNIFIED_CASE_STRUCTURE.md) format  

---

## Overview

This template guides you through the process of analyzing a Kubernetes migration or platform case and transforming raw information into a **unified, AI-friendly decision framework**.

### What You'll Create
- **Structured case document** with clear requirements, constraints, and decisions
- **"Choose X unless Y" decision rules** for all major tool selections
- **Provider recommendations** mapped to specific scenarios
- **Prioritized question list** to guide stakeholders
- **Risk assessment** with mitigations
- **Machine-readable JSON** for automated decision support

---

## Step 1: Gather Raw Information

### Interview Questions to Ask

#### Organization Context
```
- Organization type? (SME, Enterprise, Startup, Government)
- Team size? (Total headcount, technical team size)
- Industry? (E-commerce, Finance, Healthcare, SaaS, etc.)
- Geography? (Datacenter location requirements, compliance zones)
- Methodology? (Agile, SAFe, Waterfall, DevOps culture)
- Current Kubernetes experience? (None, Basic, Intermediate, Advanced)
```

#### Current State
```
- What's the current infrastructure? (VMs, bare metal, existing cloud)
- What applications are being migrated? (Monolith, microservices, database)
- Current pain points? (Downtime, slow deployments, manual processes)
- Current costs? (Monthly infrastructure spend)
- Current team ownership model? (Dev vs Ops, siloed vs collaborative)
```

#### Goals & Drivers
```
- Why migrate to Kubernetes? (Business drivers, not just "it's modern")
- What problems MUST be solved? (Critical pain points)
- What's "nice to have" but not critical? (Secondary goals)
- What success looks like? (Measurable criteria)
- Timeline? (When does this need to be done?)
```

#### Constraints
```
- Budget? (Monthly operational budget, one-time migration budget)
- Compliance? (GDPR, HIPAA, PCI-DSS, SOC 2, ISO 27001)
- Vendor preferences? (Vendor independence required? Acceptable dependencies?)
- Security requirements? (Audit trails, access controls, break-glass procedures)
- Data residency? (Where must data live? Cross-border restrictions?)
- Uptime requirements? (99.9%? 99.99%? Business impact of downtime?)
```

#### Technical Details
```
- Application architecture? (Stateless? Stateful? Session management?)
- Database? (PostgreSQL, MySQL, SQL Server, MongoDB, etc.)
- Resource requirements? (Current CPU/memory per instance)
- Traffic patterns? (Concurrent users, peak hours, seasonal spikes)
- External dependencies? (APIs, payment gateways, third-party services)
- Current deployment process? (Manual, CI/CD, frequency, downtime)
```

---

## Step 2: Classify Requirements into Layers

### Layer 0: Strategic Foundation

**Extract from raw information:**

1. **Primary Goals** (3-5 critical objectives)
   - Pattern: "We need to solve [problem] to achieve [business outcome]"
   - Example: "Eliminate deployment downtime to deploy during business hours"

2. **Hard Constraints** (Non-negotiable requirements)
   - Pattern: "We MUST have [requirement] or [consequence]"
   - Example: "Data must remain in EU or violates GDPR"

3. **Non-Goals** (Explicitly excluded)
   - Pattern: "We are NOT doing [thing] because [rationale]"
   - Example: "No microservices refactoring - too complex for current team"

4. **Trade-offs** (Accepted compromises)
   - Pattern: "We accept [downside] to gain [benefit]"
   - Example: "Accept managed DB vendor dependency for operational simplicity"

5. **Risks** (High/Medium/Low with mitigations)
   - Pattern: "Risk that [problem] causes [impact], mitigate by [action]"
   - Example: "Team lacks K8s experience → hire external consultant"

**Questions to ask:**
- What's non-negotiable? (Hard constraints)
- What would break the business? (Criticality)
- What are we explicitly NOT doing? (Scope control)
- What compromises are we willing to make? (Trade-offs)
- What keeps you up at night? (Risks)

---

### Layer 1: Tactical Tool Selection

**For each domain, determine:**

1. **Default Tool Choice**
   - What's the recommended tool for this scenario?
   - Why does it fit the Layer 0 requirements?

2. **"Choose X unless Y" Rule**
   - Under what conditions would you choose differently?
   - What are the alternative tools?
   - When are alternatives better?

3. **Layer 0 Link**
   - Which Layer 0 requirement drives this choice?
   - How does this tool satisfy the constraint/goal?

**Domains to cover:**
- Infrastructure: K8s distribution, IaC, node sizing
- Networking: CNI, Ingress, service mesh (if needed)
- GitOps & CI/CD: GitOps tool, CI/CD pipeline, registry
- Observability: Metrics, logging, tracing (if needed), alerting
- Security: Secrets management, authentication, RBAC, policies
- Data: Database strategy, backup & DR, caching

**Template for each domain:**
```markdown
#### [Tool Category]
**Decision**: [Recommended tool]

**"Choose X unless Y" Rule**:
```
✅ Choose [TOOL X] UNLESS:
  ❌ [Condition 1] → [Alternative tool]
  ❌ [Condition 2] → [Alternative tool]
```

**Layer 0 Link**: [Constraint/Goal that drives this choice]

**Rationale**: [Why this tool fits the scenario]

**Alternatives Considered**:
- [Alt 1]: [Why rejected / when better]
- [Alt 2]: [Why rejected / when better]
```

---

### Layer 2: Enhancement Triggers

**For each advanced capability, define:**

1. **Trigger Condition** - When becomes relevant?
   - Pattern: "Implement when [condition 1] AND [condition 2]"
   - Example: "Service mesh when > 5 microservices AND per-service security needed"

2. **Skip Condition** - When NOT to implement?
   - Pattern: "Skip when [condition]"
   - Example: "Skip service mesh when monolith or < 3 services"

3. **Trade-offs** - What's the cost vs benefit?
   - Complexity, operational burden, features gained

4. **Timing Guidance** - Too early? Right time? Too late?
   - Example: "Too early: Day 1 (unnecessary complexity). Right time: After 5+ microservices. Too late: After security incidents"

**Layer 2 capabilities to evaluate:**
- Service Mesh (Istio, Linkerd, Cilium Mesh)
- Distributed Tracing (Tempo, Jaeger, cloud APM)
- Chaos Engineering (Chaos Mesh, Litmus)
- Policy Enforcement (OPA/Gatekeeper, Kyverno)
- Cost Visibility (Kubecost, OpenCost)
- Multi-Region Architecture
- Advanced Security (Falco, Tetragon, runtime scanning)

---

## Step 3: Build Decision Trees

### Pattern: "Choose X unless Y"

**Structure:**
```
DEFAULT: [Tool X]

UNLESS:
  - [Condition A] → [Tool Y] (reason)
  - [Condition B] → [Tool Z] (reason)
  - [Condition C] → [No tool needed] (reason)

RATIONALE: [Why Tool X is default for this scenario]

EXCEPTIONS: [When to break this rule]
```

**Example:**
```
DEFAULT: Managed Kubernetes

UNLESS:
  - Team has K8s expertise (3+ years) → Self-managed viable
  - Vendor independence > operational simplicity → Self-managed required
  - Compliance requires on-premises → Self-managed required
  - Budget allows platform team (2+ FTE) → Self-managed feasible

RATIONALE: Managed K8s reduces operational burden for teams without expertise

EXCEPTIONS: If vendor independence is absolute priority, self-managed + consultant
```

### Creating Decision Logic

1. **Identify the default** - What works for 80% of cases?
2. **List exceptions** - When would you choose differently?
3. **Explain rationale** - Why is this the default?
4. **Link to Layer 0** - Which requirement drives this?

---

## Step 4: Map Provider Recommendations

### Scenario-Based Mapping

**For each organization type, create:**

1. **Context** - What characterizes this scenario?
   - Organization size, budget, maturity, compliance needs

2. **Provider Options** - Which providers fit?
   - List 3-5 providers with pros/cons
   - Include cost, region, features, trade-offs

3. **Decision Matrix** - When to choose each?
   - IF/THEN logic based on constraints
   - UNLESS conditions for exceptions

4. **Best Match** - What's the top recommendation?
   - Explain why it fits this scenario best

**Scenarios to cover:**
- **SME/Startup**: Limited budget, small team, operational simplicity priority
- **Enterprise**: Large budget, compliance needs, multiple teams
- **Government**: Data sovereignty, transparency, risk-averse
- **Scale-Up**: Growing fast, need to scale, multi-region planning

**Template:**
```markdown
### Scenario: [Type]
**Context**: [Organization characteristics]

| Provider | Region | Cost | Pros | Cons | Best For |
|----------|--------|------|------|------|----------|
| [Name] | [Location] | €[X] | [List] | [List] | [Use case] |

**Decision Matrix**:
```
IF ([condition 1] AND [condition 2])
THEN recommend: [Provider X]
UNLESS: [exception] → [Provider Y]
```

**Recommendation**: [Top choice with rationale]
```

---

## Step 5: Prioritize Open Questions

### Categorization Framework

**Critical (Implementation Blockers)**:
- Questions that MUST be answered before starting implementation
- Pattern: "Cannot provision cluster without knowing [X]"
- Examples: Provider choice, resource sizing, database type, stateless validation

**Important (First 2 Weeks)**:
- Affects architecture but doesn't block initial setup
- Pattern: "Need to know this to design [X] properly"
- Examples: Git workflow, identity provider, monitoring metrics

**Can Defer (Layer 2+)**:
- Nice-to-have, optimization, or Layer 2 enhancements
- Pattern: "Can decide this after initial deployment"
- Examples: Hubble UI, self-hosted runners, advanced features

### Question Template

```markdown
| ID | Question | Impact | Affects | Default Assumption | Priority |
|----|----------|--------|---------|-------------------|----------|
| Q[X] | [Question text]? | [What it blocks] | [What depends on it] | [Safe default] | critical/important/defer |
```

**Example:**
```markdown
| Q1 | Which managed K8s provider? | Blocks cluster provisioning | Infrastructure, cost, compliance | TransIP (Dutch, EU) | critical |
```

---

## Step 6: Assess Risks

### Risk Assessment Template

For each identified risk:

1. **Risk Description** - What could go wrong?
2. **Impact** - Business/technical consequence
3. **Probability** - High/Medium/Low
4. **Severity** - High/Medium/Low
5. **Mitigation** - Concrete action items

**Categorize as:**
- **High Risk**: Must mitigate (high probability AND high impact)
- **Medium Risk**: Monitor and plan (medium probability OR medium impact)
- **Low Risk**: Acceptable (low probability AND low impact)

**Template:**
```markdown
#### [Risk Name]
- **Risk**: [Description]
- **Impact**: [Consequence if it happens]
- **Mitigation**:
  - [ ] [Action item 1]
  - [ ] [Action item 2]
  - [ ] [Action item 3]
```

**Common risks to check:**
- Team lacks expertise → consultant, training
- Database migration complexity → extensive testing
- Vendor lock-in by accident → portability checklist
- Security gaps → security assessment, policies
- Cost overrun → monitoring from day 1
- Workflow changes rejected → pilot first, training

---

## Step 7: Document Gaps & Conflicts

### Unanswered Assumptions

**Pattern:**
```markdown
- **Assumption**: [What we're assuming]
- **Risk if wrong**: [Impact]
- **Validation needed**: [How to verify]
```

**Example:**
```markdown
- **Assumption**: Application is stateless (sessions in Redis)
- **Risk if wrong**: Cannot do rolling updates, users lose sessions
- **Validation needed**: Test with multiple replicas, verify session persistence
```

### Conflicting Requirements

**Pattern:**
```markdown
- **Conflict**: [Requirement A] vs [Requirement B]
- **Current stance**: [How resolving]
- **Needs stakeholder decision**: [Yes/No]
```

**Example:**
```markdown
- **Conflict**: Vendor independence (self-managed) vs Operational simplicity (managed)
- **Current stance**: Prioritize operational simplicity (managed K8s), preserve portability via IaC
- **Needs stakeholder decision**: Yes - confirm managed DB acceptable
```

### Missing Information

**Pattern:**
```markdown
- **What's missing**: [Information gap]
- **Blocking**: [What can't proceed without it]
- **How to obtain**: [Action items]
```

---

## Step 8: Generate Output Documents

### Required Outputs

1. **Unified Case Document** (Markdown)
   - Follow structure from [UNIFIED_CASE_STRUCTURE.md](UNIFIED_CASE_STRUCTURE.md)
   - Sections: Executive Summary, Layer 0, Layer 1, Layer 2, Questions, Providers, Decision Rules, Gaps

2. **Machine-Readable JSON**
   - See [cases/webshop/webshop_case.json](cases/webshop/webshop_case.json) as example
   - Include: metadata, constraints, goals, decision_rules, providers, questions, risks

3. **AI Advisor Integration**
   - Identify the 5 most critical questions for interactive workflow
   - Create question flow with context-aware responses
   - See [AI_CASE_ADVISOR.md](AI_CASE_ADVISOR.md) for pattern

---

## Quality Checklist

Before finalizing the case analysis:

### Completeness
- [ ] All Layer 0 requirements have Layer 1 implementations
- [ ] Every tool choice has "Choose X unless Y" rationale
- [ ] All risks have mitigations or explicit acceptance
- [ ] Non-goals are documented with reasoning
- [ ] Open questions are categorized by urgency (Critical/Important/Defer)
- [ ] Provider options include trade-offs and scenario mapping
- [ ] Assumptions are explicit and marked for validation
- [ ] Conflicts are acknowledged with resolution path
- [ ] Success metrics are measurable
- [ ] Document is parseable by both humans and AI

### Traceability
- [ ] Every Layer 1 decision links back to Layer 0 requirement
- [ ] Every tool choice explains "why" (not just "what")
- [ ] Every non-goal has rationale (why excluded)
- [ ] Every risk has identified mitigation
- [ ] Every question shows impact if unanswered

### Actionability
- [ ] Decision rules are clear IF/THEN/UNLESS logic
- [ ] Provider recommendations have specific criteria
- [ ] Implementation phases have concrete activities
- [ ] Critical questions are identifiable
- [ ] Next steps are explicit

### AI-Friendliness
- [ ] Structured markdown with clear headers
- [ ] Tables for comparison and decision matrices
- [ ] JSON for machine-readable data
- [ ] Consistent patterns ("Choose X unless Y", "IF/THEN/UNLESS")
- [ ] Explicit relationships (Layer 0 → Layer 1 → Layer 2)

---

## Example Workflow

### Case: New SaaS Startup Migration

**Step 1: Gather Information**
```
- Organization: SaaS startup, 5 people, 1 solo DevOps engineer
- Current: Heroku (expensive, vendor lock-in concern)
- Goals: Reduce costs, increase control, prepare for scale
- Constraints: $2000/month budget, must maintain velocity
- Database: PostgreSQL (Heroku managed)
- Application: Node.js API + React frontend, stateless
```

**Step 2: Classify into Layers**

**Layer 0:**
- Primary Goal: Reduce infrastructure costs (from $3000 to $2000/month)
- Hard Constraint: Cannot sacrifice deployment velocity (solo DevOps)
- Non-Goal: Multi-region (not needed for 1000 users)
- Trade-off: Accept managed K8s (vendor dependency) for operational simplicity
- Risk: Solo DevOps overwhelmed → start simple, managed services

**Layer 1:**
- K8s: Managed (DigitalOcean or Scaleway) - solo ops can't maintain cluster
- GitOps: Argo CD or Flux - choose Flux (simpler for solo ops)
- Database: Managed PostgreSQL - operational simplicity critical
- Observability: Prometheus + Grafana - budget constraint, open-source

**Layer 2:**
- Skip: Service mesh, distributed tracing, chaos engineering (premature)
- Implement: Cost visibility from day 1 (Kubecost - track savings)

**Step 3: Build Decision Trees**
```
DEFAULT: Managed K8s at DigitalOcean
UNLESS: Budget allows platform engineer → Self-managed viable
```

**Step 4: Provider Recommendations**
```
For startup (solo DevOps, budget-conscious):
1. DigitalOcean K8s (mature, good UX) - €100-150/month
2. Scaleway K8s (cheaper) - €80-120/month
Avoid: Hyperscalers (too expensive), Self-managed (too complex for solo)
```

**Step 5: Prioritize Questions**
```
Critical:
- Q1: Current resource usage? (Node sizing)
- Q2: Database size? (Managed DB tier)
- Q3: Budget finalized? (Provider selection)

Important:
- Q4: Git workflow? (Flux config)
- Q5: Metrics to track? (Grafana dashboards)
```

**Step 6: Assess Risks**
```
High: Solo DevOps overwhelmed → Start minimal, managed services, document extensively
Medium: Costs still too high → Monitor with Kubecost, optimize over time
```

**Step 7: Document Gaps**
```
Assumption: Traffic remains < 10K users (otherwise need HA architecture)
Conflict: Cost reduction vs Vendor independence (choose cost for now)
Missing: Actual resource metrics (need to measure current Heroku usage)
```

**Step 8: Generate Outputs**
- Create `cases/saas-startup/SAAS_STARTUP_UNIFIED_CASE.md`
- Create `cases/saas-startup/saas_startup_case.json`
- Update `AI_CASE_ADVISOR.md` with startup-specific workflow

---

## Tips for Effective Analysis

### Do's ✅
- **Start with business drivers**, not tools - "Why?" before "What?"
- **Make assumptions explicit** - Don't hide unknowns
- **Document non-goals** - Critical for scope control
- **Link decisions to requirements** - Traceability matters
- **Provide alternatives** - No one-size-fits-all solution
- **Acknowledge trade-offs** - Be honest about compromises
- **Use consistent patterns** - "Choose X unless Y" for all decisions

### Don'ts ❌
- **Don't start with tool selection** - Requirements first, tools second
- **Don't hide conflicts** - Surface disagreements explicitly
- **Don't assume everything is Layer 0** - Layering prevents analysis paralysis
- **Don't skip non-goals** - Scope creep prevention is critical
- **Don't use buzzwords without context** - Explain why tools matter
- **Don't create one-size-fits-all** - Scenario-specific guidance essential

---

## Iterative Refinement

### Initial Draft (80% Complete)
1. Gather raw information (interviews, documents)
2. Create first Layer 0 classification
3. Map initial tool selections (Layer 1)
4. Identify obvious questions and risks

### Review & Refine (95% Complete)
1. Validate with stakeholders (confirm assumptions)
2. Challenge tool choices (is default really best?)
3. Test decision rules (do they handle edge cases?)
4. Fill gaps (missing info, conflicting requirements)

### Finalize (100% Complete)
1. Create machine-readable JSON
2. Test with AI advisor (can it generate recommendations?)
3. Peer review (architect feedback)
4. Mark unanswered questions for stakeholder input

---

## References

### Framework Documents
- **[UNIFIED_CASE_STRUCTURE.md](UNIFIED_CASE_STRUCTURE.md)** - Output format template
- **[FRAMEWORK.md](FRAMEWORK.md)** - Decision layers and timing
- **[AI_CASE_ADVISOR.md](AI_CASE_ADVISOR.md)** - Interactive agent workflow

### Example Cases
- **[cases/webshop/WEBSHOP_UNIFIED_CASE.md](cases/webshop/WEBSHOP_UNIFIED_CASE.md)** - Complete SME example
- **[cases/webshop/webshop_case.json](cases/webshop/webshop_case.json)** - Machine-readable format
- **[SCENARIOS.md](SCENARIOS.md)** - Enterprise and other scenarios

### Source Material Examples
- **[LAYER_0_WEBSHOP_CASE.md](LAYER_0_WEBSHOP_CASE.md)** - Raw Layer 0 analysis
- **[LAYER_1_WEBSHOP_CASE.md](LAYER_1_WEBSHOP_CASE.md)** - Raw Layer 1 with questions
- **[LAYER_2_WEBSHOP_CASE.md](LAYER_2_WEBSHOP_CASE.md)** - Raw Layer 2 triggers

---

**Document Status**: ✅ Complete - Ready for Case Analysis  
**Version**: 1.0  
**Last Update**: December 2024  
**License**: MIT - Free to use and adapt
