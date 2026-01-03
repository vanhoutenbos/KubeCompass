# TransIP Kubernetes: Quick Start Guide

**TL;DR**: How to use TransIP Kubernetes with Infrastructure as Code

---

## The Challenge

TransIP is recommended for Dutch SMEs (GDPR, support, pricing) but **lacks native Terraform provider for Kubernetes cluster lifecycle management**.

## The Solution: Hybrid IaC Approach

### 3-Layer Strategy

```
┌─────────────────────────────────────┐
│ Priority 1: Cluster Lifecycle         │
│ Tool: Manual (TransIP Control Panel)│
│ What: Provision cluster, node pools│
│ Doc: runbooks/transip-cluster-      │
│      provisioning.md                │
└─────────────────────────────────────┘
              ↓ kubeconfig
┌─────────────────────────────────────┐
│ Priority 2: In-Cluster Resources       │
│ Tool: Terraform (Kubernetes provider)│
│ What: Namespaces, RBAC, Helm, DNS  │
│ Doc: terraform/environments/        │
│      production-transip/            │
└─────────────────────────────────────┘
              ↓ platform ready
┌─────────────────────────────────────┐
│ Layer 3: Applications               │
│ Tool: GitOps (ArgoCD)               │
│ What: Deploy applications           │
│ Doc: kubernetes/platform/argocd/   │
└─────────────────────────────────────┘
```

---

## Quick Start (30 Minutes)

### Step 1: Provision Cluster (Manual)

📖 Follow: [`docs/runbooks/transip-cluster-provisioning.md`](runbooks/transip-cluster-provisioning.md)

**Result**: 
- Cluster: `webshop-prod` in Amsterdam
- Nodes: 2 system + 3 application
- Kubeconfig: Stored securely

### Step 2: Deploy Platform (Terraform)

📖 Follow: [`terraform/environments/production-transip/README.md`](../terraform/environments/production-transip/README.md)

```bash
cd terraform/environments/production-transip
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Fill in values

terraform init
terraform plan
terraform apply
```

**Result**:
- Namespaces created
- NGINX Ingress deployed
- ArgoCD, Prometheus, Grafana installed
- DNS records configured

### Step 3: Deploy Applications (GitOps)

```bash
# ArgoCD auto-deploys from Git
git push origin main
# Monitor: https://argocd.your-domain.nl
```

---

## What Can/Cannot Be Done

### ✅ Fully Automated (Terraform)

- Kubernetes namespaces
- RBAC (roles, bindings, service accounts)
- Storage classes
- Network policies
- Helm releases (ArgoCD, Prometheus, Grafana, etc.)
- DNS records (via TransIP provider)
- Platform configuration

### ⚠️ Manual Required (Documented)

- Cluster provisioning (create/delete)
- Node pool management (add/remove nodes)
- Kubernetes version upgrades
- Node scaling (no autoscaler)

### 🔄 Hybrid (Manual + Script)

- Node scaling: Manual UI or API scripts
- Backups: Velero (automated) + cluster state (documented)

---

## Node Scaling

### Option 1: Manual (Recommended for Start)

1. Monitor Grafana dashboards
2. Set alerts for >80% CPU/memory
3. Scale via TransIP Control Panel when needed
4. Document scaling decisions

**When**: Predictable traffic, small team

### Option 2: API-Based Scripts

```bash
# Custom script (not included, example)
./scripts/scale-transip-nodes.sh app-pool 5
```

**When**: Frequent scaling, automation valuable

### Option 3: Event-Driven (Advanced)

Build custom Kubernetes operator to call TransIP API

**When**: Unpredictable traffic, large scale

---

## Cost Comparison

### TransIP (Manual Cluster + Terraform)

**Pros**:
- ✅ Best GDPR compliance (NL datacenter)
- ✅ Nederlandse support
- ✅ Predictable pricing
- ✅ 80% of IaC works perfectly

**Cons**:
- ❌ Manual cluster provisioning
- ❌ Manual node scaling

**Monthly Cost**: ~€150-300 (2 system + 3-6 app nodes)

### Alternatives with Full Terraform

**Scaleway**:
- ✅ Full Terraform support
- ✅ EU datacenter (Paris)
- ⚠️ French/English support only
- **Cost**: ~€180-350/month

**OVHcloud**:
- ✅ Full Terraform support
- ✅ Multiple EU datacenters
- ⚠️ More complex pricing
- **Cost**: ~€200-400/month

**DigitalOcean**:
- ✅ Full Terraform support
- ✅ Excellent docs
- ⚠️ US company (datacenter = Amsterdam)
- **Cost**: ~€160-320/month

---

## When to Choose TransIP?

### ✅ Choose TransIP if:

1. **GDPR strict**: Nederlandse datacenter vereist
2. **Support critical**: Team heeft Nederlandse support nodig
3. **Manual acceptable**: Team kan manual cluster provisioning aan
4. **Budget conscious**: Transparante, voorspelbare pricing belangrijk

### ⚠️ Choose Scaleway/OVHcloud if:

1. **Terraform critical**: Full automation vereist
2. **Support language**: Engels/Frans acceptabel
3. **Team mature**: Terraform expertise aanwezig

### ⚠️ Choose DigitalOcean if:

1. **Documentation**: Excellent docs critical
2. **Community**: Large community belangrijk
3. **US company**: Acceptabel (datacenter blijft EU)

---

## Key Documentation

### Core Guides

1. **[TransIP IaC Guide](TRANSIP_INFRASTRUCTURE_AS_CODE.md)** (24KB)
   - Complete strategy and implementation
   - Provider comparison
   - Node scaling approaches
   - FAQ and troubleshooting

2. **[Cluster Provisioning Runbook](runbooks/transip-cluster-provisioning.md)** (12KB)
   - Step-by-step manual cluster setup
   - Validation checklist
   - Node scaling procedures

3. **[Terraform Production Example](../terraform/environments/production-transip/README.md)** (9KB)
   - Complete Terraform configuration
   - Usage instructions
   - Troubleshooting guide

### Related Documentation

- **[Decision Rules](DECISION_RULES.md)** - Provider selection criteria
- **[Open Questions](OPEN_QUESTIONS.md)** - TransIP considerations
- **[Priority 1 Webshop Case](cases/PRIORITY_1_WEBSHOP_CASE.md)** - Architecture decisions
- **[Webshop Unified Case](../cases/webshop/WEBSHOP_UNIFIED_CASE.md)** - Complete case study

---

## Common Questions

### Q: Is manual cluster provisioning "unprofessional"?

**A**: No. Many organizations choose manual provisioning for:
- Cost control (no unexpected autoscaling costs)
- Simplicity (fewer moving parts)
- Predictability (controlled changes)

For SME with predictable traffic: **pragmatic choice**.

### Q: Can we migrate away from TransIP later?

**A**: Yes, within 1 quarter (Priority 0 requirement):
1. Applications are portable (standard K8s)
2. In-cluster config is in Terraform (reproducible)
3. Cluster state in Velero backups
4. Migration time: 2-4 weeks

### Q: What if TransIP adds Terraform support?

**A**: Perfect! Convert Priority 1 runbook to Terraform:
- Effort: 1-2 days
- Priority 2 stays unchanged
- Huge improvement

### Q: How do we handle Black Friday traffic spikes?

**A**: Two approaches:
1. **Pre-scale**: Week before, manually scale to 6 nodes
2. **On-call**: Team ready to scale during event
3. **Post-mortem**: Use metrics to improve next year

Both work for predictable annual events.

---

## Success Metrics

After implementing TransIP hybrid IaC:

- [ ] Cluster provisioned in < 45 minutes
- [ ] All in-cluster resources managed by Terraform
- [ ] Applications deployed via GitOps (ArgoCD)
- [ ] DNS automatically updated
- [ ] Team can reprovision cluster from runbook
- [ ] Node scaling documented and tested
- [ ] Disaster recovery tested (quarterly)

---

## Support & Resources

- **TransIP Support**: https://www.transip.nl/support
- **TransIP API**: https://api.transip.nl/rest/docs.html
- **Terraform Kubernetes Provider**: https://registry.terraform.io/providers/hashicorp/kubernetes
- **TransIP Community Provider**: https://github.com/aequitas/terraform-provider-transip (DNS/VPS only)

---

**Last Updated**: 2025-12-27  
**Version**: 1.0  
**Maintainer**: Platform Engineering Team  

**Feedback**: Found an issue or improvement? Open an issue on GitHub!
