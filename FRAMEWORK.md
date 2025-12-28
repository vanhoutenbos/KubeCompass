# KubeCompass Framework

This document outlines the complete decision-making framework for building and operating production-ready Kubernetes platforms.

---

## The Golden Rule

**Installation is an implementation detail. Architecture is a design decision.**

This framework focuses on **what to decide** and **why**, not on **how to install** tools. We document architecture decisions and trade-offs, then link to official documentation for implementation details.

Why? Because installation commands change frequently, but architecture principles endure. Your time is better spent understanding trade-offs than memorizing configuration syntax.

📖 **[See full philosophy in VISION.md](VISION.md#5-the-golden-rule-architecture-vs-implementation)**

---

## Visual Overview

🎨 **Looking for visual diagrams?** See **[DIAGRAMS.md](DIAGRAMS.md)** for:
- Interactive domain architecture maps
- Decision layer visualizations
- Scale-based deployment models (single team → multi-team → enterprise)
- CNCF alignment mapping
- Decision flow navigation

📖 Continue reading below for detailed domain descriptions and decision guidance.

---

## 1. Domains & Subdomains

Every production Kubernetes cluster requires decisions across multiple operational domains. This section maps out those domains and the key choices within each.

### 1.1 Provisioning & Infrastructure
- **Cluster Creation**: Managed vs. self-hosted, cloud vs. on-prem
- **Node Management**: Instance types, auto-scaling, spot/preemptible instances
- **Infrastructure as Code**: Terraform, Pulumi, Crossplane, etc.

### 1.2 Application Deployment & Packaging
- **Manifest Management**: Helm, Kustomize, raw YAML
- **Application Delivery**: ArgoCD, Flux, manual kubectl

### 1.3 Identity, Access & Security (Pre-Run)
- **Authentication**: OIDC, LDAP, service accounts
- **Authorization**: RBAC, ABAC, OPA
- **Secrets Management**: External Secrets Operator, Sealed Secrets, Vault
- **Image Security**: Registry scanning, admission policies

### 1.4 Runtime Security
- **Threat Detection**: Falco, Tetragon
- **Network Policies**: Calico, Cilium policies
- **Workload Isolation**: Pod Security Standards, seccomp, AppArmor

### 1.5 Networking & Service Mesh
- **CNI Plugin**: Calico, Cilium, Flannel, etc.
- **Ingress**: NGINX, Traefik, HAProxy, cloud-native LBs
- **Service Mesh**: Istio, Linkerd, Cilium, or none

### 1.6 CI/CD & GitOps
- **CI/CD Pipeline**: GitHub Actions, GitLab CI, Jenkins, Tekton
- **GitOps**: Yes/No, and if yes → ArgoCD, Flux
- **Image Building**: Kaniko, Buildah, Docker-in-Docker

### 1.7 Observability
- **Metrics**: Prometheus, VictoriaMetrics, Datadog
- **Logging**: Loki, ELK, Fluentd
- **Tracing**: Jaeger, Tempo, Zipkin
- **Dashboards**: Grafana, Kibana, cloud-native tools

### 1.8 Data Management & Storage
- **Persistent Storage**: CSI drivers, cloud disks, Rook-Ceph, Longhorn
- **Backup & DR**: Velero, Kasten K10, cloud-native snapshots
- **Databases**: StatefulSets vs. managed DBs (RDS, CloudSQL, etc.)
- **Object Storage**: MinIO, Rook-Ceph S3, cloud object stores (S3, Azure Blob, GCS)

### 1.9 Container Registry & Artifacts
- **Container Registry**: Harbor, Docker Registry, cloud-native registries (ECR, ACR, GCR)
- **Artifact Management**: Vulnerability scanning, image signing, retention policies
- **Private Registry**: Self-hosted vs. managed options

### 1.10 Message Brokers & Event Streaming
- **Message Queues**: RabbitMQ, NATS, Amazon SQS
- **Event Streaming**: Apache Kafka, NATS Streaming, Pulsar
- **Service Communication**: Event-driven architectures, async processing

### 1.11 Data Stores & Caching
- **In-Memory Caching**: Redis, Memcached, Valkey
- **Session Storage**: Redis, Hazelcast
- **Rate Limiting**: Redis-based rate limiters

### 1.12 Developer Experience
- **Local Development**: Kind, K3d, Minikube, Tilt
- **Remote Debugging**: Telepresence, Skaffold
- **Self-Service**: Internal developer platforms (Backstage, etc.)

### 1.13 Governance & Policy
- **Policy Enforcement**: OPA/Gatekeeper, Kyverno
- **Compliance**: CIS benchmarks, PCI-DSS, SOC2
- **Cost Management**: Kubecost, OpenCost, cloud billing tools

---

## 2. Decision Layers & Timing

Not all decisions are equal. Some are **foundational** — hard to change later and with high architectural impact. Others are **additive** — easy to introduce or swap without disrupting the platform.

### Understanding Decision Layers

| Layer | When to Decide | Migration Cost | Examples |
|-------|----------------|----------------|----------|
| **Layer 0: Foundational** | Day 1, before workloads | **High** — requires platform rebuild or major refactoring | CNI plugin, GitOps (yes/no), RBAC model, storage backend, service mesh architecture |
| **Layer 1: Core Operations** | Within first month | **Medium** — significant effort but possible | Observability stack, secrets management, ingress controller, backup strategy |
| **Layer 2: Enhancement** | Add when needed | **Low** — plug-and-play or easy replacement | Image scanning (Trivy), policy enforcement (OPA), chaos tooling, cost monitoring |

### Why This Matters

**Example: GitOps**  
- **If chosen Day 1**: Your repo structure, deployment patterns, and team workflows are designed around it from the start.
- **If added later**: You must refactor all existing manifests, retrain teams, and migrate deployment processes — expensive and risky.

**Example: Image Scanning (Trivy)**  
- **Can be added anytime**: Plug it into existing CI/CD pipelines or admission controllers.
- **Easy to replace**: Swap Trivy for Grype or Snyk with minimal disruption.

### Decision Criteria: What Makes Something Foundational?

1. **Architectural Impact**: Does it change how the platform is structured?
2. **Team Workflow Impact**: Does it change how teams deploy or operate?
3. **Migration Complexity**: How much time/risk to change later?
4. **Blast Radius**: If it fails, what breaks?

### Applying Layers to Domains

Each domain in section 1 should be tagged with its decision layer:

| Domain | Layer | Rationale |
|--------|-------|-----------|  
| 1.1 Provisioning & Infrastructure | 0 - Foundational | IaC and node setup define the entire platform base |
| 1.3 Identity, Access & Security (Pre-Run) | 0 - Foundational | RBAC model is hard to retrofit; secrets mgmt affects all workloads |
| 1.5 Networking & Service Mesh | 0 - Foundational | CNI and mesh architecture are deeply embedded |
| 1.6 CI/CD & GitOps | 0 - Foundational | Defines deployment patterns and team workflow |
| 1.7 Observability | 1 - Core Operations | Important early, but can be replaced with moderate effort |
| 1.8 Data Management & Storage | 1 - Core Operations | CSI drivers are swappable, but backups should be planned early; object storage critical for backups and artifacts |
| 1.9 Container Registry & Artifacts | 1 - Core Operations | Essential for deployment pipeline; can be changed but affects all image pulls |
| 1.10 Message Brokers & Event Streaming | 1 - Core Operations | Important for event-driven architectures; moderate effort to migrate |
| 1.11 Data Stores & Caching | 1 - Core Operations | Critical for application performance; caching can be changed with moderate effort |
| 1.4 Runtime Security | 2 - Enhancement | Tools like Falco are additive and don't change platform architecture |
| 1.12 Developer Experience | 2 - Enhancement | Tooling can be introduced incrementally |
| 1.13 Governance & Policy | 2 - Enhancement | Can be layered on as maturity grows |

---

This layered approach prevents the common mistake of obsessing over "cool tools" (service mesh, chaos engineering) before the foundation (RBAC, backups, secrets) is solid.

---

## 3. The Decision Matrix

📖 **[See the full Decision Matrix](MATRIX.md)** — complete tool recommendations across all layers with filtering guidance.

---

## 4. Real-World Scenarios

📚 **[Browse Real-World Scenarios](SCENARIOS.md)** — including enterprise multi-tenant architecture with detailed tool selections and security posture.

---

## 5. CNCF Cloud Native Landscape Alignment

KubeCompass domains are carefully aligned with the CNCF Cloud Native Landscape to ensure comprehensive coverage of the cloud-native ecosystem. This mapping helps users familiar with CNCF navigate KubeCompass and vice versa.

### CNCF Category Mapping

| KubeCompass Domain | CNCF Primary Category | CNCF Subcategory |
|-------------------|----------------------|------------------|
| **1.1 Provisioning & Infrastructure** | Provisioning | Automation & Configuration |
| **1.2 Application Deployment & Packaging** | App Definition & Development | Application Definition & Image Build |
| **1.3 Identity, Access & Security (Pre-Run)** | Provisioning | Key Management / Identity, Security & Compliance |
| **1.4 Runtime Security** | Provisioning | Security & Compliance |
| **1.5 Networking & Service Mesh** | Runtime, Orchestration & Management | Cloud Native Network, Service Mesh |
| **1.6 CI/CD & GitOps** | App Definition & Development | Continuous Integration & Delivery |
| **1.7 Observability** | Observability & Analysis | Monitoring, Logging, Tracing |
| **1.8 Data Management & Storage** | Runtime, App Definition & Development | Cloud Native Storage, Databases |
| **1.9 Container Registry & Artifacts** | Provisioning | Container Registry |
| **1.10 Message Brokers & Event Streaming** | App Definition & Development | Streaming/Messaging |
| **1.11 Data Stores & Caching** | App Definition & Development | Databases (in-memory data stores) |
| **1.12 Developer Experience** | Platform, App Definition & Development | PaaS, Application Definition |
| **1.13 Governance & Policy** | Provisioning | Security & Compliance |

### Multi-Domain Tool Mapping

Many cloud-native tools span multiple CNCF categories. KubeCompass places tools in their **primary decision context** while acknowledging their multi-domain capabilities:

| Tool | KubeCompass Primary Domain | CNCF Categories (Multiple) |
|------|---------------------------|---------------------------|
| **Cilium** | 1.5 Networking & Service Mesh | Runtime (CNI), Orchestration (Service Mesh), Observability (Network Monitoring) |
| **Harbor** | 1.9 Container Registry | Provisioning (Registry), Security (Scanning), App Definition (Artifact Storage) |
| **Vault** | 1.3 Identity & Security | Provisioning (Key Management), Security (Encryption as Service) |
| **Prometheus** | 1.7 Observability | Observability (Monitoring), Orchestration (Service Discovery) |
| **ArgoCD** | 1.6 CI/CD & GitOps | App Definition (Delivery), Orchestration (Deployment Automation) |
| **Kafka** | 1.10 Message Brokers | App Definition (Streaming), Observability (Log Aggregation) |

### KubeCompass Value-Add: Decision Timing Layers

Unlike the CNCF Landscape (which is descriptive), KubeCompass adds a **prescriptive layer model** to help prioritize decisions:

- **Layer 0 (Foundational)**: Must decide Day 1 — hard to change later
- **Layer 1 (Core Operations)**: Decide within first month — medium migration cost
- **Layer 2 (Enhancement)**: Add when needed — low migration cost

This timing framework is **unique to KubeCompass** and complements the CNCF taxonomy.

📖 **[See full CNCF Alignment Analysis](CNCF_ALIGNMENT.md)** — comprehensive mapping, gap analysis, and recommendations.

---

This framework is a living document and will evolve based on real-world testing and community feedback.