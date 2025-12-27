# Decision Rules: "Kies X tenzij Y"

**Doelgroep**: Architecten, Engineers, AI Decision Agents  
**Doel**: Concrete, herbruikbare beslisregels per tool/functie  
**Type**: Decision Support Playbook  

---

## Leeswijzer

Elke beslisregel volgt het format:
- **Use [Tool X] unless [Condition Y]**
- **Layer 0 Rationale**: Waarom deze keuze past bij Layer 0 principes
- **Alternative**: Wanneer alternatief tool beter is
- **Trade-offs**: Expliciete afwegingen
- **Decision Logic**: Criteria voor interactieve filtering

---

## 1. Compute & Cluster

### 1.1 Kubernetes Distributie

#### Use Managed Kubernetes unless
**Condition**: Je hebt volwassen platform team (5+ dedicated SREs met K8s ervaring)

**Primary Choice**: Managed Kubernetes (Nederlandse cloud provider)

**Layer 0 Rationale**:
- **Team Maturity**: Geen Kubernetes ervaring → reduce operational burden
- **Vendor Independence**: Managed K8s API is standaard → reproducible across providers
- **Budget**: Control plane costs zijn acceptabel vs. team hiring/training costs

**Alternative**: Self-hosted (Kubeadm, RKE2, K3s)
**When**: 
- Team heeft Kubernetes operationele expertise
- Control plane customization vereist
- Cost optimization priority (maar operationele overhead hoger)

**Trade-offs**:
| Aspect | Managed K8s | Self-hosted K8s |
|--------|-------------|----------------|
| **Operational Burden** | ✅ Low (provider manages control plane) | ❌ High (team manages etcd, API server, upgrades) |
| **Cost** | ⚠️ Control plane fee (~€50-150/month) | ✅ Only compute costs |
| **Vendor Lock-in** | ✅ Low (K8s API is standard) | ✅ None (full control) |
| **Upgrade Control** | ⚠️ Provider schedule (with some flexibility) | ✅ Full control |
| **Support** | ✅ Vendor SLA | ❌ Self-support (unless paid consulting) |

**Decision Logic**:
```javascript
if (team_k8s_experience === "none" || ops_team_size < 3) {
  return "Managed Kubernetes";
} else if (team_k8s_experience === "expert" && cost_optimization_priority === "high") {
  return "Self-hosted Kubernetes";
} else {
  return "Managed Kubernetes (default for most teams)";
}
```

---

### 1.2 Node Configuration

#### Use Dedicated Node Pools unless
**Condition**: Single workload with predictable resource requirements

**Primary Choice**: Separate node pools voor system vs. application workloads

**Layer 0 Rationale**:
- **High Availability**: Isoleer platform workloads (ingress, monitoring) van applicatie
- **Resource Contention**: Voorkom dat heavy application workload platform componenten beïnvloedt

**Alternative**: Single node pool (mixed workloads)
**When**:
- Small clusters (< 5 nodes)
- Development/staging environments
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
      enabled: true
      min: 3
      max: 6
```

**Decision Logic**:
```javascript
if (workload_count > 5 || high_availability_required) {
  return "Dedicated node pools (system + application)";
} else if (budget_constrained && environment === "dev") {
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
- Je hebt al Calico expertise in-house EN geen capaciteit voor nieuwe tool learning
- Je hebt specifieke BGP routing requirements (Calico is sterker in BGP)
- Je wilt absoluut simpelste setup EN geen advanced features (Flannel)

**Primary Choice**: Cilium

**Layer 0 Rationale**:
- **Performance**: eBPF > iptables (webshop snelheid requirement)
- **Security**: L3/L4 + L7 network policies (defense in depth)
- **Multi-region Ready**: Cluster Mesh capability (toekomstige non-goal, maar niet blokkeren)
- **Vendor Independence**: CNCF graduated, cloud-agnostic
- **Observability**: Hubble included (network flow visibility)

**Alternative A**: Calico
**When**:
- Team heeft Calico ervaring (learning curve trade-off)
- BGP networking requirements
- Wilt proven stability over cutting-edge performance

**Alternative B**: Flannel
**When**:
- Absolute simplicity vereist
- Geen network policy requirements (basic L3 routing only)
- Small clusters (< 10 nodes)

**Trade-offs**:
| Feature | Cilium | Calico | Flannel |
|---------|--------|--------|---------|
| **Performance** | ✅ eBPF (best) | ⚠️ iptables (good) | ⚠️ iptables (good) |
| **Network Policies** | ✅ L3/L4/L7 | ✅ L3/L4 | ❌ None |
| **Observability** | ✅ Hubble (built-in) | ⚠️ Third-party tools | ❌ Limited |
| **Multi-cluster** | ✅ Cluster Mesh | ⚠️ Possible (complex) | ❌ Not designed for |
| **Operational Complexity** | ⚠️ Medium (eBPF learning) | ✅ Low (well-known) | ✅ Very low |
| **Maturity** | ✅ CNCF Graduated | ✅ CNCF Graduated | ⚠️ CNCF Sandbox |

**Decision Logic**:
```javascript
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
- Je wilt dynamische configuratie zonder restarts → Traefik
- Je bent all-in op Envoy ecosystem (Istio/Contour) → Envoy Gateway/Contour

**Primary Choice**: NGINX Ingress Controller

**Layer 0 Rationale**:
- **Maturity**: Meest gebruikte ingress controller (battle-tested)
- **Cloud-Agnostic**: Werkt overal (vendor independence)
- **Feature Set**: SSL termination, rate limiting, rewrites (voldoet aan requirements)
- **Community**: Grootste community, veel documentatie

**Alternative A**: Traefik
**When**:
- Dynamic configuration vereist (no restart voor config changes)
- Moderne UI gewenst (Traefik dashboard)
- Let's Encrypt integratie out-of-box (maar cert-manager beter voor production)

**Alternative B**: Contour / Envoy Gateway
**When**:
- All-in op Envoy ecosystem (service mesh planned)
- HTTPProxy CRD voorkeur over Ingress resource

**Alternative C**: Cloud-native LB (AWS ALB, Azure Application Gateway)
**When**:
- All-in op cloud provider (vendor lock-in acceptable)
- Managed LB features gewenst (WAF, etc.)

**Trade-offs**:
| Feature | NGINX | Traefik | Contour | Cloud LB |
|---------|-------|---------|---------|----------|
| **Maturity** | ✅ Very mature | ✅ Mature | ⚠️ Growing | ✅ Mature |
| **Configuration Reload** | ⚠️ Restart needed | ✅ Dynamic | ✅ Dynamic | ✅ Managed |
| **Feature Set** | ✅ Comprehensive | ✅ Comprehensive | ✅ Good | ✅ Comprehensive |
| **Vendor Independence** | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| **Operational Burden** | ✅ Low | ✅ Low | ✅ Low | ✅ Managed |
| **Cost** | ✅ Free | ✅ Free | ✅ Free | ⚠️ Per LB fee |

**Decision Logic**:
```javascript
if (vendor_independence === "high") {
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

#### Use No Service Mesh (Layer 1) unless
**Conditions**:
- Je hebt > 5 microservices MET complexe inter-service communicatie
- Per-service mTLS vereist (compliance requirement)
- Advanced traffic management nodig (canary, traffic splitting)

**Primary Choice**: No Service Mesh (start Layer 1)

**Layer 0 Rationale**:
- **Team Maturity**: Service mesh adds significant complexity
- **Architecture**: Monolith doesn't need service mesh (overhead without benefit)
- **Non-Goal**: Advanced observability (distributed tracing) is Layer 2

**When to Add (Layer 2)**: If migrating to microservices (> 5 services)

**If Service Mesh Needed, Use Linkerd unless**:
- Je wilt Envoy ecosystem integration → Istio
- Je hebt Cilium already EN wilt single tool voor networking + mesh → Cilium Service Mesh

**Alternative A**: Linkerd (Recommended for Mesh)
**When**:
- Simplicity priority (easiest service mesh)
- mTLS out-of-box
- Low resource overhead

**Alternative B**: Istio
**When**:
- Complex traffic management (advanced routing rules)
- Envoy ecosystem (tracing, etc.)
- Large scale (> 100 services)

**Alternative C**: Cilium Service Mesh
**When**:
- Already using Cilium CNI (single tool for CNI + mesh)
- eBPF-based service mesh desired

**Decision Logic**:
```javascript
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
- Je wilt GitOps-pure zonder UI → Flux
- Je hebt complexe Helm + image automation → Flux (sterkere Helm support)
- Je wilt minimale footprint → Flux (lighter-weight)

**Primary Choice**: Argo CD

**Layer 0 Rationale**:
- **Audit Trail**: Change tracking voor compliance (Layer 0 requirement)
- **UI**: Support/Management kunnen deployment status zien zonder kubectl
- **RBAC + SSO**: Native integratie (Layer 0 security requirement)
- **Self-Service**: Developers kunnen deployments triggeren via Git PR

**Alternative**: Flux
**When**:
- GitOps-pure philosophy (Git is absolute source of truth, no UI)
- Helm + image automation is complex use case
- Minimale resource footprint vereist

**Trade-offs**:
| Feature | Argo CD | Flux |
|---------|---------|------|
| **UI** | ✅ Yes (dashboard) | ❌ No (CLI only) |
| **RBAC/SSO** | ✅ Native | ⚠️ K8s RBAC only |
| **Multi-tenancy** | ✅ Projects (built-in) | ⚠️ Manual setup |
| **Helm Support** | ✅ Good | ✅ Excellent |
| **Image Automation** | ⚠️ Limited (needs Argo Image Updater) | ✅ Native |
| **Resource Footprint** | ⚠️ Medium (3-4 pods) | ✅ Light (2 pods) |
| **Audit Trail** | ✅ Built-in | ⚠️ Git only |

**Decision Logic**:
```javascript
if (ui_required_for_support_team || rbac_sso_required) {
  return "Argo CD";
} else if (gitops_pure_philosophy && no_ui_needed) {
  return "Flux";
} else if (complex_helm_image_automation) {
  return "Flux (better Helm/image support)";
} else {
  return "Argo CD (default for teams with UI/RBAC needs)";
}
```

---

### 3.2 CI/CD Pipeline

#### Use GitHub Actions unless
**Conditions**:
- Je gebruikt GitLab → GitLab CI
- Je bent all-in op Kubernetes-native CI → Tekton
- Je hebt legacy Jenkins setup → Migreer naar GitHub Actions iteratief

**Primary Choice**: GitHub Actions

**Layer 0 Rationale**:
- **Integration**: Native met GitHub (repository is daar al)
- **Simplicity**: YAML-based, easy learning curve
- **Cost**: Free tier generous voor small teams
- **Ecosystem**: Marketplace met duizenden actions

**Alternative A**: GitLab CI
**When**:
- GitLab is repository platform
- GitLab features gewenst (container registry, security scanning integrated)

**Alternative B**: Tekton (Kubernetes-native)
**When**:
- Fully Kubernetes-native CI/CD gewenst
- Complex pipeline orchestration (parallel tasks, etc.)
- Vendor independence absolute priority

**Alternative C**: Jenkins
**When**:
- Legacy Jenkins setup exists
- Complex groovy-based pipelines exist (migration cost high)

**Decision Logic**:
```javascript
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
- Je hebt enterprise SaaS budget → Datadog/New Relic (minder ops overhead)
- Je bent all-in op cloud provider → Cloud-native monitoring (CloudWatch, Azure Monitor)

**Primary Choice**: Prometheus + Grafana

**Layer 0 Rationale**:
- **Budget**: Open-source (no per-host licensing costs)
- **Vendor Independence**: Self-hosted, cloud-agnostic
- **Ecosystem**: Largest community, most integrations
- **Standard**: De facto standard for Kubernetes monitoring

**Alternative A**: VictoriaMetrics + Grafana
**When**:
- Long-term storage requirements (Prometheus retention limited to weeks)
- Cost-sensitive (VM more efficient storage)
- High cardinality metrics

**Alternative B**: Datadog / New Relic (SaaS)
**When**:
- Budget available (~$15-30/host/month)
- Lower operational burden priority
- APM + infrastructure monitoring in single tool

**Alternative C**: Cloud-native (CloudWatch, Azure Monitor)
**When**:
- All-in op cloud provider (vendor lock-in acceptable)
- Unified billing met andere cloud services

**Trade-offs**:
| Feature | Prometheus+Grafana | VictoriaMetrics | Datadog | Cloud-native |
|---------|-------------------|----------------|---------|--------------|
| **Cost** | ✅ Free (self-hosted) | ✅ Free (self-hosted) | ❌ $$$$ | ⚠️ $$ |
| **Operational Burden** | ⚠️ Self-managed | ⚠️ Self-managed | ✅ Managed | ✅ Managed |
| **Vendor Independence** | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| **Long-term Storage** | ⚠️ Limited (weeks) | ✅ Excellent | ✅ Excellent | ✅ Good |
| **Query Language** | ✅ PromQL (standard) | ✅ PromQL compatible | ⚠️ Proprietary | ⚠️ Proprietary |
| **Community** | ✅ Largest | ⚠️ Growing | ✅ Large | ⚠️ Cloud-specific |

**Decision Logic**:
```javascript
if (budget_constraint === "low" && vendor_independence === "high") {
  if (long_term_storage_required) {
    return "VictoriaMetrics + Grafana";
  } else {
    return "Prometheus + Grafana";
  }
} else if (budget_available && operational_simplicity_priority) {
  return "Datadog/New Relic (SaaS)";
} else if (cloud_native_preference && vendor_lockin_acceptable) {
  return "Cloud-native monitoring (CloudWatch, Azure Monitor)";
} else {
  return "Prometheus + Grafana (default)";
}
```

---

### 4.2 Logging

#### Use Grafana Loki unless
**Conditions**:
- Je hebt legacy ELK stack → Behoud ELK (migratie cost/benefit)
- Je wilt full-text search over alle logs → Elasticsearch (Loki is label-based)

**Primary Choice**: Grafana Loki

**Layer 0 Rationale**:
- **Cost**: Label-based indexing (cheaper storage than full-text)
- **Integration**: Native Grafana integration (same UI as metrics)
- **Simplicity**: Lower operational overhead than ELK stack
- **Vendor Independence**: Open-source, self-hosted

**Alternative A**: ELK Stack (Elasticsearch, Logstash, Kibana)
**When**:
- Full-text search vereist (alle logs doorzoekbaar)
- Legacy ELK stack exists (migration cost high)
- Complex log analytics (aggregations, etc.)

**Alternative B**: Cloud-native (CloudWatch Logs, Azure Log Analytics)
**When**:
- All-in op cloud provider
- Unified billing/management

**Alternative C**: Splunk / Sumo Logic (SaaS)
**When**:
- Enterprise SaaS budget
- Advanced analytics + alerting
- Compliance/audit features out-of-box

**Decision Logic**:
```javascript
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
- Je bent all-in op cloud provider → Cloud KMS + External Secrets (AWS Secrets Manager, Azure Key Vault)
- Je wilt absolute simpelheid → Sealed Secrets (maar geen centralized management)

**Primary Choice**: HashiCorp Vault + External Secrets Operator

**Layer 0 Rationale**:
- **Vendor Independence**: Self-hosted, portable
- **Centralized**: Single source of truth voor alle secrets
- **Rotation**: Automated secret rotation support
- **Audit**: Complete audit trail (compliance requirement)

**Alternative A**: Cloud KMS + External Secrets Operator
**When**:
- Cloud provider is primary infrastructure (vendor lock-in acceptable voor secrets)
- Lower operational burden (managed service)
- Native cloud integration gewenst

**Alternative B**: Sealed Secrets
**When**:
- Simplicity priority (secrets encrypted in Git)
- No centralized secret management needed
- Small team / simple use case

**Alternative C**: Kubernetes Secrets (Plain)
**When**:
- ❌ **NEVER** for production (Layer 0 principe: no secrets in plaintext)
- Development environments only

**Trade-offs**:
| Feature | Vault | Cloud KMS | Sealed Secrets | K8s Secrets |
|---------|-------|-----------|----------------|-------------|
| **Vendor Independence** | ✅ Yes | ❌ No | ✅ Yes | ✅ Yes |
| **Operational Burden** | ⚠️ Self-managed | ✅ Managed | ✅ Low | ✅ Native |
| **Secret Rotation** | ✅ Yes | ✅ Yes | ❌ Manual | ❌ Manual |
| **Audit Trail** | ✅ Complete | ✅ Good | ⚠️ Git only | ❌ Limited |
| **Centralized Management** | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| **Encryption at Rest** | ✅ Yes | ✅ Yes | ✅ Yes | ⚠️ K8s etcd encryption |

**Decision Logic**:
```javascript
if (vendor_independence === "high") {
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
- Je hebt SaaS budget → Snyk / Aqua Security (enterprise features)
- Je wilt specifieke compliance scanning → Clair + policy frameworks

**Primary Choice**: Trivy (CI/CD) + Harbor Scanning (Registry)

**Layer 0 Rationale**:
- **Cost**: Open-source, free
- **Comprehensive**: CVE, misconfigurations, secrets scanning
- **Integration**: Easy CI/CD integration, multiple output formats
- **Vendor Independence**: Self-hosted

**Alternative A**: Snyk / Aqua Security (SaaS)
**When**:
- Enterprise SaaS budget
- Developer-focused workflows (IDE integration, PR comments)
- Compliance reporting out-of-box

**Alternative B**: Grype (Anchore)
**When**:
- Open-source voorkeur
- Prefer Anchore ecosystem (Syft SBOM generation)

**Decision Logic**:
```javascript
if (budget_constraint === "low") {
  return "Trivy (open-source, comprehensive)";
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
- Break-glass scenarios (cluster-admin voor noodgevallen) → Tijdelijk elevated access
- Platform team baseline → Cluster-scoped voor infrastructure management

**Primary Choice**: Namespace-scoped RBAC (developers), Cluster-scoped (platform team)

**Layer 0 Rationale**:
- **Least Privilege**: Developers geen cluster-admin (compliance requirement)
- **Isolation**: Teams kunnen elkaar niet beïnvloeden
- **Audit**: Clear ownership per namespace

**RBAC Roles Matrix**:
| Role | Scope | Permissions | Assignment |
|------|-------|-------------|------------|
| **namespace-admin** | Namespace | Full access binnen namespace (deployments, services, secrets) | Tech leads per team |
| **namespace-developer** | Namespace | Deploy via GitOps (read-only direct access) | Developers |
| **namespace-viewer** | Namespace | Read-only (dashboards, logs) | Support team |
| **cluster-admin** | Cluster | Full cluster access (AVOID for regular use) | Platform team (break-glass only) |
| **cluster-viewer** | Cluster | Read-only cluster-wide (monitoring, auditing) | Ops team, SREs |

**Decision Logic**:
```javascript
if (user_role === "developer") {
  return "namespace-developer (GitOps-only deployments)";
} else if (user_role === "tech_lead") {
  return "namespace-admin (full namespace access)";
} else if (user_role === "support") {
  return "namespace-viewer (read-only)";
} else if (user_role === "platform_engineer") {
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
- Vendor independence is absolute requirement → StatefulSet (maar veel hogere ops burden)

**Primary Choice**: Managed PostgreSQL (Cloud Provider)

**Layer 0 Rationale**:
- **Team Maturity**: Geen database HA expertise (Layer 0 constraint)
- **Data Resilience**: PITR + HA native (Layer 0 requirement: RPO 15min)
- **Operational Burden**: Managed service reduces operational risk
- **Trade-off**: Vendor dependency geaccepteerd voor **database specifically** (niet voor compute/networking)

**Alternative A**: StatefulSet + Postgres/MySQL Operator
**When**:
- Team heeft database operations expertise (DBA in team)
- Vendor independence is absolute (can't accept managed DB dependency)
- Complex database configurations vereist (extensions, custom tuning)

**Alternative B**: External VM/Bare-metal Database
**When**:
- Legacy database exists (migration cost too high)
- Database size/performance vereist dedicated hardware
- Separation of concerns (database not in K8s cluster)

**Trade-offs**:
| Aspect | Managed DB | StatefulSet + Operator | External DB |
|--------|-----------|----------------------|-------------|
| **HA + PITR** | ✅ Native | ⚠️ Manual config (complex) | ⚠️ Manual config |
| **Operational Burden** | ✅ Low (managed) | ❌ High (self-managed) | ⚠️ Medium |
| **Vendor Independence** | ❌ Cloud provider lock-in | ✅ Portable | ✅ Portable |
| **Cost** | ⚠️ Higher (managed fee) | ✅ Lower (only compute) | ✅ Lower |
| **Team Expertise Required** | ✅ Low | ❌ High (DBA skills) | ⚠️ Medium |

**Decision Logic**:
```javascript
if (team_has_dba && vendor_independence_absolute) {
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
- Je bent all-in op cloud provider → Cloud-native snapshots (AWS Backup, Azure Backup)
- Enterprise backup platform exists → Kasten K10 (enterprise features + support)

**Primary Choice**: Velero + Database Native Backup

**Layer 0 Rationale**:
- **Vendor Independence**: S3-compatible storage (portable)
- **Kubernetes-native**: Backup namespaces, PVs, cluster resources
- **Open-source**: Free, community support

**For Database**:
- Managed Database → Native backup/PITR (cloud provider)
- StatefulSet Database → pg_dump/mysqldump + Velero PV snapshots

**Alternative A**: Kasten K10
**When**:
- Enterprise features gewenst (policy-driven backup, application-aware)
- Commercial support vereist
- Compliance reporting out-of-box

**Alternative B**: Cloud-native Backup (AWS Backup, Azure Backup)
**When**:
- All-in op cloud provider
- Unified backup management voor VMs + K8s + databases

**Decision Logic**:
```javascript
if (vendor_independence === "high") {
  return "Velero + S3-compatible storage";
} else if (enterprise_features_required && budget_available) {
  return "Kasten K10";
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
- Je hebt geen caching layer nodig → Skip (maar waarschijnlijk wel nodig voor session management)

**Primary Choice**: Valkey (open-source Redis fork)

**Layer 0 Rationale**:
- **Vendor Independence**: Open-source, community-driven (post-Redis license change)
- **Compatibility**: Drop-in replacement voor Redis
- **Session Management**: Vereist voor horizontale scaling (stateless application requirement)

**Alternative A**: Managed Redis (Cloud Provider)
**When**:
- Operational simplicity priority
- HA + failover out-of-box gewenst
- Budget available

**Alternative B**: Memcached
**When**:
- Simple key-value cache only (geen persistence)
- Lower memory footprint
- No advanced data structures needed

**Decision Logic**:
```javascript
if (application_stateless_required) {
  if (vendor_independence === "high") {
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
- Je hebt geen capaciteit voor registry operations → Cloud provider registry (ECR, ACR, GCR)
- Je wilt vendor SaaS → Quay.io, Docker Hub (paid tiers)

**Primary Choice**: Harbor (self-hosted)

**Layer 0 Rationale**:
- **Vendor Independence**: Self-hosted, cloud-agnostic
- **Image Scanning**: Trivy integrated
- **RBAC**: Project-based access control
- **Replication**: Multi-registry replication (DR scenarios)

**Alternative A**: Cloud Provider Registry (ECR, ACR, GCR)
**When**:
- Managed service voorkeur
- Tight cloud integration (IAM, etc.)
- No operational burden voor registry

**Alternative B**: Quay.io / Docker Hub (SaaS)
**When**:
- Public images (open-source projects)
- No self-hosting capacity
- Budget voor paid tiers

**Decision Logic**:
```javascript
if (vendor_independence === "high" && team_can_operate_registry) {
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
- Je hebt legacy Ansible → Migreer naar Terraform iteratief

**Primary Choice**: Terraform

**Layer 0 Rationale**:
- **Vendor Independence**: Multi-cloud, cloud-agnostic
- **Maturity**: Stable providers, large community
- **State Management**: Remote state for team collaboration

**Alternative A**: Pulumi
**When**:
- Modern programming language voorkeur (TypeScript, Python, Go)
- Code reuse / testability priority
- Team heeft programming background (not just ops)

**Alternative B**: Crossplane
**When**:
- Kubernetes-native provisioning gewenst
- GitOps for infrastructure (not just applications)
- Complex multi-cloud orchestration

**Decision Logic**:
```javascript
if (vendor_independence === "high") {
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
      default: "None (Layer 1)"
      unless: ">5 microservices OR mTLS compliance required"
  
  gitops:
    tool:
      default: "Argo CD"
      unless: "GitOps-pure zonder UI (Flux)"
  
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
      unless: "Team heeft DBA expertise AND vendor independence absolute"
    
    backup:
      default: "Velero"
      unless: "Enterprise features required (Kasten K10)"
    
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

**Document Eigenaar**: Architecture Board  
**Update Frequentie**: Bij nieuwe tool evaluations of Layer 0 requirement changes  
**Voor AI Agents**: Decision logic is extractable for automated recommendations  

**Versie**: 1.0  
**Datum**: December 2024  
**Licentie**: MIT
