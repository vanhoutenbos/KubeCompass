# Real-World Scenarios

This document provides concrete architectural examples for common Kubernetes use cases. Each scenario includes:
- Context and requirements
- Tool selections with rationale
- Architecture overview
- Security posture
- Cost considerations

---

## Scenario 1: Enterprise Multi-Tenant Architecture

### Context

**Target sectors**: Finance and government  
**Organization size**: 200-500 employees, 10-20 development teams  
**Compliance requirements**: ISO 27001, SOC 2 Type II, GDPR  
**Uptime target**: 99.99% (four nines) for critical systems  
**Security posture**: Zero-trust, defense-in-depth, audit everything  
**Tenancy model**: Multiple departments/teams with strict isolation  

**Key challenges**:
- Each department needs isolated namespaces with strict resource limits
- Compliance requires audit trails for all changes and access
- Security teams need visibility without impacting performance
- Multiple teams must deploy independently without interfering with each other

---

### Architecture Overview

**Cluster topology**:
- **Multi-zone deployment**: 3 availability zones for HA
- **Node pools**: Separate pools for control plane, workloads, and observability
- **Multi-region**: Optional active-passive DR setup for critical systems

**Tenancy model**:
- **Namespace per team/department**: Logical isolation boundary
- **Resource quotas**: CPU, memory, and storage limits per namespace
- **Network policies**: Default deny, explicit allow between namespaces
- **RBAC**: Team-scoped roles, no cluster-admin for regular users

---

### Layer 0: Foundational Decisions (Made Day 1)

#### 1. CNI: Cilium

**Why Cilium**:
- **eBPF-based networking**: High performance without iptables overhead
- **Network policies with L7 visibility**: Critical for zero-trust security model
  - Can enforce policies based on HTTP methods, paths, headers
  - Example: "Department A can only call `/api/v1/public` endpoints in Department B"
- **Hubble observability**: Built-in network flow visualization for troubleshooting and compliance
- **Compliance support**:
  - Audit logging for network policy violations (SOC 2)
  - Flow logs for security monitoring (ISO 27001)
  - Network segmentation for multi-tenancy (GDPR data isolation)
- **CNCF Graduated**: Long-term vendor-neutral support

**Configuration highlights**:
- Enable network policies by default
- Deploy Hubble UI and Hubble Relay for observability
- Configure flow export to SIEM for compliance
- Enable encryption for inter-node traffic (optional, for defense-in-depth)

**Alternatives considered**:
- **Calico**: Mature and battle-tested, but lacks eBPF performance and L7 policy features
- **Decision**: Cilium for modern security features and observability

---

#### 2. GitOps: Argo CD

**Why Argo CD**:
- **Multi-tenant architecture**: Projects isolate teams, RBAC controls access
  - Each department gets an Argo CD "Project" with scoped repositories and destinations
  - Example: "Finance team can only deploy to `finance-*` namespaces"
- **SSO integration**: Works with Keycloak for centralized authentication
  - Non-technical stakeholders (managers, auditors) can view deployment status
  - Role-based access: developers can sync, managers can view, auditors read-only
- **Audit trails**: Complete change history for ISO 27001 compliance
  - Who deployed what, when, and from which Git commit
  - Drift detection: alerts when manual changes bypass GitOps
- **Rich UI**: Easier for teams to self-serve and troubleshoot
- **CNCF Graduated**: Production-proven, large community

**Configuration highlights**:
- One Argo CD "Project" per department/team
- RBAC policies mapped to Keycloak groups (OIDC integration)
- Webhook notifications to Slack/Teams for deployment events
- Git repositories structured by environment (dev, staging, prod)

**Alternatives considered**:
- **Flux**: More GitOps-pure but lacks multi-tenant UI and project isolation
- **Decision**: Argo CD for enterprise multi-tenancy and SSO integration

---

#### 3. Identity & Access Control: Keycloak + Kubernetes RBAC

**Why Keycloak**:
- **OIDC/SAML provider**: Integrates with Kubernetes API server for SSO
- **Centralized identity**: Single source of truth for user authentication
- **Multi-factor authentication (MFA)**: Required for SOC 2 compliance
- **Group-based access**: Map Keycloak groups to Kubernetes Roles
  - Example: `finance-developers` group → `finance-namespace-developer` Role
- **Audit logging**: All authentication attempts logged for compliance

**How it works**:
1. **User authenticates**: Developer logs into Keycloak (SSO with MFA)
2. **OIDC token issued**: Keycloak provides JWT with group claims
3. **Kubernetes validates**: API server validates token against Keycloak
4. **RBAC enforces**: Kubernetes maps groups to Roles/RoleBindings
5. **Scoped access**: Developer can only access their team's namespaces

**RBAC structure**:
- **Namespace-scoped roles**: `developer`, `viewer`, `admin` per namespace
- **Cluster-scoped roles**: Only for platform team (`cluster-admin` tightly controlled)
- **Service accounts**: Per-application, scoped to namespace, no shared secrets

**Compliance benefits**:
- **ISO 27001**: Centralized access control, audit logs, MFA enforcement
- **SOC 2**: Access reviews, least privilege, role-based access
- **GDPR**: Minimal access to personal data, audit trails for data access

---

#### 4. Secrets Management: HashiCorp Vault + External Secrets Operator

**Why Vault + ESO**:
- **Vault**: Industry-standard secrets management
  - Encryption at rest and in transit (GDPR compliance)
  - Dynamic secrets for databases (credentials rotated automatically)
  - Audit logging for all secret access (SOC 2 compliance)
  - Fine-grained policies (teams can only access their secrets)
- **External Secrets Operator (ESO)**: Kubernetes-native integration
  - Syncs secrets from Vault to Kubernetes Secrets automatically
  - Teams don't need direct Vault access (reduces complexity)
  - Secrets never committed to Git (GitOps-friendly)

**How it works**:
1. **Secrets stored in Vault**: Platform team or automated process stores secrets
2. **ESO watches ExternalSecret resources**: Defined in GitOps repos
3. **ESO fetches from Vault**: Uses service account token for authentication
4. **Kubernetes Secret created**: Application can mount as volume or env vars

**Configuration highlights**:
- Vault deployed in HA mode (3 replicas, multi-zone)
- Kubernetes auth method enabled (pods authenticate with service account tokens)
- Vault policies per namespace: `finance-namespace` policy only allows `finance/*` secrets
- Audit logs exported to SIEM for compliance

**Alternatives considered**:
- **Sealed Secrets**: Simpler but lacks dynamic secrets and fine-grained policies
- **Cloud-native secret managers** (AWS Secrets Manager, Azure Key Vault): Cloud lock-in
- **Decision**: Vault + ESO for flexibility, compliance, and cloud-agnostic approach

---

#### 5. Storage: Cloud-Native CSI Drivers

**Why cloud-native CSI**:
- **Fully managed**: No storage cluster to operate (reduces operational overhead)
- **High availability**: Cloud providers handle replication and failover
- **Backup integration**: Native snapshot support (integrated with Velero)
- **Performance**: SSD-backed, predictable I/O for databases

**Configuration highlights**:
- **StorageClasses**: Different tiers (SSD, HDD) for different workload needs
- **Volume snapshots**: Daily snapshots via Velero for RPO compliance
- **Encryption at rest**: Enabled by default (GDPR compliance)

**Alternatives considered**:
- **Rook-Ceph**: Cloud-agnostic but high operational complexity
- **Decision**: Cloud-native CSI for simplicity and reliability

---

### Layer 1: Core Operations (Implemented Within First Month)

#### 6. Observability: Prometheus + Loki + Grafana

**Why this stack**:
- **Unified observability**: Single pane of glass for metrics, logs, and dashboards
- **Prometheus**: CNCF Graduated, industry-standard metrics
  - Scrapes metrics from all workloads
  - Alertmanager for critical alerts (PagerDuty integration)
  - Thanos for long-term storage (1-year retention for compliance)
- **Loki**: Cost-effective logging (indexes labels, not full text)
  - Centralizes logs from all pods
  - Query logs by namespace, pod, container for troubleshooting
- **Grafana**: Rich dashboards for teams and management
  - Team-specific dashboards (each team sees only their namespaces)
  - SRE dashboards (cluster health, resource usage, SLOs)

**Compliance benefits**:
- **Audit logs**: Kubernetes API server audit logs stored in Loki (ISO 27001)
- **Alerting**: Real-time notifications for security events (SOC 2)
- **Retention**: 1-year metric/log retention for compliance audits

**Configuration highlights**:
- Prometheus deployed per namespace (tenant isolation)
- Thanos for cross-cluster aggregation and long-term storage
- Grafana RBAC integrated with Keycloak (teams see only their dashboards)

---

#### 7. Ingress: NGINX Ingress Controller

**Why NGINX**:
- **Battle-tested**: Mature, stable, widely adopted
- **TLS termination**: Automatic TLS with cert-manager (Let's Encrypt or internal CA)
- **Rate limiting**: Protect APIs from abuse
- **IP whitelisting**: Restrict access to internal tools (compliance requirement)

**Configuration highlights**:
- **TLS everywhere**: All ingress routes enforce HTTPS (GDPR compliance)
- **ModSecurity WAF**: Optional web application firewall for extra defense
- **Audit logging**: Access logs exported to Loki for compliance

---

#### 8. Backup & Disaster Recovery: Velero

**Why Velero**:
- **Cluster-wide backups**: Backs up namespaces, PVs, and cluster resources
- **Scheduled backups**: Daily full backups, hourly incrementals
- **Cross-region replication**: Backups stored in separate region for DR
- **Tested restores**: Quarterly DR drills to validate RPO/RTO

**Configuration highlights**:
- **Backup scope**: Per-namespace backups (teams can restore their own)
- **Retention**: 30-day retention (configurable per compliance needs)
- **Restore testing**: Automated restore validation in non-prod cluster

**Compliance benefits**:
- **RPO**: Near-zero with continuous PV snapshots
- **RTO**: 15-minute restore time for critical namespaces
- **Audit**: Backup logs for compliance verification

---

### Layer 2: Security Enhancements (Added After Core Platform is Stable)

#### 9. Image Scanning: Trivy

**Why Trivy**:
- **CI/CD integration**: Scans images in GitHub Actions/GitLab CI before push
- **Admission controller**: Blocks vulnerable images at deploy time
- **Compliance**: Generates SBOMs for supply chain security (SOC 2)

**Configuration highlights**:
- **CI/CD**: Fail builds if HIGH or CRITICAL vulnerabilities found
- **Admission webhook**: Optional enforcement in production (warn-only mode initially)
- **Exceptions**: Allow-list for accepted risks (documented for auditors)

---

#### 10. Policy Enforcement: Kyverno

**Why Kyverno**:
- **Compliance as code**: Enforce Pod Security Standards, require labels, disallow privileged pods
- **YAML-based**: Easier for teams to write and review policies
- **Audit mode**: Report violations before enforcing (gradual rollout)

**Example policies**:
- Require `owner` and `cost-center` labels on all pods (for cost tracking)
- Disallow `hostPath` volumes (security risk)
- Enforce resource requests/limits (prevent resource exhaustion)
- Require non-root containers (security baseline)

---

#### 11. Runtime Security: Falco

**Why Falco**:
- **Threat detection**: Real-time alerts for suspicious activity
  - Unexpected shell spawned in container
  - File access in sensitive directories (`/etc/passwd`)
  - Outbound network connections to unknown IPs
- **CNCF Graduated**: Production-proven
- **Compliance**: Incident detection for SOC 2, ISO 27001

**Configuration highlights**:
- **Custom rules**: Tailored for finance/government threat models
- **SIEM integration**: Alerts forwarded to SIEM for correlation
- **Response runbooks**: Defined procedures for Falco alerts

---

### Security Posture Summary

| Layer | Control | Tool | Purpose |
|-------|---------|------|---------|
| **Authentication** | SSO with MFA | Keycloak | Centralized identity, compliance |
| **Authorization** | RBAC | Kubernetes + Keycloak | Least privilege, namespace isolation |
| **Secrets** | Encrypted storage | Vault + ESO | Protect credentials, dynamic secrets |
| **Network** | Zero-trust policies | Cilium | L7 policies, tenant isolation |
| **Ingress** | TLS + rate limiting | NGINX Ingress | Protect APIs, enforce HTTPS |
| **Images** | Vulnerability scanning | Trivy | Block CVEs before deploy |
| **Runtime** | Threat detection | Falco | Detect anomalies in real-time |
| **Policy** | Compliance enforcement | Kyverno | Pod Security Standards, labels |
| **Observability** | Audit logging | Prometheus + Loki | Detect incidents, compliance audits |
| **Backup** | Disaster recovery | Velero | RPO/RTO compliance |

---

### Cost Considerations

**Note**: Tool costs are primarily infrastructure (compute, storage, bandwidth). Actual cloud hosting costs vary significantly by provider and scale.

**Estimated infrastructure requirements** (for 50-100 workloads):

| Component | Resources | Notes |
|-----------|-----------|-------|
| **Control plane** | 3 nodes (4 vCPU, 16GB RAM each) | HA etcd, API servers, controllers |
| **Worker nodes** | 10-20 nodes (8 vCPU, 32GB RAM each) | Autoscale based on workload demand |
| **Observability** | 3 nodes (8 vCPU, 32GB RAM each) | Prometheus, Loki, Grafana (can share with workers) |
| **Storage** | 2TB persistent volumes | Application data, logs, backups |
| **Backup storage** | 5TB object storage | Off-cluster backups (S3, Azure Blob, GCS) |

**Cost optimization tips**:
- Use spot/preemptible instances for non-critical workloads
- Autoscale worker nodes based on demand
- Use node affinity to pack workloads efficiently
- Implement resource quotas to prevent waste
- Use Kubecost or OpenCost to track and allocate costs per team

**Open-source tools = no licensing costs**:
- All tools in this stack are open-source (Apache 2.0 or similar)
- No vendor lock-in or mandatory SaaS subscriptions
- Support costs (if needed) via commercial offerings (Isovalent for Cilium, HashiCorp for Vault, etc.)

---

### Deployment Timeline

**Week 1: Foundation**
- [ ] Deploy Kubernetes cluster (multi-zone, HA control plane)
- [ ] Install Cilium CNI
- [ ] Set up Keycloak and integrate with Kubernetes OIDC
- [ ] Configure RBAC roles and policies
- [ ] Deploy Vault and External Secrets Operator
- [ ] Set up cloud-native CSI storage classes

**Week 2-3: Core Operations**
- [ ] Deploy Prometheus, Loki, Grafana
- [ ] Set up Thanos for long-term metrics storage
- [ ] Configure Alertmanager and PagerDuty integration
- [ ] Deploy NGINX Ingress with cert-manager
- [ ] Set up Velero for backups and test restore

**Week 4: GitOps**
- [ ] Deploy Argo CD
- [ ] Structure Git repositories (per team/environment)
- [ ] Migrate first application to GitOps
- [ ] Train teams on Argo CD workflow

**Month 2: Security Enhancements**
- [ ] Integrate Trivy into CI/CD pipelines
- [ ] Deploy Kyverno and create baseline policies
- [ ] Deploy Falco and tune rules for environment
- [ ] Conduct security audit and penetration test

**Month 3: Compliance Readiness**
- [ ] Document all controls for ISO 27001 audit
- [ ] Conduct DR drill and measure RTO/RPO
- [ ] Complete SOC 2 readiness assessment
- [ ] Train teams on compliance procedures

---

### Success Metrics

**Availability**:
- ✅ 99.99% uptime for critical systems (measured monthly)
- ✅ RTO: 15 minutes or less for critical namespaces
- ✅ RPO: < 5 minutes for all persistent data

**Security**:
- ✅ Zero privileged pods in production (enforced by Kyverno)
- ✅ 100% of secrets encrypted at rest (Vault)
- ✅ All images scanned before deployment (Trivy)
- ✅ Network policies enforced on all namespaces (Cilium)

**Compliance**:
- ✅ API audit logs retained for 1 year (Loki)
- ✅ All deployments tracked via GitOps (Argo CD)
- ✅ Access reviews conducted quarterly (Keycloak + RBAC)
- ✅ DR drill passed within RTO/RPO targets

**Operations**:
- ✅ Mean time to detection (MTTD): < 5 minutes (Prometheus Alertmanager)
- ✅ Mean time to recovery (MTTR): < 15 minutes (automated runbooks)
- ✅ Developer self-service: 90% of deployments via GitOps (Argo CD)

---

## Scenario 2: Startup MVP (Cost-Optimized)

*(Coming soon: Simplified stack for fast iteration and low cost)*

**Key differences from enterprise**:
- Single-zone cluster (accept lower availability)
- Skip Keycloak (use kubeconfig files initially)
- Sealed Secrets instead of Vault
- Prometheus without Thanos (shorter retention)
- Skip Falco and Kyverno (add later)

---

## Scenario 3: Edge Computing

*(Coming soon: Resource-constrained, intermittent connectivity)*

**Key differences from enterprise**:
- K3s instead of full Kubernetes
- Lightweight storage (Longhorn)
- Local-first observability (no cloud dependencies)
- Offline-capable GitOps (Flux with Git over HTTPS caching)

---

## Next Steps

- 📖 **[Review the Decision Matrix](MATRIX.md)** to explore alternative tool choices
- 📋 **[See Production-Ready Definition](PRODUCTION_READY.md)** for compliance checklists
- 🔍 **[Read detailed tool reviews](reviews/)** for hands-on testing results

---

*This scenarios document will expand with more use cases (hybrid cloud, CI/CD-heavy, air-gapped, etc.) as the project matures.*
