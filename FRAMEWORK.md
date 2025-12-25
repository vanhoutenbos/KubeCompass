# KubeCompass Framework

This document outlines the complete decision-making framework for building and operating production-ready Kubernetes platforms.

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

### 1.9 Developer Experience
- **Local Development**: Kind, K3d, Minikube, Tilt
- **Remote Debugging**: Telepresence, Skaffold
- **Self-Service**: Internal developer platforms (Backstage, etc.)

### 1.10 Governance & Policy
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
| 1.8 Data Management & Storage | 1 - Core Operations | CSI drivers are swappable, but backups should be planned early |
| 1.4 Runtime Security | 2 - Enhancement | Tools like Falco are additive and don't change platform architecture |
| 1.9 Developer Experience | 2 - Enhancement | Tooling can be introduced incrementally |
| 1.10 Governance & Policy | 2 - Enhancement | Can be layered on as maturity grows |

---

This layered approach prevents the common mistake of obsessing over "cool tools" (service mesh, chaos engineering) before the foundation (RBAC, backups, secrets) is solid.

---

## 3. The Decision Matrix

📖 **[See the full Decision Matrix](MATRIX.md)** — complete tool recommendations across all layers with filtering guidance.

---

## 4. Real-World Scenarios

📚 **[Browse Real-World Scenarios](SCENARIOS.md)** — including enterprise multi-tenant architecture with detailed tool selections and security posture.

---

This framework is a living document and will evolve based on real-world testing and community feedback.