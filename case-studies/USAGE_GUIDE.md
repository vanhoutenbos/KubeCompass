# How to Use the Layer 0 Case Study with Auto-Copilot

This guide explains how to use the Layer 0 case study (`layer0-ecommerce-legacy-migration.md`) with AI coding assistants (GitHub Copilot, Cursor, Codeium, etc.) to systematically design a Kubernetes platform.

## Quick Start

### Option 1: Direct Copy-Paste (Simplest)

1. **Open** `case-studies/layer0-ecommerce-legacy-migration.md`
2. **Copy** the entire document
3. **Paste** into your AI assistant chat
4. **Ask**: "Based on this Layer 0 case study, help me create Layer 1 (platform capabilities). Ask me clarifying questions first to validate assumptions."
5. **Answer** the questions the AI asks
6. **Iterate** until you have a complete Layer 1 document
7. **Repeat** for Layer 2 (tool selection), Layer 3 (implementation), etc.

### Option 2: Structured Prompting (Recommended)

Use this prompt template with your AI assistant:

```
You are an experienced DevOps/Platform Engineer with expertise in Kubernetes migrations.

I have a Layer 0 case study documenting a client's current state and requirements.
This case study follows a systematic approach where:
- Layer 0 = Business context and requirements (no tools)
- Layer 1 = Platform capabilities (still no specific tools)
- Layer 2 = Tool selection with rationale
- Layer 3+ = Implementation details

Here is the Layer 0 document:
[PASTE THE ENTIRE LAYER 0 DOCUMENT HERE]

Your task:
1. Review the Layer 0 document carefully
2. Ask me clarifying questions about the 18 follow-up questions in Section 9
3. Based on my answers, help me create a Layer 1 document that defines:
   - Required platform capabilities
   - Capability requirements and constraints
   - Prioritization (foundational vs. additive)
   - Success criteria for each capability

Important constraints:
- Do NOT recommend specific tools yet (that's Layer 2)
- Stay vendor-neutral and cloud-agnostic
- Focus on capabilities, not implementations
- Maintain the production-first mindset from Layer 0

Start by asking me the first 3-5 most critical questions from Section 9.
```

### Option 3: Incremental Questions (Most Thorough)

If you want maximum control, work through the follow-up questions systematically:

**Step 1**: Answer Business & Organization questions (Section 9.1)
```
I'm working through a Layer 0 case study and need to answer these questions:
[Copy questions 1-5 from Section 9.1]

Here are my answers:
[Provide your answers]

Please validate these answers and suggest any missing information.
```

**Step 2**: Answer Technical Details questions (Section 9.2)
**Step 3**: Answer Strategic Decisions questions (Section 9.3)
**Step 4**: Answer Timeline & Rollout questions (Section 9.4)

**Step 5**: Request Layer 1 creation
```
Now that we have answers to all follow-up questions, please create a Layer 1 document
that defines platform capabilities without specifying tools.
```

## What to Expect from Each Layer

### Layer 0 (Current Document)
**Focus**: Business context, goals, constraints, assumptions  
**Output**: Understanding of "why" we're doing this and "what" constraints exist  
**Tools Mentioned**: None (deliberately tool-agnostic)  
**Example Content**: "We need zero-downtime deployments" (not "We'll use Kubernetes rolling updates")

### Layer 1 (Next Step)
**Focus**: Required platform capabilities  
**Output**: List of capabilities with requirements (HA, observability, GitOps, etc.)  
**Tools Mentioned**: Still none (defines "what" not "how")  
**Example Content**: "Platform must support canary deployments with automatic rollback" (not "We'll use Argo Rollouts")

### Layer 2 (After Layer 1)
**Focus**: Tool selection and justification  
**Output**: Specific tools mapped to capabilities with rationale  
**Tools Mentioned**: Yes! (finally selecting specific tools)  
**Example Content**: "For GitOps: Argo CD because it provides multi-tenant projects and SSO integration" (with alternatives considered)

### Layer 3+ (After Layer 2)
**Focus**: Implementation, configuration, deployment  
**Output**: Architecture diagrams, YAML configs, deployment guides  
**Tools Mentioned**: Implementation details for chosen tools  
**Example Content**: Actual Helm charts, CI/CD pipelines, network policies, etc.

## Tips for Success

### 1. Don't Skip Layers
Each layer builds on the previous one. Jumping straight to tool selection (Layer 2) without defining capabilities (Layer 1) leads to poor decisions.

### 2. Validate Assumptions
The Layer 0 document includes assumptions (Section 6). Make sure to validate these against your actual situation before proceeding.

### 3. Answer Follow-Up Questions Honestly
The 18 questions in Section 9 are designed to surface important details. Don't rush through them—thoughtful answers lead to better platform design.

### 4. Adapt to Your Context
This case study is a template. Your organization may have:
- Different team structure
- Different compliance requirements
- Different technology stack
- Different risk tolerance

Adapt the document to fit your reality.

### 5. Use KubeCompass Resources
Reference these documents as you progress:
- **FRAMEWORK.md**: Decision domains and layers
- **MATRIX.md**: Tool options and scoring (for Layer 2)
- **SCENARIOS.md**: Example architectures (for validation)
- **PRODUCTION_READY.md**: Production-readiness criteria

### 6. Iterate
If Layer 1 reveals gaps in Layer 0, go back and refine. If Layer 2 tool selection conflicts with Layer 1 capabilities, revisit requirements. This is normal.

## Common Pitfalls to Avoid

### ❌ Jumping to Tools Too Early
**Problem**: "We'll use Cilium, Argo CD, and Vault"  
**Fix**: First define *why* you need those capabilities, *then* select tools

### ❌ Ignoring Constraints
**Problem**: Selecting tools that violate "no vendor lock-in" constraint  
**Fix**: Always validate tool choices against Section 5 (Strategic Constraints)

### ❌ Over-Engineering
**Problem**: Designing for Google-scale when you have 1000 users  
**Fix**: Use Assumption 2 (Traffic & Scale) to right-size the solution

### ❌ Under-Engineering
**Problem**: Skipping HA because "we'll add it later"  
**Fix**: Review Goal 3 (Eliminate Database SPOF)—some capabilities are foundational

### ❌ Not Documenting Decisions
**Problem**: Making choices but not recording *why*  
**Fix**: Document rationale for every major decision (helps future you)

## Example Session Flow

Here's what a successful session with your AI assistant might look like:

**Turn 1 (You)**: [Paste Layer 0 document] "Help me create Layer 1"

**Turn 2 (AI)**: "I have some clarifying questions about your current setup..."

**Turn 3 (You)**: [Answer questions about team size, traffic, compliance, etc.]

**Turn 4 (AI)**: "Based on your answers, here are the required platform capabilities..."

**Turn 5 (You)**: "The observability capability seems over-specified. Can we simplify?"

**Turn 6 (AI)**: "Yes, here's a revised observability requirement..."

**Turn 7 (You)**: "Perfect. Now prioritize these capabilities: which are foundational?"

**Turn 8 (AI)**: "Foundational (decide Day 1): CNI, GitOps, RBAC... Additive (can wait): Chaos engineering, cost tracking..."

**Turn 9 (You)**: "Great! Save this as layer1-ecommerce-platform-capabilities.md"

**Turn 10**: Move to Layer 2 (tool selection)

## Getting Help

If you get stuck or have questions:

1. **Review the case study README**: `case-studies/README.md`
2. **Check existing scenarios**: `SCENARIOS.md` for similar architectures
3. **Open a GitHub issue**: Share your specific challenge
4. **Start a discussion**: Community may have insights

## Contributing Back

If you successfully use this case study:
- Share your Layer 1/2/3 documents (anonymized) as PRs
- Report any gaps or unclear sections
- Suggest additional follow-up questions
- Add your use case to the case studies collection

## License

This guide, like all KubeCompass content, is MIT licensed. Use freely, adapt as needed, contribute back if you find it useful.

---

**Good luck with your Kubernetes platform design!**

Remember: Take your time, validate assumptions, and focus on capabilities before tools. The systematic approach pays off in operational maturity.
