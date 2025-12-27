# TransIP Production Environment - Terraform Configuration

This directory contains Terraform configuration for managing **in-cluster resources** on a TransIP Kubernetes cluster using the **Hybrid IaC approach**.

## Overview

TransIP does not provide a Terraform provider for Kubernetes cluster lifecycle management (create/delete cluster, manage node pools). This configuration uses a **hybrid approach**:

1. **Manual**: Cluster provisioning via TransIP Control Panel (documented in runbook)
2. **Terraform**: All in-cluster resources (namespaces, RBAC, platform components, DNS)
3. **GitOps**: Application deployments via ArgoCD

## Prerequisites

### 1. TransIP Kubernetes Cluster

The cluster must be provisioned manually before running Terraform. Follow the runbook:

📖 **[TransIP Cluster Provisioning Runbook](../../../docs/runbooks/transip-cluster-provisioning.md)**

**Expected cluster configuration**:
- Name: `webshop-prod`
- Region: Amsterdam (`ams1`)
- Kubernetes Version: 1.28 (N-1 for stability)
- High Availability: Enabled
- Node Pools:
  - System pool: 2 nodes (4 vCPU, 8GB RAM)
  - Application pool: 3-6 nodes (4 vCPU, 16GB RAM)

### 2. Tools Installation

```bash
# Terraform >= 1.6.0
terraform version

# kubectl
kubectl version --client

# Helm (optional, for manual operations)
helm version
```

### 3. Credentials & Access

#### Kubeconfig
Retrieve from TransIP cluster and store securely:

```bash
# Download from TransIP Control Panel
# Save to: ~/.kube/transip-webshop-prod.yaml
chmod 600 ~/.kube/transip-webshop-prod.yaml

# Test connection
export KUBECONFIG=~/.kube/transip-webshop-prod.yaml
kubectl get nodes
```

**Security**: Store kubeconfig in secrets manager (Vault, 1Password, AWS Secrets Manager)

#### TransIP API Key
Generate via TransIP Control Panel → API Settings:

```bash
# Save private key to file
vim ~/.transip/api-key.pem
chmod 600 ~/.transip/api-key.pem

# Or set as environment variable
export TF_VAR_transip_private_key=$(cat ~/.transip/api-key.pem)
```

### 4. Remote State Backend

Configure S3-compatible backend for state storage:

**Options**:
1. **DigitalOcean Spaces** (recommended for EU data residency)
2. **AWS S3** (global, mature)
3. **MinIO** (self-hosted, open-source)

**Setup** (DigitalOcean Spaces example):
```bash
# Create Spaces bucket
doctl spaces create kubecompass-terraform-state --region ams3

# Configure credentials
export AWS_ACCESS_KEY_ID="your-spaces-key"
export AWS_SECRET_ACCESS_KEY="your-spaces-secret"
```

Update `backend.tf` with your configuration.

## Usage

### Initial Setup

1. **Copy example variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   vim terraform.tfvars  # Fill in your values
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review plan**:
   ```bash
   terraform plan -out=tfplan
   ```

4. **Apply configuration**:
   ```bash
   terraform apply tfplan
   ```

### Deployment Order

Terraform automatically manages dependencies, but be aware:

1. **Phase 1**: Namespaces, storage classes, RBAC
2. **Phase 2**: NGINX Ingress Controller (creates LoadBalancer)
3. **Phase 3**: cert-manager, External Secrets Operator
4. **Phase 4**: ArgoCD, Prometheus/Grafana (require ingress)
5. **Phase 5**: DNS records (require LoadBalancer IP)

**First deployment** may take 10-15 minutes for all Helm releases to become ready.

### Updating Configuration

```bash
# Make changes to .tf files
vim main.tf

# Review changes
terraform plan

# Apply if satisfied
terraform apply
```

### Destroying Resources

⚠️ **WARNING**: This will delete all in-cluster resources, but NOT the cluster itself.

```bash
terraform destroy
```

To delete the cluster, use TransIP Control Panel.

## Configuration Files

| File | Purpose |
|------|---------|
| `main.tf` | Main configuration (namespaces, Helm releases, DNS) |
| `variables.tf` | Input variables with validation |
| `backend.tf` | Remote state backend configuration |
| `terraform.tfvars.example` | Example values (copy to `terraform.tfvars`) |
| `outputs.tf` | Output values (URLs, IPs, etc.) |

## What is Managed by Terraform?

✅ **Managed**:
- Kubernetes namespaces
- Storage classes
- RBAC (service accounts, role bindings)
- Network policies
- Platform components (ArgoCD, Prometheus, Grafana, cert-manager)
- DNS records (via TransIP provider)

❌ **NOT Managed** (Manual via TransIP):
- Cluster creation/deletion
- Node pools (create, scale, delete)
- Kubernetes version upgrades
- Control plane configuration

## Secrets Management

**DO NOT** store secrets in Terraform code or state.

### Recommended Approach

1. **terraform.tfvars**: Store in secrets manager, never commit to Git
2. **Kubeconfig**: Retrieve dynamically from secrets manager
3. **Application secrets**: Use External Secrets Operator to sync from Vault/cloud KMS

### Example: Using 1Password

```bash
# Store terraform.tfvars in 1Password
op create document terraform.tfvars --vault infrastructure

# Retrieve for use
op read "op://infrastructure/terraform.tfvars" > terraform.tfvars

# Run Terraform
terraform apply

# Clean up
rm terraform.tfvars
```

## Troubleshooting

### Issue: "kubeconfig file does not exist"

**Solution**: Ensure kubeconfig is downloaded from TransIP and path is correct:
```bash
export KUBECONFIG=~/.kube/transip-webshop-prod.yaml
kubectl get nodes  # Verify connection
```

### Issue: "Helm release failed"

**Cause**: Helm chart deployment timeout or resource constraints

**Solution**:
```bash
# Check Helm release status
helm list -A

# Get release details
helm status <release-name> -n <namespace>

# Check pod status
kubectl get pods -n <namespace>

# View pod logs
kubectl logs <pod-name> -n <namespace>
```

### Issue: "DNS record creation failed"

**Cause**: TransIP API authentication issue or domain not found

**Solution**:
```bash
# Verify TransIP API key
terraform console
> var.transip_private_key  # Should show key content

# Check domain exists in TransIP account
# Visit TransIP Control Panel → Domains
```

### Issue: "LoadBalancer IP not available"

**Cause**: NGINX Ingress Controller not ready yet

**Solution**:
```bash
# Check ingress controller status
kubectl get svc -n ingress-nginx

# Wait for EXTERNAL-IP to be assigned
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress[0].ip}' \
  service/ingress-nginx-controller -n ingress-nginx --timeout=300s

# Re-run Terraform
terraform apply
```

## Monitoring & Validation

### Post-Deployment Checklist

```bash
# 1. Verify all namespaces created
kubectl get namespaces

# 2. Check Helm releases
helm list -A

# 3. Verify LoadBalancer IP assigned
kubectl get svc -n ingress-nginx

# 4. Test DNS records
dig webshop.example.nl
dig argocd.webshop.example.nl
dig grafana.webshop.example.nl

# 5. Access ArgoCD UI
open https://argocd.webshop.example.nl

# 6. Access Grafana UI
open https://grafana.webshop.example.nl

# 7. Check cert-manager certificates
kubectl get certificates -A

# 8. Verify network policies
kubectl get networkpolicies -n production
```

### Terraform Outputs

View deployment information:
```bash
terraform output

# Example output:
# cluster_name = "webshop-prod"
# ingress_ip = "203.0.113.42"
# argocd_url = "https://argocd.webshop.example.nl"
# grafana_url = "https://grafana.webshop.example.nl"
```

## Maintenance

### Regular Tasks

1. **Terraform provider updates** (monthly):
   ```bash
   terraform init -upgrade
   terraform plan
   ```

2. **Helm chart updates** (quarterly):
   ```bash
   # Update versions in main.tf
   # Test in staging first
   terraform plan
   terraform apply
   ```

3. **State backup** (weekly):
   ```bash
   # State is automatically versioned in S3 backend
   # Verify backups exist:
   aws s3 ls s3://kubecompass-terraform-state/transip/production/
   ```

### Disaster Recovery

**Scenario**: Complete cluster loss

**Recovery steps**:
1. Provision new TransIP cluster (follow runbook)
2. Update kubeconfig path if needed
3. Run `terraform apply` (recreates all resources)
4. Restore application data from backups (Velero, database backups)

**Time to recover**: 2-4 hours

## Cost Estimation

**TransIP Kubernetes cluster** (manual, not in Terraform):
- Control plane: €X/month (included in TransIP pricing)
- 2 system nodes (4 vCPU, 8GB): ~€Y/month
- 3-6 app nodes (4 vCPU, 16GB): ~€Z/month
- LoadBalancer: €A/month

**Storage** (managed by Terraform):
- Prometheus (50GB SSD): ~€B/month
- Grafana (10GB SSD): ~€C/month
- Application data: Variable

**Total estimated**: €X + €Y + €Z + €A + €B + €C = ~€150-300/month (adjust based on TransIP pricing)

## Related Documentation

- **[TransIP Infrastructure as Code Guide](../../../docs/TRANSIP_INFRASTRUCTURE_AS_CODE.md)** - Complete IaC strategy
- **[TransIP Cluster Provisioning Runbook](../../../docs/runbooks/transip-cluster-provisioning.md)** - Manual cluster setup
- **[Layer 1 Tool Selection](../../../LAYER_1_WEBSHOP_CASE.md)** - Architecture decisions
- **[Decision Rules](../../../DECISION_RULES.md)** - Provider selection criteria

## Support

- **TransIP Support**: https://www.transip.nl/support
- **TransIP API Docs**: https://api.transip.nl/rest/docs.html
- **Terraform Kubernetes Provider**: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
- **Helm Charts**: https://artifacthub.io/

---

**Last Updated**: 2025-12-27  
**Terraform Version**: >= 1.6.0  
**Kubernetes Version**: 1.28  
**Maintainer**: Platform Engineering Team
