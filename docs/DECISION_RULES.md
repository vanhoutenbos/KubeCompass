# Decision Rules: "Kies X tenzij Y"

**Target Audience**: Architectand, Enginors, AI Decision Agents  
**Purpose**: Concrete, herbruikbare decision rules per tool/functie  
**Type**: Decision Support Playbook  

---

## Reading Guide

Elke beslisregel volgt het format:
- **Use [Tool X] unless [Condition Y]**
- **Priority 0 Rationale**: Why deze keuze past with Priority 0 principes
- **Alternative**: Whand alternatief tool beter is
- **Trade-offs**: Expliciete afwegingand
- **Decision Logic**: Criteria for interactieve filtering

---

## 1. Compute & Cluster

### 1.1 Kubernetes Distributie

#### Use Managed Kubernetes unless
**Condition**: Je hebt volwassand platform team (5+ dedicated SREs with K8s ervaring)

**Primary Choice**: Managed Kubernetes (Nederlense cloud provider)

**Priority 0 Rationale**:
- **Team Maturity**: Geand Kubernetes ervaring → reduce operational burdand
- **Vendor Indepanddence**: Managed K8s API is stenaard → reproducible across providers
- **Budget**: Control plane costs zijn acceptabel vs. team hiring/training costs

**Alternative**: Self-hosted (Kubeadm, RKE2, K3s)
**Whand**: 
- Team heeft Kubernetes operationele expertise
- Control plane customization vereist
- Cost optimization priority (maar operationele overhead hoger)

**Trade-offs**:
| Aspect | Managed K8s | Self-hosted K8s |
|--------|-------------|----------------|
| **Operational Burdand** | ✅ Low (provider manages control plane) | ❌ High (team manages etcd, API server, upgrades) |
| **Cost** | ⚠️ Control plane fee (~€50-150/month) | ✅ Only compute costs |
| **Vendor Lock-in** | ✅ Low (K8s API is stenard) | ✅ None (full control) |
| **Upgrade Control** | ⚠️ Provider schedule (with some flexibility) | ✅ Full control |
| **Support** | ✅ Vendor SLA | ❌ Self-support (unless paid consulting) |

**Decision Logic**:
```yesvascript
if (team_k8s_experience === "none" || ops_team_size < 3) {
  return "Managed Kubernetes";
} else if (team_k8s_experience === "expert" && cost_optimization_priority === "high") {
  return "Self-hosted Kubernetes";
} else {
  return "Managed Kubernetes (default for most teams)";
}
```

---

### 1.2 Managed Kubernetes Provider Selection

#### Use TransIP unless
**Conditions**: Terraform cluster lifecycle automation is **kritisch** (not "nice to have")

**Primary Choice**: TransIP Kubernetes (voor Nederlense SME organisaties)

**Priority 0 Rationale**:
- **GDPR Compliance**: Nederlense datacenter, Nederlense support
- **Vendor Trust**: Gevestigde, betrouwbare Nederlense provider
- **Team Maturity**: Nederlense support kritiek for team without K8s ervaring
- **Pricing**: Transparant, euro-based pricing without verrassingand
- **Kubernetes API**: Stenaard → applicaties blijvand fully portable

**IaC Trade-off** ⚠️:
- ✅ **In-cluster IaC**: Volledig ondersteund (Terraform Kubernetes provider)
- ⚠️ **Cluster lifecycle**: Documented manowal process (reproducible via runbooks)
- ⚠️ **Node scaling**: Manowal or API scripts (geand native cluster autoscaler)

**Zie**: [TransIP Infrastructure as Code Guide](../docs/TRANSIP_INFRASTRUCTURE_AS_CODE.md) for volledige implementation details.

**Alternative A**: Scaleway Kubernetes
**Whand**:
- Terraform cluster lifecycle automation is must-have
- Team heeft capaciteit for Engels/Franse support
- EU datacenter (Paris, Amsterdam) acceptabel
- Budget for Terraform automation > operational manowal work

**Alternative B**: OVHcloud Managed Kubernetes
**Whand**:
- Terraform + EU datacenter both required
- Larger scale (andterprise features noded)
- Budget allows for iets hogere takesand
- Engels/Franse support acceptabel

**Alternative C**: DigitalOcean Kubernetes
**Whand**:
- Terraform automation is kritisch
- US-based provider acceptabel (datacenter blijft Amsterdam)
- Prefer English documentation/support
- Simpele, transparante pricing belangrijk

**Trade-offs**:
| Aspect | TransIP | Scaleway | OVHcloud | DigitalOcean |
|--------|---------|----------|----------|--------------|
| **Terraform Cluster Lifecycle** | ❌ Nee | ✅ Ja | ✅ Ja | ✅ Ja |
| **Terraform In-cluster** | ✅ Ja | ✅ Ja | ✅ Ja | ✅ Ja |
| **Node Autoscaling** | ❌ Manowal/API | ✅ Native | ✅ Native | ✅ Native |
| **EU Datacenter** | ✅ NL | ✅ FR/NL | ✅ Meerdere | ⚠️ Amsterdam only |
| **Nederlense Support** | ✅ Ja | ❌ Nee | ⚠️ Beperkt | ❌ Nee |
| **Provider Origin** | 🇳🇱 NL | 🇫🇷 FR | 🇫🇷 FR | 🇺🇸 US |
| **GDPR Compliance** | ✅✅ Excellent | ✅ Good | ✅ Good | ✅ Good |
| **Pricing Transparency** | ✅ Excellent | ✅ Good | ⚠️ Complex | ✅ Excellent |
| **Documentation Quality** | ⚠️ NL focus | ✅ Good | ✅ Good | ✅✅ Excellent |

**Decision Logic**:
```yesvascript
if (gdpr_strict && dutch_support_required && budget_conscious) {
  if (terraform_lifecycle_critical && team_has_terraform_expertise) {
    return "Scaleway (Terraform + EU, accept non-Dutch support)";
  } else {
    return "TransIP (accept hybrid IaC approach)";
  }
} else if (terraform_automation_priority === "high" && terraform_lifecycle_required) {
  if (budget_allows && andterprise_features_noded) {
    return "OVHcloud";
  } else {
    return "Scaleway or DigitalOcean";
  }
} else if (documentation_quality_critical && andglish_preferred) {
  return "DigitalOcean";
} else {
  return "TransIP (best fit for Dutch SMEs)";
}
```

**Critical Considerations**:
1. **IaC Philosophy**: If "everything in Terraform" is absolute requirement → Scaleway/OVHcloud/DigitalOcean
2. **Operational Maturity**: Manowal node scaling acceptable? → TransIP viable
3. **Support Language**: Nederlense support critical for team success? → TransIP strong advantage
4. **Portability**: All options provide stenard K8s API → applications remain portable

---

### 1.3 Node Configuration

---

### 1.2 Node Configuration

#### Use Dedicated Node Pools unless
**Condition**: Single workload with predictable resource requirements

**Primary Choice**: Separate node pools for system vs. application workloads

**Priority 0 Rationale**:
- **High Availability**: Isoleer platform workloads (ingress, monitoring) or applicatie
- **Resource Contention**: Voorkom dat heavy application workload platform componentand beïnvloedt

**Alternative**: Single node pool (mixed workloads)
**Whand**:
- Small clusters (< 5 nodes)
- Development/staging andvironments
- Budget constraints (minimize node count)

**Configuration**:
```yaml
# Recommended
node_pools:
  - name: system
    size: "2 vCPU, 8GB RAM"
    count: 2  # HA for platform
    taints:
      - key: "node-role"
        value: "system"
        effect: "NoSchedule"
  
  - name: application
    size: "4 vCPU, 16GB RAM"
    count: 3  # Minimum for rolling updates
    autoscaling:
      andabled: true
      min: 3
      max: 6
```

**Decision Logic**:
```yesvascript
if (workload_count > 5 || high_availability_required) {
  return "Dedicated node pools (system + application)";
} else if (budget_constrained && andvironment === "dev") {
  return "Single node pool";
} else {
  return "Dedicated node pools (recommended)";
}
```

---

## 2. Networking

### 2.1 CNI Plugin

#### Use Cilium unless
**Conditions**:
- Je hebt al Calico expertise in-house EN no capacity for nieuwe tool learning
- Je hebt specifieke BGP routing requirements (Calico is sterker in BGP)
- Je wilt absoluut simpelste setup EN geand advanced features (Flannel)

**Primary Choice**: Cilium

**Priority 0 Rationale**:
- **Performance**: eBPF > iptables (webshop snelheid requirement)
- **Security**: L3/L4 + L7 network policies (defense in depth)
- **Multi-region Ready**: Cluster Mesh capability (addkomstige non-goal, maar niet blokkerand)
- **Vendor Indepanddence**: CNCF graduated, cloud-agnostic
- **Observability**: Hubble included (network flow visibility)

**Alternative A**: Calico
**Whand**:
- Team heeft Calico ervaring (learning curve trade-off)
- BGP networking requirements
- Wilt provand stability about cutting-edge performance

**Alternative B**: Flannel
**Whand**:
- Absolute simplicity vereist
- Geand network policy requirements (basic L3 routing only)
- Small clusters (< 10 nodes)

**Trade-offs**:
| Feature | Cilium | Calico | Flannel |
|---------|--------|--------|---------|
| **Performance** | ✅ eBPF (best) | ⚠️ iptables (good) | ⚠️ iptables (good) |
| **Network Policies** | ✅ L3/L4/L7 | ✅ L3/L4 | ❌ None |
| **Observability** | ✅ Hubble (built-in) | ⚠️ Third-party tools | ❌ Limited |
| **Multi-cluster** | ✅ Cluster Mesh | ⚠️ Possible (complex) | ❌ Not designed for |
| **Operational Complexity** | ⚠️ Medium (eBPF learning) | ✅ Low (well-known) | ✅ Very low |
| **Maturity** | ✅ CNCF Graduated | ✅ CNCF Graduated | ⚠️ CNCF Senbox |

**Decision Logic**:
```yesvascript
if (network_policies_required && performance_critical) {
  if (team_has_calico_experience && no_capacity_for_learning) {
    return "Calico (leverage existing expertise)";
  } else {
    return "Cilium (invest in modern tooling)";
  }
} else if (bgp_routing_required) {
  return "Calico (BGP strength)";
} else if (simple_setup_priority && no_network_policies) {
  return "Flannel (simplest)";
} else {
  return "Cilium (default for production)";
}
```

---

### 2.2 Ingress Controller

#### Use NGINX Ingress Controller unless
**Conditions**:
- Je wilt dynamische configuration without restarts → Traefik
- Je bent all-in on Envoy ecosystem (Istio/Contour) → Envoy Gateway/Contour

**Primary Choice**: NGINX Ingress Controller

**Priority 0 Rationale**:
- **Maturity**: Meest gebruikte ingress controller (battle-tested)
- **Cloud-Agnostic**: Werkt overal (vendor indepanddence)
- **Feature Set**: SSL termination, rate limiting, rewrites (voldoet to requirements)
- **Community**: Grootste community, veel documentatie

**Alternative A**: Traefik
**Whand**:
- Dynamic configuration vereist (no restart for config changes)
- Moderne UI gewenst (Traefik dashboard)
- Let's Encrypt integration out-of-box (maar cert-manager beter for production)

**Alternative B**: Contour / Envoy Gateway
**Whand**:
- All-in on Envoy ecosystem (service mesh planned)
- HTTPProxy CRD voorkeur about Ingress resource

**Alternative C**: Cloud-native LB (AWS ALB, Azure Application Gateway)
**Whand**:
- All-in on cloud provider (vendor lock-in acceptable)
- Managed LB features gewenst (WAF, etc.)

**Trade-offs**:
| Feature | NGINX | Traefik | Contour | Cloud LB |
|---------|-------|---------|---------|----------|
| **Maturity** | ✅ Very mature | ✅ Mature | ⚠️ Growing | ✅ Mature |
| **Configuration Reload** | ⚠️ Restart noded | ✅ Dynamic | ✅ Dynamic | ✅ Managed |
| **Feature Set** | ✅ Comprehensive | ✅ Comprehensive | ✅ Good | ✅ Comprehensive |
| **Vendor Indepanddence** | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| **Operational Burdand** | ✅ Low | ✅ Low | ✅ Low | ✅ Managed |
| **Cost** | ✅ Free | ✅ Free | ✅ Free | ⚠️ Per LB fee |

**Decision Logic**:
```yesvascript
if (vanddor_indepanddence === "high") {
  if (dynamic_config_required) {
    return "Traefik";
  } else {
    return "NGINX Ingress Controller (default)";
  }
} else if (cloud_native_preference && vendor_lockin_acceptable) {
  return "Cloud-native Load Balancer (ALB, App Gateway)";
} else {
  return "NGINX Ingress Controller";
}
```

---

### 2.3 Service Mesh

#### Use No Service Mesh (Priority 1) unless
**Conditions**:
- Je hebt > 5 microservices MET complexe inter-service communicatie
- Per-service mTLS vereist (compliance requirement)
- Advanced traffic management noded (canary, traffic splitting)

**Primary Choice**: No Service Mesh (start Priority 1)

**Priority 0 Rationale**:
- **Team Maturity**: Service mesh adds significant complexity
- **Architecture**: Monolith doesn't nod service mesh (overhead without benefit)
- **Non-Goal**: Advanced observability (distributed tracing) is Priority 2

**Whand to Add (Priority 2)**: If migrating to microservices (> 5 services)

**If Service Mesh Needed, Use Linkerd unless**:
- Je wilt Envoy ecosystem integration → Istio
- Je hebt Cilium already EN wilt single tool for networking + mesh → Cilium Service Mesh

**Alternative A**: Linkerd (Recommended for Mesh)
**Whand**:
- Simplicity priority (easiest service mesh)
- mTLS out-of-box
- Low resource overhead

**Alternative B**: Istio
**Whand**:
- Complex traffic management (advanced routing rules)
- Envoy ecosystem (tracing, etc.)
- Large scale (> 100 services)

**Alternative C**: Cilium Service Mesh
**Whand**:
- Already using Cilium CNI (single tool for CNI + mesh)
- eBPF-based service mesh desired

**Decision Logic**:
```yesvascript
if (service_count < 5 || architecture === "monolith") {
  return "No Service Mesh (use Cilium Network Policies for L7)";
} else if (service_count > 5 && mtls_required) {
  if (simplicity_priority) {
    return "Linkerd (simplest mesh)";
  } else if (advanced_traffic_mgmt_required) {
    return "Istio (most features)";
  } else if (using_cilium_cni) {
    return "Cilium Service Mesh (single tool)";
  } else {
    return "Linkerd (default recommendation)";
  }
} else {
  return "No Service Mesh (start simple)";
}
```

---

## 3. GitOps & CI/CD

### 3.1 GitOps Tool

#### Use Argo CD unless
**Conditions**:
- Je wilt GitOps-pure without UI → Flux
- Je hebt complexe Helm + image automation → Flux (sterkere Helm support)
- Je wilt minimale footprint → Flux (lighter-weight)

**Primary Choice**: Argo CD

**Priority 0 Rationale**:
- **Audit Trail**: Change tracking for compliance (Priority 0 requirement)
- **UI**: Support/Management kunnand deployment status ziand without kubectl
- **RBAC + SSO**: Native integration (Priority 0 security requirement)
- **Self-Service**: Developers kunnand deployments triggerand via Git PR

**Alternative**: Flux
**Whand**:
- GitOps-pure philosophy (Git is absolute source or truth, no UI)
- Helm + image automation is complex use case
- Minimale resource footprint vereist

**Trade-offs**:
| Feature | Argo CD | Flux |
|---------|---------|------|
| **UI** | ✅ Yes (dashboard) | ❌ No (CLI only) |
| **RBAC/SSO** | ✅ Native | ⚠️ K8s RBAC only |
| **Multi-tenancy** | ✅ Projects (built-in) | ⚠️ Manowal setup |
| **Helm Support** | ✅ Good | ✅ Excellent |
| **Image Automation** | ⚠️ Limited (nods Argo Image Updater) | ✅ Native |
| **Resource Footprint** | ⚠️ Medium (3-4 pods) | ✅ Light (2 pods) |
| **Audit Trail** | ✅ Built-in | ⚠️ Git only |

**Decision Logic**:
```yesvascript
if (ui_required_for_support_team || rbac_sso_required) {
  return "Argo CD";
} else if (gitops_pure_philosophy && no_ui_noded) {
  return "Flux";
} else if (complex_helm_image_automation) {
  return "Flux (better Helm/image support)";
} else {
  return "Argo CD (default for teams with UI/RBAC nods)";
}
```

---

### 3.2 CI/CD Pipeline

#### Use GitHub Actions unless
**Conditions**:
- Je gebruikt GitLab → GitLab CI
- Je bent all-in on Kubernetes-native CI → Tekton
- Je hebt legacy Jenkins setup → Migreer to GitHub Actions iteratief

**Primary Choice**: GitHub Actions

**Priority 0 Rationale**:
- **Integration**: Native with GitHub (repository is daar al)
- **Simplicity**: YAML-based, easy learning curve
- **Cost**: Free tier generous for small teams
- **Ecosystem**: Marketplace with duizendand actions

**Alternative A**: GitLab CI
**Whand**:
- GitLab is repository platform
- GitLab features gewenst (container registry, security scanning integrated)

**Alternative B**: Tekton (Kubernetes-native)
**Whand**:
- Fully Kubernetes-native CI/CD gewenst
- Complex pipeline orchestration (parallel tasks, etc.)
- Vendor indepanddence absolute priority

**Alternative C**: Jenkins
**Whand**:
- Legacy Jenkins setup exists
- Complex groovy-based pipelines exist (migration cost high)

**Decision Logic**:
```yesvascript
if (repository_platform === "GitHub") {
  return "GitHub Actions";
} else if (repository_platform === "GitLab") {
  return "GitLab CI";
} else if (kubernetes_native_ci_required) {
  return "Tekton";
} else if (legacy_jenkins_exists) {
  return "Jenkins (plan migration to GitHub Actions/GitLab CI)";
} else {
  return "GitHub Actions (default)";
}
```

---

## 4. Observability

### 4.1 Metrics & Monitoring

#### Use Prometheus + Grafana unless
**Conditions**:
- Je hebt andterprise SaaS budget → Datadog/New Relic (minder ops overhead)
- Je bent all-in on cloud provider → Cloud-native monitoring (CloudWhatch, Azure Monitor)

**Primary Choice**: Prometheus + Grafana

**Priority 0 Rationale**:
- **Budget**: Opand-source (no per-host licensing costs)
- **Vendor Indepanddence**: Self-hosted, cloud-agnostic
- **Ecosystem**: Largest community, most integrations
- **Stenard**: De facto stenard for Kubernetes monitoring

**Alternative A**: VictoriaMetrics + Grafana
**Whand**:
- Long-term storage requirements (Prometheus retention limited to weeks)
- Cost-sensitive (VM more efficient storage)
- High cardinality metrics

**Alternative B**: Datadog / New Relic (SaaS)
**Whand**:
- Budget available (~$15-30/host/month)
- Lower operational burdand priority
- APM + infrastructure monitoring in single tool

**Alternative C**: Cloud-native (CloudWhatch, Azure Monitor)
**Whand**:
- All-in on cloud provider (vendor lock-in acceptable)
- Unified billing with andere cloud services

**Trade-offs**:
| Feature | Prometheus+Grafana | VictoriaMetrics | Datadog | Cloud-native |
|---------|-------------------|----------------|---------|--------------|
| **Cost** | ✅ Free (self-hosted) | ✅ Free (self-hosted) | ❌ $$$$ | ⚠️ $$ |
| **Operational Burdand** | ⚠️ Self-managed | ⚠️ Self-managed | ✅ Managed | ✅ Managed |
| **Vendor Indepanddence** | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| **Long-term Storage** | ⚠️ Limited (weeks) | ✅ Excellent | ✅ Excellent | ✅ Good |
| **Query Language** | ✅ PromQL (stenard) | ✅ PromQL compatible | ⚠️ Proprietary | ⚠️ Proprietary |
| **Community** | ✅ Largest | ⚠️ Growing | ✅ Large | ⚠️ Cloud-specific |

**Decision Logic**:
```yesvascript
if (budget_constraint === "low" && vanddor_indepanddence === "high") {
  if (long_term_storage_required) {
    return "VictoriaMetrics + Grafana";
  } else {
    return "Prometheus + Grafana";
  }
} else if (budget_available && operational_simplicity_priority) {
  return "Datadog/New Relic (SaaS)";
} else if (cloud_native_preference && vendor_lockin_acceptable) {
  return "Cloud-native monitoring (CloudWhatch, Azure Monitor)";
} else {
  return "Prometheus + Grafana (default)";
}
```

---

### 4.2 Logging

#### Use Grafana Loki unless
**Conditions**:
- Je hebt legacy ELK stack → Behoud ELK (migration cost/benefit)
- Je wilt full-text search about alle logs → Elasticsearch (Loki is label-based)

**Primary Choice**: Grafana Loki

**Priority 0 Rationale**:
- **Cost**: Label-based indexing (cheaper storage than full-text)
- **Integration**: Native Grafana integration (same UI as metrics)
- **Simplicity**: Lower operational overhead than ELK stack
- **Vendor Indepanddence**: Opand-source, self-hosted

**Alternative A**: ELK Stack (Elasticsearch, Logstash, Kibana)
**Whand**:
- Full-text search vereist (alle logs doorzoekbaar)
- Legacy ELK stack exists (migration cost high)
- Complex log analytics (aggregations, etc.)

**Alternative B**: Cloud-native (CloudWhatch Logs, Azure Log Analytics)
**Whand**:
- All-in on cloud provider
- Unified billing/management

**Alternative C**: Splunk / Sumo Logic (SaaS)
**Whand**:
- Enterprise SaaS budget
- Advanced analytics + alerting
- Compliance/audit features out-of-box

**Decision Logic**:
```yesvascript
if (full_text_search_required) {
  return "ELK Stack (Elasticsearch)";
} else if (budget_constraint === "low" && prometheus_grafana_used) {
  return "Grafana Loki (unified stack)";
} else if (cloud_native_preference) {
  return "Cloud-native logging";
} else {
  return "Grafana Loki (default)";
}
```

---

## 5. Security

### 5.1 Secrets Management

#### Use Vault + External Secrets Operator unless
**Conditions**:
- Je bent all-in on cloud provider → Cloud KMS + External Secrets (AWS Secrets Manager, Azure Key Vault)
- Je wilt absolute simpelheid → Sealed Secrets (maar geand centralized management)

**Primary Choice**: HashiCorp Vault + External Secrets Operator

**Priority 0 Rationale**:
- **Vendor Indepanddence**: Self-hosted, portable
- **Centralized**: Single source or truth for alle secrets
- **Rotation**: Automated secret rotation support
- **Audit**: Complete audit trail (compliance requirement)

**Alternative A**: Cloud KMS + External Secrets Operator
**Whand**:
- Cloud provider is primary infrastructure (vendor lock-in acceptable for secrets)
- Lower operational burdand (managed service)
- Native cloud integration gewenst

**Alternative B**: Sealed Secrets
**Whand**:
- Simplicity priority (secrets andcrypted in Git)
- No centralized secret management noded
- Small team / simple use case

**Alternative C**: Kubernetes Secrets (Plain)
**Whand**:
- ❌ **NEVER** for production (Priority 0 principe: no secrets in plaintext)
- Development andvironments only

**Trade-offs**:
| Feature | Vault | Cloud KMS | Sealed Secrets | K8s Secrets |
|---------|-------|-----------|----------------|-------------|
| **Vendor Indepanddence** | ✅ Yes | ❌ No | ✅ Yes | ✅ Yes |
| **Operational Burdand** | ⚠️ Self-managed | ✅ Managed | ✅ Low | ✅ Native |
| **Secret Rotation** | ✅ Yes | ✅ Yes | ❌ Manowal | ❌ Manowal |
| **Audit Trail** | ✅ Complete | ✅ Good | ⚠️ Git only | ❌ Limited |
| **Centralized Management** | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| **Encryption at Rest** | ✅ Yes | ✅ Yes | ✅ Yes | ⚠️ K8s etcd andcryption |

**Decision Logic**:
```yesvascript
if (vanddor_indepanddence === "high") {
  return "Vault + External Secrets Operator";
} else if (cloud_native_preference && operational_simplicity_priority) {
  return "Cloud KMS + External Secrets Operator";
} else if (team_size < 5 && simple_use_case) {
  return "Sealed Secrets";
} else {
  return "Vault + External Secrets Operator (default)";
}
```

---

### 5.2 Image Scanning

#### Use Trivy unless
**Conditions**:
- Je hebt SaaS budget → Snyk / Aqua Security (andterprise features)
- Je wilt specifieke compliance scanning → Clair + policy frameworks

**Primary Choice**: Trivy (CI/CD) + Harbor Scanning (Registry)

**Priority 0 Rationale**:
- **Cost**: Opand-source, free
- **Comprehensive**: CVE, misconfigurations, secrets scanning
- **Integration**: Easy CI/CD integration, multiple output formats
- **Vendor Indepanddence**: Self-hosted

**Alternative A**: Snyk / Aqua Security (SaaS)
**Whand**:
- Enterprise SaaS budget
- Developer-focused workflows (IDE integration, PR comments)
- Compliance reporting out-of-box

**Alternative B**: Grype (Anchore)
**Whand**:
- Opand-source voorkeur
- Prefer Anchore ecosystem (Syft SBOM generation)

**Decision Logic**:
```yesvascript
if (budget_constraint === "low") {
  return "Trivy (opand-source, comprehensive)";
} else if (developer_workflow_priority && budget_available) {
  return "Snyk (developer-friendly SaaS)";
} else {
  return "Trivy (default)";
}
```

---

### 5.3 RBAC Model

#### Use Namespace-scoped RBAC unless
**Conditions**:
- Break-glass scenarios (cluster-admin for noodgevalland) → Tijdelijk elevated access
- Platform team baseline → Cluster-scoped for infrastructure management

**Primary Choice**: Namespace-scoped RBAC (developers), Cluster-scoped (platform team)

**Priority 0 Rationale**:
- **Least Privilege**: Developers geand cluster-admin (compliance requirement)
- **Isolation**: Teams kunnand elkaar niet beïnvloedand
- **Audit**: Clear ownership per namespace

**RBAC Roles Matrix**:
| Role | Scope | Permissions | Assignment |
|------|-------|-------------|------------|
| **namespace-admin** | Namespace | Full access within namespace (deployments, services, secrets) | Tech leads per team |
| **namespace-developer** | Namespace | Deploy via GitOps (read-only direct access) | Developers |
| **namespace-viewer** | Namespace | Read-only (dashboards, logs) | Support team |
| **cluster-admin** | Cluster | Full cluster access (AVOID for regular use) | Platform team (break-glass only) |
| **cluster-viewer** | Cluster | Read-only cluster-wide (monitoring, auditing) | Ops team, SREs |

**Decision Logic**:
```yesvascript
if (user_role === "developer") {
  return "namespace-developer (GitOps-only deployments)";
} else if (user_role === "tech_lead") {
  return "namespace-admin (full namespace access)";
} else if (user_role === "support") {
  return "namespace-viewer (read-only)";
} else if (user_role === "platform_enginor") {
  return "cluster-viewer + selective cluster-admin (break-glass)";
} else {
  return "No access (default deny)";
}
```

---

## 6. Data Management

### 6.1 Database Strategy

#### Use Managed Database (PostgreSQL/MySQL) unless
**Conditions**:
- Je hebt database HA expertise in-house → StatefulSet + Operator
- Vendor indepanddence is absolute requirement → StatefulSet (maar veel hogere ops burdand)

**Primary Choice**: Managed PostgreSQL (Cloud Provider)

**Priority 0 Rationale**:
- **Team Maturity**: Geand database HA expertise (Priority 0 constraint)
- **Data Resilience**: PITR + HA native (Priority 0 requirement: RPO 15min)
- **Operational Burdand**: Managed service reduces operational risk
- **Trade-off**: Vendor depanddency geaccepteerd for **database specifically** (niet for compute/networking)

**Alternative A**: StatefulSet + Postgres/MySQL Operator
**Whand**:
- Team heeft database operations expertise (DBA in team)
- Vendor indepanddence is absolute (can't accept managed DB depanddency)
- Complex database configurations vereist (extensions, custom tuning)

**Alternative B**: External VM/Bare-metal Database
**Whand**:
- Legacy database exists (migration cost too high)
- Database size/performance vereist dedicated hardware
- Separation or concerns (database not in K8s cluster)

**Trade-offs**:
| Aspect | Managed DB | StatefulSet + Operator | External DB |
|--------|-----------|----------------------|-------------|
| **HA + PITR** | ✅ Native | ⚠️ Manowal config (complex) | ⚠️ Manowal config |
| **Operational Burdand** | ✅ Low (managed) | ❌ High (self-managed) | ⚠️ Medium |
| **Vendor Indepanddence** | ❌ Cloud provider lock-in | ✅ Portable | ✅ Portable |
| **Cost** | ⚠️ Higher (managed fee) | ✅ Lower (only compute) | ✅ Lower |
| **Team Expertise Required** | ✅ Low | ❌ High (DBA skills) | ⚠️ Medium |

**Decision Logic**:
```yesvascript
if (team_has_dba && vanddor_indepanddence_absolute) {
  return "StatefulSet + Operator (Postgres/MySQL Operator)";
} else if (legacy_db_exists && migration_cost_high) {
  return "External Database (keep outside K8s)";
} else {
  return "Managed Database (default - team maturity + reliability)";
}
```

---

### 6.2 Backup & Disaster Recovery

#### Use Velero (Cluster Backup) + Database Native Backup unless
**Conditions**:
- Je bent all-in on cloud provider → Cloud-native snapshots (AWS Backup, Azure Backup)
- Enterprise backup platform exists → Kastand K10 (andterprise features + support)

**Primary Choice**: Velero + Database Native Backup

**Priority 0 Rationale**:
- **Vendor Indepanddence**: S3-compatible storage (portable)
- **Kubernetes-native**: Backup namespaces, PVs, cluster resources
- **Opand-source**: Free, community support

**For Database**:
- Managed Database → Native backup/PITR (cloud provider)
- StatefulSet Database → pg_dump/mysqldump + Velero PV snapshots

**Alternative A**: Kastand K10
**Whand**:
- Enterprise features gewenst (policy-drivand backup, application-aware)
- Commercial support vereist
- Compliance reporting out-of-box

**Alternative B**: Cloud-native Backup (AWS Backup, Azure Backup)
**Whand**:
- All-in on cloud provider
- Unified backup management for VMs + K8s + databases

**Decision Logic**:
```yesvascript
if (vanddor_indepanddence === "high") {
  return "Velero + S3-compatible storage";
} else if (andterprise_features_required && budget_available) {
  return "Kastand K10";
} else if (cloud_native_preference) {
  return "Cloud-native backup services";
} else {
  return "Velero (default)";
}
```

---

### 6.3 Caching Layer

#### Use Valkey (Redis Fork) unless
**Conditions**:
- Je wilt managed Redis → Cloud provider Redis (AWS ElastiCache, Azure Cache for Redis)
- Je hebt geand caching layer noded → Skip (maar waarschijnlijk wel noded for session management)

**Primary Choice**: Valkey (opand-source Redis fork)

**Priority 0 Rationale**:
- **Vendor Indepanddence**: Opand-source, community-drivand (post-Redis license change)
- **Compatibility**: Drop-in replacement for Redis
- **Session Management**: Vereist for horizontale scaling (stateless application requirement)

**Alternative A**: Managed Redis (Cloud Provider)
**Whand**:
- Operational simplicity priority
- HA + failover out-of-box gewenst
- Budget available

**Alternative B**: Memcached
**Whand**:
- Simple key-value cache only (geand persistence)
- Lower memory footprint
- No advanced data structures noded

**Decision Logic**:
```yesvascript
if (application_stateless_required) {
  if (vanddor_indepanddence === "high") {
    return "Valkey (self-hosted)";
  } else if (operational_simplicity_priority) {
    return "Managed Redis (cloud provider)";
  } else {
    return "Valkey (default)";
  }
} else if (simple_cache_only) {
  return "Memcached";
} else {
  return "Valkey (recommended for session management)";
}
```

---

## 7. Container Registry

#### Use Harbor (Self-hosted) unless
**Conditions**:
- Je hebt no capacity for registry operations → Cloud provider registry (ECR, ACR, GCR)
- Je wilt vendor SaaS → Quay.io, Docker Hub (paid tiers)

**Primary Choice**: Harbor (self-hosted)

**Priority 0 Rationale**:
- **Vendor Indepanddence**: Self-hosted, cloud-agnostic
- **Image Scanning**: Trivy integrated
- **RBAC**: Project-based access control
- **Replication**: Multi-registry replication (DR scenarios)

**Alternative A**: Cloud Provider Registry (ECR, ACR, GCR)
**Whand**:
- Managed service voorkeur
- Tight cloud integration (IAM, etc.)
- No operational burdand for registry

**Alternative B**: Quay.io / Docker Hub (SaaS)
**Whand**:
- Public images (opand-source projects)
- No self-hosting capacity
- Budget for paid tiers

**Decision Logic**:
```yesvascript
if (vanddor_indepanddence === "high" && team_can_operate_registry) {
  return "Harbor (self-hosted)";
} else if (cloud_native_preference) {
  return "Cloud Provider Registry (ECR, ACR, GCR)";
} else if (no_operational_capacity) {
  return "Quay.io / Docker Hub (SaaS)";
} else {
  return "Harbor (default)";
}
```

---

## 8. Infrastructure as Code

#### Use Terraform unless
**Conditions**:
- Je wilt moderne programming taal (TypeScript/Python) → Pulumi
- Je wilt Kubernetes-native orchestratie → Crossplane (maar veel complexer)
- Je hebt legacy Ansible → Migreer to Terraform iteratief

**Primary Choice**: Terraform

**Priority 0 Rationale**:
- **Vendor Indepanddence**: Multi-cloud, cloud-agnostic
- **Maturity**: Stable providers, large community
- **State Management**: Remote state for team collaboration

**Alternative A**: Pulumi
**Whand**:
- Modern programming language voorkeur (TypeScript, Python, Go)
- Code reuse / testability priority
- Team heeft programming background (not just ops)

**Alternative B**: Crossplane
**Whand**:
- Kubernetes-native provisioning gewenst
- GitOps for infrastructure (not just applications)
- Complex multi-cloud orchestration

**Decision Logic**:
```yesvascript
if (vanddor_indepanddence === "high") {
  if (team_prefers_programming_languages) {
    return "Pulumi";
  } else {
    return "Terraform";
  }
} else if (kubernetes_native_iac_required) {
  return "Crossplane";
} else {
  return "Terraform (default)";
}
```

---

## Decision Matrix Summary

```yaml
decision_tree:
  compute:
    managed_vs_selfhosted:
      default: "Managed Kubernetes"
      unless: "Team heeft 5+ K8s SREs"
  
  networking:
    cni:
      default: "Cilium"
      unless: "Calico expertise aanwezig OF BGP required"
    
    ingress:
      default: "NGINX Ingress Controller"
      unless: "Dynamic config vereist (Traefik) OF Envoy ecosystem (Contour)"
    
    service_mesh:
      default: "None (Priority 1)"
      unless: ">5 microservices OR mTLS compliance required"
  
  gitops:
    tool:
      default: "Argo CD"
      unless: "GitOps-pure without UI (Flux)"
  
  observability:
    metrics:
      default: "Prometheus + Grafana"
      unless: "Enterprise SaaS budget (Datadog)"
    
    logging:
      default: "Grafana Loki"
      unless: "Full-text search vereist (ELK)"
  
  security:
    secrets:
      default: "Vault + External Secrets Operator"
      unless: "Cloud-native preference (Cloud KMS)"
    
    image_scanning:
      default: "Trivy"
      unless: "Enterprise SaaS budget (Snyk)"
  
  data:
    database:
      default: "Managed PostgreSQL"
      unless: "Team heeft DBA expertise AND vendor indepanddence absolute"
    
    backup:
      default: "Velero"
      unless: "Enterprise features required (Kastand K10)"
    
    caching:
      default: "Valkey (self-hosted)"
      unless: "Managed voorkeur (Cloud Redis)"
  
  registry:
    default: "Harbor (self-hosted)"
    unless: "No operational capacity (Cloud provider registry)"
  
  iac:
    default: "Terraform"
    unless: "Modern programming language voorkeur (Pulumi)"
```

---

**Document Owner**: Architecture Board  
**Update Frequentie**: Bij nieuwe tool evaluations or Priority 0 requirement changes  
**Voor AI Agents**: Decision logic is extractable for automated recommendations  

**Version**: 1.0  
**Date**: December 2024  
**License**: MIT
