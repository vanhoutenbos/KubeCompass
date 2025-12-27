# Terraform Infrastructure - Webshop Kubernetes Migration

This directory contains Infrastructure as Code (IaC) for provisioning and managing the Kubernetes cluster and related infrastructure for the Dutch webshop migration.

## Overview

**Purpose**: Provision managed Kubernetes cluster with EU-based provider, following Layer 0 principles of vendor independence and reproducibility.

**Provider**: Designed for managed Kubernetes (DigitalOcean, Scaleway, OVHcloud, TransIP) - can be adapted to any provider.

## Directory Structure

```
terraform/
├── modules/              # Reusable Terraform modules
│   ├── kubernetes-cluster/   # Kubernetes cluster provisioning
│   ├── networking/           # VPC, subnets, Cilium CNI
│   └── storage/              # Storage classes, CSI driver
├── environments/         # Environment-specific configurations
│   ├── dev/
│   ├── staging/
│   └── production/
└── README.md
```

## Prerequisites

1. **Terraform Installation**: Version >= 1.6.0
2. **Cloud Provider Credentials**: Configure based on selected provider
3. **Remote State Backend**: S3-compatible storage (MinIO, AWS S3, DigitalOcean Spaces)
4. **Team Access**: Ensure all team members have state backend access

## State Management

**Remote Backend**: All environments use remote state storage for:
- Team collaboration
- State locking (prevents concurrent modifications)
- State versioning and backup
- Disaster recovery

**Configuration**: See `environments/*/backend.tf` for backend setup.

## Usage

### Initialize Environment

```bash
cd environments/dev
terraform init
```

### Plan Changes

```bash
terraform plan -out=tfplan
```

### Apply Changes

```bash
terraform apply tfplan
```

### Destroy (Use with caution!)

```bash
terraform destroy
```

## Environments

### Development (dev)
- **Purpose**: Feature development and testing
- **Resources**: Minimal node pools, auto-scaling disabled
- **Updates**: Automatic, no approval required

### Staging
- **Purpose**: Pre-production testing, integration tests
- **Resources**: Production-like sizing
- **Updates**: Automatic from main branch

### Production
- **Purpose**: Live customer traffic
- **Resources**: Full node pools with auto-scaling
- **Updates**: Manual approval required

## Kubernetes Cluster Configuration

### Node Pools

**System Pool** (control plane workloads):
- Size: 2-4 vCPU, 8-16GB RAM
- Nodes: 2 (high availability)
- Taints: `node-role.kubernetes.io/control-plane=true:NoSchedule`

**Application Pool** (application workloads):
- Size: 4-8 vCPU, 16-32GB RAM
- Nodes: 3 (minimum for HA)
- Auto-scaling: Min 3, Max 6
- No taints (general workload)

### Versioning Strategy

- **Version**: N-1 (one version behind latest stable for stability)
- **Security Patches**: Applied immediately
- **Feature Upgrades**: Quarterly review and upgrade
- **Testing**: Always test upgrades in dev → staging → production

## Network Configuration

### CNI: Cilium

Cilium is configured via Terraform and provides:
- **eBPF-based networking**: High performance L3/L4/L7
- **Network Policies**: L3/L4/L7 policy enforcement
- **Observability**: Hubble for flow visibility
- **Multi-cluster**: Ready for future multi-region

### Ingress

- **Controller**: NGINX Ingress Controller
- **SSL/TLS**: cert-manager with Let's Encrypt
- **Load Balancer**: Cloud provider managed LB

## Storage

### Persistent Storage
- **CSI Driver**: Cloud provider CSI driver
- **Storage Classes**: 
  - `standard`: Default, balanced performance
  - `fast`: SSD-backed for databases
  - `backup`: For Velero and backups

## Security

### Secrets Management
- **NO secrets in Terraform state**
- Use External Secrets Operator to sync from Vault/cloud KMS
- Terraform only provisions infrastructure, not sensitive data

### RBAC
- Minimal IAM permissions for Terraform service account
- Cluster RBAC managed via Kubernetes manifests (not Terraform)

## Maintenance

### Regular Updates
- **Terraform Provider Updates**: Monthly review
- **Module Updates**: Quarterly review
- **Kubernetes Version**: Quarterly upgrade cycle

### State Backup
- Remote state is automatically versioned
- Additional backup: Weekly export to separate storage

## Troubleshooting

### State Lock Issues
```bash
# Remove stale lock (only if confirmed no other apply is running)
terraform force-unlock <LOCK_ID>
```

### Provider Authentication
```bash
# Verify provider credentials
terraform providers
```

### Import Existing Resources
```bash
terraform import <resource_type>.<name> <resource_id>
```

## Open Questions for Implementation

1. **Which managed Kubernetes provider?**
   - Options: DigitalOcean, Scaleway, OVHcloud, TransIP
   - Criteria: EU datacenter, SLA, pricing, support

2. **Kubernetes version strategy?**
   - N-1 stable?
   - Upgrade frequency: quarterly?

3. **Multi-region strategy?**
   - Single region initially?
   - Multi-region architecture for future?

4. **Resource sizing?**
   - Traffic patterns?
   - Peak load expectations?

5. **Backup retention?**
   - How long to keep cluster backups?
   - Compliance requirements?

## Layer 0 Alignment

This Terraform implementation directly addresses Layer 0 requirements:

- ✅ **Vendor Independence**: Standard Kubernetes API, reproducible across providers
- ✅ **Infrastructure as Code**: Version-controlled, reviewable, reproducible
- ✅ **Team Collaboration**: Remote state with locking
- ✅ **Security by Design**: Minimal permissions, no secrets in code
- ✅ **Disaster Recovery**: State backup, documented restore procedures

## References

- [Layer 0 Foundation](../LAYER_0_WEBSHOP_CASE.md)
- [Layer 1 Tool Selection](../LAYER_1_WEBSHOP_CASE.md)
- [Terraform Documentation](https://www.terraform.io/docs)
