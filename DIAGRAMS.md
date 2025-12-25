# KubeCompass Visual Diagrams

This document contains visual representations of KubeCompass domains, subdomains, and decision layers to help you navigate the Kubernetes platform landscape.

---

## Table of Contents

1. [Domain Architecture Overview](#1-domain-architecture-overview)
2. [Decision Layer Visualization](#2-decision-layer-visualization)
3. [Scale-Based Deployment Models](#3-scale-based-deployment-models)
4. [CNCF Alignment Map](#4-cncf-alignment-map)
5. [Interactive Navigation Guide](#5-interactive-navigation-guide)

---

## 1. Domain Architecture Overview

### 1.1 Complete Domain Map

This diagram shows all 13 domains covered by KubeCompass and their relationships:

```mermaid
graph TB
    subgraph "Layer 0: Foundational (Day 1)"
        D1[1.1 Provisioning &<br/>Infrastructure]
        D3[1.3 Identity, Access<br/>& Security]
        D5[1.5 Networking &<br/>Service Mesh]
        D6[1.6 CI/CD & GitOps]
    end
    
    subgraph "Layer 1: Core Operations (Month 1)"
        D7[1.7 Observability]
        D8[1.8 Data Management<br/>& Storage]
        D9[1.9 Container Registry<br/>& Artifacts]
        D10[1.10 Message Brokers<br/>& Event Streaming]
        D11[1.11 Data Stores<br/>& Caching]
    end
    
    subgraph "Layer 2: Enhancement (Add as Needed)"
        D2[1.2 Application<br/>Deployment]
        D4[1.4 Runtime Security]
        D12[1.12 Developer<br/>Experience]
        D13[1.13 Governance<br/>& Policy]
    end
    
    D1 --> D3
    D1 --> D5
    D3 --> D6
    D5 --> D6
    D6 --> D2
    D8 --> D9
    D7 --> D4
    D6 --> D7
    D3 --> D13
    D2 --> D12
    
    style D1 fill:#ff6b6b
    style D3 fill:#ff6b6b
    style D5 fill:#ff6b6b
    style D6 fill:#ff6b6b
    style D7 fill:#ffd93d
    style D8 fill:#ffd93d
    style D9 fill:#ffd93d
    style D10 fill:#ffd93d
    style D11 fill:#ffd93d
    style D2 fill:#6bcf7f
    style D4 fill:#6bcf7f
    style D12 fill:#6bcf7f
    style D13 fill:#6bcf7f
```

**Color Legend:**
- 🔴 **Red (Layer 0)**: Foundational - Decide Day 1 (High migration cost)
- 🟡 **Yellow (Layer 1)**: Core Operations - Within Month 1 (Medium migration cost)
- 🟢 **Green (Layer 2)**: Enhancement - Add as needed (Low migration cost)

### 1.2 Domain Dependency Flow

This diagram shows the logical flow and dependencies between domains:

```mermaid
flowchart LR
    subgraph Foundation["🏗️ Foundation"]
        direction TB
        INFRA[Infrastructure<br/>Provisioning]
        SECURITY[Identity &<br/>Security]
        NETWORK[Networking &<br/>CNI]
    end
    
    subgraph Deployment["🚀 Deployment Pipeline"]
        direction TB
        CICD[CI/CD]
        GITOPS[GitOps]
        REGISTRY[Container<br/>Registry]
    end
    
    subgraph Runtime["⚙️ Runtime Operations"]
        direction TB
        OBSERVE[Observability]
        STORAGE[Storage &<br/>Backup]
        MESSAGING[Message<br/>Brokers]
        CACHE[Data Stores<br/>& Cache]
    end
    
    subgraph Enhancement["✨ Enhancements"]
        direction TB
        RUNSEC[Runtime<br/>Security]
        DEVX[Developer<br/>Experience]
        POLICY[Governance<br/>& Policy]
    end
    
    Foundation --> Deployment
    Foundation --> Runtime
    Deployment --> Runtime
    Runtime --> Enhancement
    Foundation --> Enhancement
    
    style Foundation fill:#ffe0e0
    style Deployment fill:#fff4cc
    style Runtime fill:#fff4cc
    style Enhancement fill:#e0ffe0
```

---

## 2. Decision Layer Visualization

### 2.1 Decision Timing Model

This diagram illustrates when to make each type of decision:

```mermaid
gantt
    title Decision Timing & Migration Cost
    dateFormat X
    axisFormat %s
    
    section Layer 0: Foundational
    CNI Plugin                    :crit, 0, 1
    GitOps Strategy              :crit, 0, 1
    RBAC Model                   :crit, 0, 1
    Service Mesh Architecture    :crit, 0, 1
    
    section Layer 1: Core Operations
    Observability Stack          :active, 1, 30
    Secrets Management           :active, 1, 30
    Ingress Controller          :active, 1, 30
    Storage Backend             :active, 1, 30
    Container Registry          :active, 1, 30
    
    section Layer 2: Enhancement
    Image Scanning              :done, 30, 90
    Policy Enforcement          :done, 30, 90
    Chaos Engineering           :done, 30, 90
    Cost Monitoring            :done, 30, 90
```

### 2.2 Migration Cost Matrix

```mermaid
graph LR
    subgraph "Migration Cost vs. Impact"
        L0["Layer 0:<br/>High Cost<br/>High Impact<br/>🔴"]
        L1["Layer 1:<br/>Medium Cost<br/>Medium Impact<br/>🟡"]
        L2["Layer 2:<br/>Low Cost<br/>Low Impact<br/>🟢"]
    end
    
    L0 --> L1
    L1 --> L2
    
    L0 -.->|"Platform Rebuild<br/>Required"| L0E["Examples:<br/>- CNI Change<br/>- GitOps Adoption<br/>- RBAC Redesign"]
    L1 -.->|"Significant<br/>Refactoring"| L1E["Examples:<br/>- Observability Switch<br/>- Storage Migration<br/>- Registry Change"]
    L2 -.->|"Plug & Play<br/>Swap"| L2E["Examples:<br/>- Add Scanning<br/>- Add Policy Tool<br/>- Add Chaos Tool"]
    
    style L0 fill:#ff6b6b
    style L1 fill:#ffd93d
    style L2 fill:#6bcf7f
    style L0E fill:#ffe0e0
    style L1E fill:#fff4cc
    style L2E fill:#e0ffe0
```

---

## 3. Scale-Based Deployment Models

### 3.1 Single Team Deployment

**Context**: Startup or small team (1-5 developers), focus on speed and simplicity

```mermaid
graph TB
    subgraph "Single Team Platform"
        subgraph "Foundation (Minimal)"
            INF1[Managed K8s<br/>GKE/EKS/AKS]
            NET1[Default CNI<br/>Flannel/Cloud Native]
            SEC1[Basic RBAC<br/>+ Secrets in K8s]
        end
        
        subgraph "Deployment (Simple)"
            CI1[GitHub Actions]
            GIT1[Optional GitOps<br/>Argo CD Lite]
            REG1[Cloud Registry<br/>ECR/ACR/GCR]
        end
        
        subgraph "Operations (Essential)"
            OBS1[Prometheus<br/>+ Grafana]
            STOR1[Cloud Storage<br/>CSI Driver]
        end
        
        subgraph "Enhancement (Add Later)"
            DEV1[Local Dev<br/>Kind/K3d]
        end
    end
    
    INF1 --> NET1
    NET1 --> CI1
    CI1 --> REG1
    REG1 --> GIT1
    GIT1 --> OBS1
    OBS1 --> STOR1
    CI1 --> DEV1
    
    style INF1 fill:#e3f2fd
    style NET1 fill:#e3f2fd
    style SEC1 fill:#e3f2fd
    style CI1 fill:#fff9c4
    style GIT1 fill:#fff9c4
    style REG1 fill:#fff9c4
    style OBS1 fill:#f1f8e9
    style STOR1 fill:#f1f8e9
    style DEV1 fill:#f3e5f5
```

**Tool Decisions for Single Team:**
- **Infrastructure**: Managed Kubernetes (GKE, EKS, AKS)
- **Networking**: Cloud-native CNI (simple)
- **CI/CD**: GitHub Actions
- **GitOps**: Optional (Argo CD if scaling expected)
- **Observability**: Prometheus + Grafana
- **Storage**: Cloud provider CSI driver

**Decision Focus**: Speed to market, minimal complexity, leverage managed services

---

### 3.2 Multi-Team Deployment

**Context**: Growing company (20-100 developers, 3-10 teams), need for collaboration and isolation

```mermaid
graph TB
    subgraph "Multi-Team Platform"
        subgraph "Foundation (Robust)"
            INF2[Multi-Zone K8s<br/>IaC: Terraform]
            NET2[Cilium<br/>Network Policies]
            SEC2[RBAC + OPA<br/>External Secrets]
        end
        
        subgraph "Deployment (Team-Scoped)"
            CI2[CI/CD Pipeline<br/>GitHub/GitLab]
            GIT2[Argo CD<br/>Multi-Tenant]
            REG2[Harbor<br/>+ Image Scanning]
        end
        
        subgraph "Operations (Complete)"
            OBS2[Prometheus Stack<br/>+ Loki + Tempo]
            STOR2[CSI + Velero<br/>Backup]
            MSG2[Message Broker<br/>Kafka/NATS]
            CACHE2[Redis<br/>Shared Cache]
        end
        
        subgraph "Enhancement (Team Tools)"
            DEV2[Developer Platform<br/>Backstage]
            POL2[Policy Enforcement<br/>Kyverno]
            COST2[Cost Tracking<br/>OpenCost]
        end
    end
    
    INF2 --> NET2
    NET2 --> SEC2
    SEC2 --> GIT2
    CI2 --> REG2
    REG2 --> GIT2
    GIT2 --> OBS2
    OBS2 --> STOR2
    GIT2 --> MSG2
    MSG2 --> CACHE2
    DEV2 --> CI2
    POL2 --> SEC2
    OBS2 --> COST2
    
    style INF2 fill:#e3f2fd
    style NET2 fill:#e3f2fd
    style SEC2 fill:#e3f2fd
    style CI2 fill:#fff9c4
    style GIT2 fill:#fff9c4
    style REG2 fill:#fff9c4
    style OBS2 fill:#f1f8e9
    style STOR2 fill:#f1f8e9
    style MSG2 fill:#f1f8e9
    style CACHE2 fill:#f1f8e9
    style DEV2 fill:#f3e5f5
    style POL2 fill:#f3e5f5
    style COST2 fill:#f3e5f5
```

**Tool Decisions for Multi-Team:**
- **Infrastructure**: Multi-zone, IaC with Terraform
- **Networking**: Cilium (L7 policies, team isolation)
- **Security**: RBAC + OPA + External Secrets Operator
- **CI/CD**: Team-specific pipelines
- **GitOps**: Argo CD with multi-tenant projects
- **Registry**: Harbor (scanning, multi-tenancy)
- **Observability**: Full stack (Prometheus, Loki, Tempo)
- **Storage**: CSI + Velero for backup
- **Developer Platform**: Backstage for self-service

**Decision Focus**: Team autonomy with governance, shared infrastructure, collaboration

---

### 3.3 Enterprise Deployment

**Context**: Large organization (100+ developers, 10+ teams), compliance, multi-region, high availability

```mermaid
graph TB
    subgraph "Enterprise Platform"
        subgraph "Foundation (Enterprise-Grade)"
            INF3[Multi-Region K8s<br/>IaC: Crossplane<br/>Multi-Cloud]
            NET3[Cilium + Istio<br/>Zero-Trust Network]
            SEC3[Vault + OPA<br/>SSO: Keycloak<br/>Audit Logging]
        end
        
        subgraph "Deployment (Full Automation)"
            CI3[Enterprise CI/CD<br/>GitLab/Jenkins]
            GIT3[Argo CD<br/>Multi-Cluster<br/>RBAC + SSO]
            REG3[Harbor HA<br/>Replication<br/>Signing]
        end
        
        subgraph "Operations (Enterprise Ops)"
            OBS3[Prometheus HA<br/>+ Victoria Metrics<br/>+ ELK Stack]
            STOR3[Rook-Ceph<br/>+ Velero DR<br/>Multi-Region]
            MSG3[Kafka HA<br/>Multi-DC]
            CACHE3[Redis Cluster<br/>HA Setup]
        end
        
        subgraph "Enhancement (Enterprise Features)"
            DEV3[Backstage Platform<br/>Service Catalog]
            POL3[OPA + Kyverno<br/>Compliance Policies]
            COST3[Kubecost<br/>Chargeback]
            RUNSEC3[Falco + Tetragon<br/>Runtime Security]
        end
        
        subgraph "Governance Layer"
            PM[Project Management<br/>Jira/Azure DevOps]
            COMP[Compliance<br/>SOC2/ISO27001]
            ORCH[Orchestration Choice<br/>Multi-K8s / Multi-Cloud]
        end
    end
    
    INF3 --> NET3
    NET3 --> SEC3
    SEC3 --> GIT3
    CI3 --> REG3
    REG3 --> GIT3
    GIT3 --> OBS3
    OBS3 --> STOR3
    GIT3 --> MSG3
    MSG3 --> CACHE3
    DEV3 --> CI3
    POL3 --> SEC3
    OBS3 --> COST3
    SEC3 --> RUNSEC3
    
    ORCH --> INF3
    PM --> CI3
    COMP --> POL3
    
    style INF3 fill:#e3f2fd
    style NET3 fill:#e3f2fd
    style SEC3 fill:#e3f2fd
    style CI3 fill:#fff9c4
    style GIT3 fill:#fff9c4
    style REG3 fill:#fff9c4
    style OBS3 fill:#f1f8e9
    style STOR3 fill:#f1f8e9
    style MSG3 fill:#f1f8e9
    style CACHE3 fill:#f1f8e9
    style DEV3 fill:#f3e5f5
    style POL3 fill:#f3e5f5
    style COST3 fill:#f3e5f5
    style RUNSEC3 fill:#f3e5f5
    style PM fill:#ffe0b2
    style COMP fill:#ffe0b2
    style ORCH fill:#ffe0b2
```

**Tool Decisions for Enterprise:**
- **Infrastructure**: Multi-region, multi-cloud with Crossplane
- **Networking**: Cilium + Istio (zero-trust, L7 security)
- **Security**: Vault, OPA, SSO with Keycloak, audit everything
- **CI/CD**: Enterprise pipelines (GitLab, Jenkins)
- **GitOps**: Argo CD multi-cluster with SSO and RBAC
- **Registry**: Harbor HA with replication and signing
- **Observability**: Prometheus HA + VictoriaMetrics + ELK
- **Storage**: Rook-Ceph for on-prem + Velero for DR
- **Message Broker**: Kafka HA multi-DC
- **Cache**: Redis Cluster HA
- **Developer Platform**: Backstage with service catalog
- **Policy**: OPA + Kyverno for compliance
- **Cost**: Kubecost with chargeback
- **Runtime Security**: Falco + Tetragon
- **Governance**: Project management integration, compliance tracking, orchestration platform decisions

**Decision Focus**: Compliance, high availability, disaster recovery, multi-region, governance

---

## 4. CNCF Alignment Map

This diagram shows how KubeCompass domains map to CNCF Cloud Native Landscape categories:

```mermaid
graph LR
    subgraph "CNCF Landscape Categories"
        CNCF1[Provisioning]
        CNCF2[Runtime]
        CNCF3[Orchestration]
        CNCF4[App Definition]
        CNCF5[Observability]
        CNCF6[Platform]
    end
    
    subgraph "KubeCompass Domains"
        KC1[1.1 Infrastructure]
        KC2[1.3 Security]
        KC3[1.5 Networking]
        KC4[1.6 CI/CD]
        KC5[1.7 Observability]
        KC6[1.8 Storage]
        KC7[1.9 Registry]
        KC8[1.12 DevX]
    end
    
    KC1 --> CNCF1
    KC2 --> CNCF1
    KC3 --> CNCF2
    KC3 --> CNCF3
    KC4 --> CNCF4
    KC5 --> CNCF5
    KC6 --> CNCF2
    KC6 --> CNCF4
    KC7 --> CNCF1
    KC8 --> CNCF6
    
    style CNCF1 fill:#4285f4
    style CNCF2 fill:#34a853
    style CNCF3 fill:#fbbc04
    style CNCF4 fill:#ea4335
    style CNCF5 fill:#9c27b0
    style CNCF6 fill:#00acc1
```

📖 **[See detailed CNCF alignment analysis](CNCF_ALIGNMENT.md)**

---

## 5. Interactive Navigation Guide

### 5.1 Domain Deep-Dive Navigation

Use this map to navigate to specific domain documentation:

```mermaid
graph TD
    START[KubeCompass Start] --> FRAMEWORK[Framework Overview]
    FRAMEWORK --> MATRIX[Decision Matrix]
    FRAMEWORK --> SCENARIOS[Real-World Scenarios]
    
    MATRIX --> L0[Layer 0: Foundational]
    MATRIX --> L1[Layer 1: Core Ops]
    MATRIX --> L2[Layer 2: Enhancement]
    
    L0 --> D1[Infrastructure]
    L0 --> D3[Security]
    L0 --> D5[Networking]
    L0 --> D6[GitOps]
    
    L1 --> D7[Observability]
    L1 --> D8[Storage]
    L1 --> D9[Registry]
    
    L2 --> D4[Runtime Security]
    L2 --> D12[DevX]
    L2 --> D13[Policy]
    
    D1 --> |Detailed Review| REV1[Tool Reviews]
    D3 --> |Detailed Review| REV1
    D5 --> |Detailed Review| REV1
    
    SCENARIOS --> S1[Single Team]
    SCENARIOS --> S2[Multi-Team]
    SCENARIOS --> S3[Enterprise]
    
    S1 --> DIAG1[Deployment Diagram]
    S2 --> DIAG2[Deployment Diagram]
    S3 --> DIAG3[Deployment Diagram]
    
    style START fill:#4CAF50
    style FRAMEWORK fill:#2196F3
    style MATRIX fill:#FF9800
    style SCENARIOS fill:#9C27B0
```

### 5.2 Decision Path Flowchart

Follow this flowchart to determine your starting point:

```mermaid
flowchart TD
    START([Start: Building K8s Platform?]) --> Q1{Team Size?}
    
    Q1 -->|1-5 people| SINGLE[Single Team<br/>Deployment Model]
    Q1 -->|5-50 people| MULTI[Multi-Team<br/>Deployment Model]
    Q1 -->|50+ people| ENTERPRISE[Enterprise<br/>Deployment Model]
    
    SINGLE --> Q2{Compliance<br/>Required?}
    MULTI --> Q3{Multi-Region?}
    ENTERPRISE --> Q4{Multi-Cloud?}
    
    Q2 -->|No| SINGLE_SIMPLE[Minimal Stack<br/>Layer 0 + 1]
    Q2 -->|Yes| SINGLE_COMPLIANT[Add Layer 2<br/>Policy Tools]
    
    Q3 -->|No| MULTI_SINGLE[Single Region<br/>Full Stack]
    Q3 -->|Yes| MULTI_DR[Multi-Region<br/>+ DR]
    
    Q4 -->|No| ENT_SINGLE[Single Cloud<br/>Full Enterprise]
    Q4 -->|Yes| ENT_MULTI[Multi-Cloud<br/>+ Crossplane]
    
    SINGLE_SIMPLE --> DOCS[📖 Read Documentation]
    SINGLE_COMPLIANT --> DOCS
    MULTI_SINGLE --> DOCS
    MULTI_DR --> DOCS
    ENT_SINGLE --> DOCS
    ENT_MULTI --> DOCS
    
    DOCS --> LAYER0[Start with Layer 0]
    LAYER0 --> LAYER1[Add Layer 1]
    LAYER1 --> LAYER2[Enhance with Layer 2]
    
    style START fill:#4CAF50
    style SINGLE fill:#81C784
    style MULTI fill:#FFD54F
    style ENTERPRISE fill:#FF8A65
    style DOCS fill:#64B5F6
```

---

## Future Interactivity Roadmap

### Planned Interactive Features (Inspired by Scaled Agile Framework)

1. **Clickable Domain Cards**
   - Click on any domain to see detailed tool recommendations
   - Hover to see quick info and decision layer

2. **Filterable Views**
   - Filter by: Team size, compliance requirements, cloud provider
   - Show/hide domains based on maturity level (stable, beta, alpha)

3. **Guided Decision Wizard**
   - Step-by-step questionnaire
   - Generates custom architecture based on answers

4. **Tool Comparison Matrix**
   - Side-by-side tool comparisons
   - Interactive scoring (you rate, we show alternatives)

5. **Architecture Generator**
   - Select your constraints (team size, compliance, budget)
   - Auto-generate recommended architecture diagram
   - Export as Terraform/Helm starter kit

6. **Community Feedback Integration**
   - Upvote/downvote tool recommendations
   - Share your experience (works in production, doesn't work)
   - Real-time updates to recommendations

### Implementation Technologies (Future)

- **Static Site Generator**: Hugo or Next.js
- **Interactive Diagrams**: D3.js, Mermaid Live Editor
- **Backend**: GitHub API for community feedback
- **Deployment**: GitHub Pages or Vercel

---

## How to Use These Diagrams

1. **Start with Scale**: Identify your organization size (Section 3)
2. **Understand Layers**: Review decision layers (Section 2)
3. **Explore Domains**: Navigate the complete domain map (Section 1)
4. **Follow the Path**: Use the decision flowchart (Section 5.2)
5. **Deep Dive**: Click through to specific domain documentation

---

**Questions or Feedback?**

- 🐛 Found an error? [Open an issue](https://github.com/vanhoutenbos/KubeCompass/issues)
- 💡 Have a suggestion? [Start a discussion](https://github.com/vanhoutenbos/KubeCompass/discussions)
- 🎨 Want to improve diagrams? [Submit a PR](https://github.com/vanhoutenbos/KubeCompass/pulls)

---

*These diagrams are designed to evolve into an interactive platform similar to the Scaled Agile Framework's Big Picture. Stay tuned for interactive features!*
