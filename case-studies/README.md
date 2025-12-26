# Case Studies

This directory contains detailed, real-world case studies for Kubernetes platform design and implementation. Each case study is designed to be used iteratively, progressing through multiple layers of decision-making.

## Purpose

These case studies serve as:
- **Educational resources**: Learn how to approach platform design systematically
- **Templates**: Adapt for your own client or organizational scenarios
- **Auto-Copilot prompts**: Use as structured input for AI-assisted platform design
- **Decision frameworks**: Separate foundational decisions from additive ones

## Methodology: Layer-Based Progression

Each case study progresses through layers, from business context to implementation:

### **Layer 0: Business Context & Requirements**
- No tools or technologies mentioned
- Business goals, non-goals, constraints
- Current state analysis
- Assumptions, risks, and mitigation strategies
- Follow-up questions to validate assumptions

### **Layer 1: Platform Capabilities**
- Define required capabilities (HA, auto-scaling, observability, etc.)
- Still no specific tool selections
- Capability requirements and constraints
- Prioritization (foundational vs. additive)

### **Layer 2: Tool Selection**
- Map capabilities to specific tools
- Justify tool choices with rationale
- Consider alternatives
- Validate against constraints (vendor lock-in, maturity, etc.)

### **Layer 3+: Implementation Details**
- Architecture diagrams
- Configuration examples
- Deployment strategies
- Operational runbooks

## Available Case Studies

### 1. E-Commerce Platform - Legacy to Kubernetes Migration

**File**: [`layer0-ecommerce-legacy-migration.md`](layer0-ecommerce-legacy-migration.md)

**Scenario**: European e-commerce company transitioning from traditional VM-based infrastructure to Kubernetes.

**Organization Model**: SAFe Essentials (multi-team)

**Key Characteristics**:
- Monolithic MVC application
- Manual deployments with downtime
- No proactive monitoring
- Database as single point of failure
- Dutch/European cloud provider (no hyperscaler lock-in)

**Use Case**: Professional organization with operational maturity concerns, regulatory compliance (GDPR), and vendor independence requirements.

**Current Status**: Layer 0 complete (business context and requirements)

**Next Steps**: Answer follow-up questions in Section 9, then create Layer 1 document.

---

## How to Use These Case Studies

### For Learning

1. **Read Layer 0 first**: Understand the business context and constraints
2. **Answer the follow-up questions**: Refine assumptions for your scenario
3. **Progress through layers**: Build upon previous decisions systematically
4. **Compare with SCENARIOS.md**: See how tool selections align with framework

### For Your Organization

1. **Fork and adapt**: Copy a case study template
2. **Customize business context**: Replace with your organization's specifics
3. **Answer follow-up questions**: Validate assumptions in your context
4. **Iterate layer-by-layer**: Build platform design incrementally
5. **Reference KubeCompass framework**: Use [MATRIX.md](../MATRIX.md) for tool options

### As Auto-Copilot Prompts

These case studies are designed to be used with AI coding assistants (GitHub Copilot, Cursor, etc.):

**Step 1**: Copy Layer 0 document as context to your AI assistant

**Step 2**: Ask: "Based on this Layer 0 case study, help me create Layer 1 (platform capabilities). Ask clarifying questions first."

**Step 3**: Answer clarifying questions to refine requirements

**Step 4**: Review and iterate on Layer 1 output

**Step 5**: Progress to Layer 2 (tool selection) once Layer 1 is complete

**Key Principle**: Each layer builds on previous layers without breaking earlier assumptions or constraints.

---

## Contributing

Have a case study to share? We welcome contributions!

**What we're looking for**:
- Real-world scenarios (anonymized if needed)
- Clear business context and constraints
- Systematic layer-based progression
- Documented trade-offs and decision rationale

**How to contribute**:
1. Fork the repository
2. Create a new case study following the layer-based structure
3. Use the e-commerce case study as a template
4. Submit a pull request with clear description

**Quality guidelines**:
- Start with Layer 0 (business context)
- Make assumptions explicit
- Identify risks and mitigation strategies
- Include follow-up questions for validation
- Respect KubeCompass principles (production-first, vendor-neutral)

---

## Upcoming Case Studies

We're planning to add more case studies covering:

- **Startup MVP**: Cost-optimized, fast iteration, small team
- **Financial Services**: Compliance-heavy, air-gapped, strict security
- **Edge Computing**: Resource-constrained, intermittent connectivity
- **IoT Platform**: High volume, time-series data, device management
- **Healthcare**: HIPAA compliance, data isolation, audit trails
- **Media/Streaming**: High bandwidth, global CDN, video processing

**Want to see a specific scenario?** [Open an issue](https://github.com/vanhoutenbos/KubeCompass/issues) with your request!

---

## Alignment with KubeCompass

These case studies align with the KubeCompass philosophy:

✅ **Production-First**: Real operational concerns, not toy examples  
✅ **Vendor-Neutral**: Avoid lock-in, document trade-offs  
✅ **Decision Timing**: Separate foundational from additive choices  
✅ **Hands-On**: Based on real implementation experience  
✅ **Transparent**: Show reasoning, not just conclusions  

See [VISION.md](../VISION.md) for more on KubeCompass principles.

---

## License

All case studies in this directory are part of the KubeCompass project and are licensed under the MIT License.

Feel free to use, adapt, and share these case studies for educational and commercial purposes.

---

**Questions or feedback?** [Open an issue](https://github.com/vanhoutenbos/KubeCompass/issues) or [start a discussion](https://github.com/vanhoutenbos/KubeCompass/discussions).
