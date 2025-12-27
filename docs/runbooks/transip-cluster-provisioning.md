# TransIP Kubernetes Cluster Provisioning Runbook

**Purpose**: Reproducible procedure for provisioning a TransIP Kubernetes cluster  
**Audience**: Platform Engineers, DevOps Team  
**Prerequisites**: TransIP account with Kubernetes access  
**Duration**: 30-45 minutes  
**Status**: Production-ready  

---

## Overview

TransIP does not provide a Terraform provider for Kubernetes cluster lifecycle management. This runbook documents the manual provisioning process to ensure reproducibility and consistency.

### Why Manual Provisioning?

- ✅ **Reproducible**: Follow this documented procedure
- ✅ **Auditable**: Document decisions and configurations
- ✅ **Team Knowledge**: Anyone can provision following this guide
- ⚠️ **Manual**: Requires human intervention (no automation)
- ⚠️ **State Drift Risk**: Console changes not tracked in Git

**Trade-off accepted**: Manual cluster provisioning is acceptable for Nederlandse SME case given other benefits (Dutch support, GDPR, pricing).

---

## Prerequisites

### Access & Credentials

- [ ] TransIP account with Kubernetes service enabled
- [ ] Sufficient permissions to create Kubernetes clusters
- [ ] Access to secrets manager (Vault, 1Password, AWS Secrets Manager)

### Tools

- [ ] Web browser (for TransIP Control Panel)
- [ ] `kubectl` CLI installed locally
- [ ] Text editor for documentation

---

## Production Cluster Provisioning

### Step 1: Login to TransIP Control Panel

1. Navigate to: https://www.transip.nl/cp
2. Login with your credentials
3. Navigate to: **Services** → **Kubernetes**

### Step 2: Create New Cluster

Click **"Create Kubernetes Cluster"** button

### Step 3: Cluster Configuration

Fill in the cluster details:

| Setting | Value | Rationale |
|---------|-------|-----------|
| **Cluster Name** | `webshop-prod` | Descriptive, indicates environment |
| **Region** | `Amsterdam (ams1)` | GDPR compliance (NL datacenter), low latency |
| **Kubernetes Version** | `1.28.x` (N-1) | Stability over latest features |
| **High Availability** | ✅ Enabled | Layer 0 requirement (99.9% uptime) |
| **Automatic Updates** | ⚠️ Security patches only | Control upgrade timing |

**Screenshot Location**: `docs/screenshots/transip-cluster-config.png` (optional: take screenshot for future reference)

Click **"Next"** or **"Continue"**

### Step 4: Node Pool Configuration - System Pool

**Purpose**: Dedicated nodes for platform components (ingress, monitoring, ArgoCD)

| Setting | Value | Rationale |
|---------|-------|-----------|
| **Pool Name** | `system-pool` | Descriptive identifier |
| **Node Type** | `Standard-4vcpu-8gb` | Sufficient for platform workloads |
| **Node Count** | `2` | High availability (minimum for HA) |
| **Autoscaling** | ❌ Disabled | System pool should be stable |
| **Labels** | `node-role=system` | For workload scheduling |
| **Taints** | ❌ None (configure via Terraform) | Will be set post-provision |

**Cost Impact**: 2 nodes × 4 vCPU, 8GB = ~€X/month (check current TransIP pricing)

Click **"Add Node Pool"** or **"Next"**

### Step 5: Node Pool Configuration - Application Pool

**Purpose**: Dedicated nodes for application workloads (webshop, databases)

| Setting | Value | Rationale |
|---------|-------|-----------|
| **Pool Name** | `app-pool` | Descriptive identifier |
| **Node Type** | `Standard-4vcpu-16gb` | More memory for applications |
| **Node Count** | `3` | Minimum for rolling updates |
| **Autoscaling** | ⚠️ Manual (see note) | TransIP may not offer autoscaling |
| **Labels** | `node-role=application` | For workload scheduling |
| **Taints** | ❌ None | General workload |

**Note**: If TransIP offers autoscaling:
- **Min Nodes**: 3
- **Max Nodes**: 6
- Enable if available

**Cost Impact**: 3-6 nodes × 4 vCPU, 16GB = ~€Y/month

Click **"Add Node Pool"** or **"Next"**

### Step 6: Review & Create

1. Review all configuration settings
2. Verify:
   - Cluster name: `webshop-prod`
   - Region: Amsterdam
   - HA enabled
   - 2 system nodes + 3 app nodes
3. Click **"Create Cluster"** or **"Provision"**

**Provisioning Time**: 10-15 minutes

### Step 7: Wait for Cluster Ready

Monitor cluster status in TransIP Control Panel:

```
Status: Provisioning → Active
Control Plane: Initializing → Running
Node Pools: Pending → Ready
```

**Expected timeline**:
- 5 min: Control plane ready
- 10 min: System nodes ready
- 15 min: Application nodes ready

---

## Post-Provisioning Configuration

### Step 8: Download Kubeconfig

1. In TransIP Control Panel, navigate to cluster details
2. Click **"Download Kubeconfig"** button
3. Save file to: `~/Downloads/webshop-prod-kubeconfig.yaml`

### Step 9: Secure Kubeconfig Storage

**CRITICAL**: Kubeconfig contains cluster admin credentials

```bash
# Move to secure location
mkdir -p ~/.kube
mv ~/Downloads/webshop-prod-kubeconfig.yaml ~/.kube/transip-webshop-prod.yaml

# Set restrictive permissions
chmod 600 ~/.kube/transip-webshop-prod.yaml

# Verify ownership
ls -la ~/.kube/transip-webshop-prod.yaml
# Expected: -rw------- (read/write owner only)
```

### Step 10: Store in Secrets Manager

**Option A: 1Password**
```bash
op create document ~/.kube/transip-webshop-prod.yaml \
  --title "TransIP Webshop Prod Kubeconfig" \
  --vault infrastructure \
  --tags kubernetes,transip,production
```

**Option B: Vault**
```bash
vault kv put secret/kubernetes/transip-webshop-prod \
  kubeconfig=@~/.kube/transip-webshop-prod.yaml
```

**Option C: AWS Secrets Manager**
```bash
aws secretsmanager create-secret \
  --name infrastructure/kubernetes/transip-prod-kubeconfig \
  --secret-string file://~/.kube/transip-webshop-prod.yaml \
  --region eu-west-1
```

### Step 11: Verify Cluster Access

```bash
# Set kubeconfig
export KUBECONFIG=~/.kube/transip-webshop-prod.yaml

# Test connection
kubectl cluster-info

# Expected output:
# Kubernetes control plane is running at https://...
# CoreDNS is running at https://...

# List nodes
kubectl get nodes

# Expected output:
# NAME                        STATUS   ROLES    AGE   VERSION
# webshop-prod-system-001     Ready    <none>   5m    v1.28.x
# webshop-prod-system-002     Ready    <none>   5m    v1.28.x
# webshop-prod-app-001        Ready    <none>   5m    v1.28.x
# webshop-prod-app-002        Ready    <none>   5m    v1.28.x
# webshop-prod-app-003        Ready    <none>   5m    v1.28.x

# Verify labels
kubectl get nodes --show-labels | grep node-role
```

### Step 12: Document Cluster Details

Create cluster documentation entry:

**File**: `docs/clusters/webshop-prod.md`

```markdown
# Webshop Production Cluster

**Provider**: TransIP Kubernetes  
**Region**: Amsterdam (ams1)  
**Created**: YYYY-MM-DD  
**Version**: 1.28.x  
**HA**: Enabled  

## Node Pools

### System Pool
- Name: `system-pool`
- Type: Standard-4vcpu-8gb
- Count: 2 nodes
- Purpose: Platform components

### Application Pool
- Name: `app-pool`
- Type: Standard-4vcpu-16gb
- Count: 3 nodes (scalable to 6)
- Purpose: Application workloads

## Access

- Kubeconfig: Stored in [secrets manager location]
- Control Panel: https://www.transip.nl/cp

## Cost

- Monthly estimate: €XXX (2 system + 3 app nodes)
```

### Step 13: Set Up Monitoring Alerts

Configure TransIP monitoring (if available):

1. Navigate to: Cluster → Monitoring
2. Enable alerts for:
   - Node status (down/unhealthy)
   - High CPU usage (> 80%)
   - High memory usage (> 85%)
   - Disk space (> 80%)

**Alert Recipients**: [team email/Slack webhook]

---

## Validation Checklist

Before proceeding to Terraform deployment:

- [ ] Cluster status: **Active**
- [ ] Control plane: **Running**
- [ ] System pool: 2 nodes **Ready**
- [ ] Application pool: 3+ nodes **Ready**
- [ ] Kubeconfig downloaded and secured
- [ ] Kubeconfig stored in secrets manager
- [ ] `kubectl get nodes` shows all nodes
- [ ] Node labels verified
- [ ] Cluster documentation created
- [ ] Monitoring alerts configured
- [ ] Team notified of cluster availability

---

## Next Steps

1. **Configure Terraform**: See [Production TransIP Terraform README](../../terraform/environments/production-transip/README.md)
2. **Deploy Platform Components**: Run `terraform apply`
3. **Set Up GitOps**: Configure ArgoCD applications
4. **Deploy Applications**: Push to Git, ArgoCD auto-deploys

---

## Troubleshooting

### Issue: Cluster provisioning failed

**Symptoms**: Status stuck in "Provisioning" for > 30 minutes

**Solution**:
1. Check TransIP status page: https://status.transip.nl/
2. Contact TransIP support: support@transip.nl
3. Provide cluster name and timestamp

### Issue: Nodes not reaching Ready state

**Symptoms**: Nodes show "NotReady" status

**Diagnosis**:
```bash
kubectl describe node <node-name>

# Check events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

**Common causes**:
- Network connectivity issues
- Resource constraints
- CSI driver not initialized

**Solution**: Wait 5-10 more minutes, or contact TransIP support

### Issue: Kubeconfig not working

**Symptoms**: `kubectl` commands fail with authentication error

**Diagnosis**:
```bash
# Verify kubeconfig format
cat ~/.kube/transip-webshop-prod.yaml

# Check cluster endpoint reachable
curl -k https://<cluster-endpoint>:6443
```

**Solution**:
- Re-download kubeconfig from TransIP
- Verify KUBECONFIG environment variable is set
- Check local network/VPN connection

---

## Node Scaling Procedure

Since TransIP does not offer Terraform-managed node scaling, use this manual procedure:

### Scale Up (Add Nodes)

1. Login to TransIP Control Panel
2. Navigate to: Cluster → Node Pools → `app-pool`
3. Click **"Scale"** or **"Edit Node Count"**
4. Increase count (e.g., 3 → 5)
5. Click **"Save"** or **"Update"**
6. Wait 5-10 minutes for new nodes to provision
7. Verify: `kubectl get nodes`
8. Document change in cluster documentation

**When to scale up**:
- CPU usage consistently > 70%
- Memory usage consistently > 75%
- Pods pending due to insufficient resources
- Planned traffic spike (e.g., Black Friday)

### Scale Down (Remove Nodes)

⚠️ **CAUTION**: Ensure workloads can be rescheduled

1. Cordon nodes to prevent new pods:
   ```bash
   kubectl cordon <node-name>
   ```

2. Drain nodes safely:
   ```bash
   kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
   ```

3. In TransIP Control Panel, decrease node count
4. Wait for nodes to be removed
5. Verify: `kubectl get nodes`
6. Document change

**When to scale down**:
- Sustained low resource usage (< 40% CPU, < 50% memory)
- Cost optimization needed
- After traffic spike subsides

---

## Appendix: Cluster Deletion Procedure

⚠️ **DANGER ZONE**: This permanently deletes the cluster

**Use case**: Disaster recovery test, environment decommission

### Prerequisites

- [ ] Database backups verified
- [ ] Velero backup completed
- [ ] Team approval obtained
- [ ] Dependent services migrated

### Deletion Steps

1. **Delete Terraform-managed resources first**:
   ```bash
   cd terraform/environments/production-transip
   terraform destroy
   ```

2. **Delete cluster via TransIP Control Panel**:
   - Navigate to: Services → Kubernetes → `webshop-prod`
   - Click **"Delete Cluster"**
   - Confirm deletion (type cluster name)
   - Click **"Permanently Delete"**

3. **Clean up local kubeconfig**:
   ```bash
   rm ~/.kube/transip-webshop-prod.yaml
   ```

4. **Update documentation**:
   - Mark cluster as "Deleted" in `docs/clusters/webshop-prod.md`
   - Add deletion date and reason

**Recovery Time** (if needed): 2-4 hours to reprovision + restore

---

## Related Documentation

- **[TransIP Infrastructure as Code Guide](../TRANSIP_INFRASTRUCTURE_AS_CODE.md)** - Overall IaC strategy
- **[Production TransIP Terraform README](../../terraform/environments/production-transip/README.md)** - Terraform usage
- **[Node Scaling Guide](transip-node-scaling.md)** - Detailed scaling procedures
- **[Disaster Recovery Procedures](disaster-recovery.md)** - Backup and restore

---

**Runbook Version**: 1.0  
**Last Updated**: 2025-12-27  
**Maintainer**: Platform Engineering Team  
**Review Cycle**: Quarterly  

**Changelog**:
- 2025-12-27: Initial version for production use
