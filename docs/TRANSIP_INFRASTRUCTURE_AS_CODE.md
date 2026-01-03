# TransIP & Infrastructure as Code: Challenges and Solutions

**Target Audience**: Platform Engineers, DevOps Teams  
**Context**: Dutch webshop migration case with TransIP Kubernetes  
**Status**: Practical Guide  

---

## 🚀 Quick Start

**Nieuw bij TransIP Kubernetes?** Start hier:

👉 **[TransIP Quick Start Guide](TRANSIP_QUICK_START.md)** - 30-minute getting started guide

Dit document bevat de complete implementatie details. Voor een snelle overview, zie de Quick Start Guide.

---

## Executive Summary

TransIP wordt aanbevolen als top keuze voor Nederlandse organisaties (GDPR, support, betrouwbaarheid), maar heeft **geen native Terraform provider voor Kubernetes cluster lifecycle management**. Dit document beschrijft hoe je toch Infrastructure as Code (IaC) principes kunt toepassen en hoe je omgaat met uitdagingen zoals node scaling.

### TL;DR

✅ **Wat WEL kan met IaC bij TransIP:**
- Alle Kubernetes resources (deployments, services, ingress) via Terraform Kubernetes provider
- DNS configuratie via TransIP Terraform provider
- GitOps workflow (ArgoCD/Flux) voor applicatie deployments
- Reproduceerbare cluster configuratie via versioned manifests

❌ **Wat NIET kan met Terraform bij TransIP:**
- Kubernetes cluster provisioning (create/delete)
- Node pool management (scaling, resizing)
- Kubernetes versie upgrades

🔧 **Oplossing: Hybrid IaC Approach**
- Cluster lifecycle: TransIP Control Panel / API + dokumentatie
- In-cluster resources: Terraform Kubernetes provider + GitOps
- Node scaling: Manual/UI of custom scripts met TransIP API

---

## 1. Het Terraform Provider Landschap

### 1.1 Providers met Native Kubernetes Support

| Provider | Terraform Provider | Cluster Lifecycle | Node Pools | Autoscaling | EU Datacenter |
|----------|-------------------|-------------------|------------|-------------|---------------|
| **DigitalOcean** | ✅ Officieel | ✅ Ja | ✅ Ja | ✅ Ja | ⚠️ Amsterdam (maar US bedrijf) |
| **Scaleway** | ✅ Officieel | ✅ Ja | ✅ Ja | ✅ Ja | ✅ Paris, Amsterdam |
| **OVHcloud** | ✅ Officieel | ✅ Ja | ✅ Ja | ✅ Ja | ✅ Meerdere EU locaties |
| **Azure (AKS)** | ✅ Officieel | ✅ Ja | ✅ Ja | ✅ Ja | ✅ West/North Europe |
| **AWS (EKS)** | ✅ Officieel | ✅ Ja | ✅ Ja | ✅ Ja | ✅ eu-west-1, eu-central-1 |
| **GCP (GKE)** | ✅ Officieel | ✅ Ja | ✅ Ja | ✅ Ja | ✅ europe-west4 |
| **TransIP** | ⚠️ Alleen DNS/VPS | ❌ Nee | ❌ Nee | ❌ Nee | ✅ Nederland |

**Conclusie**: TransIP is uitstekend voor GDPR/Nederlandse support, maar IaC voor cluster lifecycle vereist andere aanpak.

### 1.2 TransIP Terraform Provider Status

**Beschikbaar** (community-maintained):
```hcl
terraform {
  required_providers {
    transip = {
      source  = "aequitas/transip"
      version = "~> 0.7"
    }
  }
}

# TransIP provider ondersteunt:
# - DNS records (A, AAAA, CNAME, MX, TXT, etc.)
# - VPS instances
# - Domains
```

**Niet beschikbaar**:
- `transip_kubernetes_cluster` resource
- `transip_kubernetes_node_pool` resource
- Kubernetes versie management

---

## 2. Hybrid IaC Strategie voor TransIP

### 2.1 Architectuur: Drie Lagen

```
┌─────────────────────────────────────────────────────┐
│ Priority 1: Cluster Lifecycle (Manual/API)            │
│ - Cluster provisioning via TransIP Control Panel   │
│ - Node pool creation & initial sizing              │
│ - Kubernetes version selection                     │
│ Tool: TransIP UI + API scripts (documented)        │
└─────────────────────────────────────────────────────┘
                      ↓ kubeconfig
┌─────────────────────────────────────────────────────┐
│ Priority 2: Infrastructure Resources (Terraform)      │
│ - DNS records (TransIP provider)                   │
│ - Kubernetes namespaces, RBAC, storage classes     │
│ - Platform components (via Terraform K8s provider) │
│ Tool: Terraform with Kubernetes + TransIP providers│
└─────────────────────────────────────────────────────┘
                      ↓ platform ready
┌─────────────────────────────────────────────────────┐
│ Layer 3: Application Deployments (GitOps)          │
│ - Application manifests in Git                     │
│ - Continuous deployment via ArgoCD                 │
│ Tool: GitOps (ArgoCD/Flux)                         │
└─────────────────────────────────────────────────────┘
```

### 2.2 Implementatie Details

#### Priority 1: Cluster Provisioning (Documented Manual Process)

**Aanpak**: Documenteer cluster creation als reproduceerbaar proces

**Voorbeeld: `docs/runbooks/transip-cluster-provisioning.md`**
```markdown
# TransIP Kubernetes Cluster Provisioning

## Prerequisites
- TransIP account met Kubernetes toegang
- API key (voor toekomstige automation)

## Production Cluster Setup

1. **Login TransIP Control Panel**
   - Navigate to: Kubernetes → Create Cluster

2. **Cluster Configuration**
   - Name: `webshop-prod`
   - Region: `ams1` (Amsterdam)
   - Kubernetes Version: `1.28` (N-1 voor stabiliteit)
   - High Availability: Enabled

3. **Node Pool: System**
   - Name: `system-pool`
   - Size: `Standard-4vcpu-8gb` (4 vCPU, 8GB RAM)
   - Count: 2 nodes (HA)
   - Labels: `node-role=system`

4. **Node Pool: Application**
   - Name: `app-pool`
   - Size: `Standard-4vcpu-16gb` (4 vCPU, 16GB RAM)
   - Count: 3 nodes (initial)
   - Labels: `node-role=application`

5. **Download Kubeconfig**
   - Save to: `~/.kube/transip-webshop-prod.yaml`
   - Set permissions: `chmod 600`

6. **Store in Secrets Manager**
   - Upload kubeconfig to Vault/1Password
   - Path: `infrastructure/kubernetes/transip-prod-kubeconfig`

## Validation
```bash
export KUBECONFIG=~/.kube/transip-webshop-prod.yaml
kubectl get nodes
# Expected: 5 nodes (2 system + 3 app)
```
```

**Voordelen**:
- ✅ Reproduceerbaar proces (iedereen kan cluster provisionen)
- ✅ Versioned in Git (runbook updates tracked)
- ✅ Onboarding documentatie voor nieuwe teamleden
- ✅ Disaster recovery procedure

**Nadelen**:
- ⚠️ Manual execution vereist
- ⚠️ Geen automated testing van provisioning
- ⚠️ State drift mogelijk (console changes niet tracked)

#### Priority 2: Infrastructure as Code (Terraform)

**Aanpak**: Gebruik Terraform Kubernetes provider voor alles IN het cluster

**Voorbeeld: `terraform/environments/production/main.tf`**
```hcl
terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    transip = {
      source  = "aequitas/transip"
      version = "~> 0.7"
    }
  }
  
  backend "s3" {
    bucket = "kubecompass-terraform-state"
    key    = "transip/production/terraform.tfstate"
    region = "eu-west-1"
  }
}

# Kubernetes Provider - gebruik kubeconfig van TransIP
provider "kubernetes" {
  config_path = var.kubeconfig_path  # From secrets manager
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

# TransIP Provider - DNS management
provider "transip" {
  account_name = var.transip_account
  private_key  = var.transip_api_key
}

# DNS Records voor cluster
resource "transip_dns_record" "webshop_prod" {
  domain  = "webshop.example.nl"
  name    = "@"
  type    = "A"
  content = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.ip
  ttl     = 300
}

# Namespaces
resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
    labels = {
      environment = "production"
      managed-by  = "terraform"
    }
  }
}

# Storage Classes (if not default)
resource "kubernetes_storage_class" "fast_ssd" {
  metadata {
    name = "fast-ssd"
  }
  storage_provisioner = "csi.transip.nl"
  parameters = {
    type = "fast-ssd"
  }
}

# Platform Components via Helm
module "argocd" {
  source = "../../modules/argocd"
  
  namespace        = "argocd"
  version          = "5.51.4"
  admin_password   = var.argocd_admin_password
  ingress_hostname = "argocd.webshop.example.nl"
}

module "prometheus" {
  source = "../../modules/prometheus"
  
  namespace = "monitoring"
  storage_size = "50Gi"
  storage_class = "fast-ssd"
}
```

**Voordelen**:
- ✅ Volledig reproduceerbaar (alles in code)
- ✅ Version control (Git history)
- ✅ Code review process (PR approvals)
- ✅ Automated deployment (CI/CD pipeline)
- ✅ State management (remote backend)

#### Layer 3: GitOps (ArgoCD)

**Aanpak**: Standaard GitOps workflow (provider-agnostic)

Dit blijft ongewijzigd - ArgoCD werkt identiek bij elke Kubernetes provider.

---

## 3. Node Scaling bij TransIP

### 3.1 Uitdaging

TransIP Kubernetes ondersteunt **geen native Cluster Autoscaler** zoals GKE/EKS/AKS. Node scaling moet handmatig of via API gebeuren.

### 3.2 Oplossingen

#### Optie A: Manual Scaling (Aanbevolen voor start)

**Process**:
1. Monitor resource usage via Prometheus/Grafana
2. Set alerts voor hoog CPU/memory gebruik (> 80%)
3. Bij alert: login TransIP console, adjust node count
4. Document in runbook

**Voordelen**:
- ✅ Simpel, geen extra tooling
- ✅ Geen risk van onverwachte kosten
- ✅ Learning opportunity (team leert resource patterns)

**Nadelen**:
- ⚠️ Manual intervention vereist
- ⚠️ Slow response time (minutes vs. seconds)

**When suitable**:
- Predictable traffic patterns
- Team has time for monitoring
- Budget predictability more important than auto-scaling

#### Optie B: API-based Scaling Script

**Aanpak**: Custom script die TransIP API gebruikt voor node scaling

**Voorbeeld: `scripts/scale-transip-nodes.sh`**
```bash
#!/bin/bash
# Scale TransIP Kubernetes node pool via API

CLUSTER_NAME="webshop-prod"
NODE_POOL="app-pool"
DESIRED_COUNT=$1

# TransIP API call (pseudo-code, check TransIP API docs)
curl -X PATCH https://api.transip.nl/v6/kubernetes/${CLUSTER_NAME}/node-pools/${NODE_POOL} \
  -H "Authorization: Bearer ${TRANSIP_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"node_count\": ${DESIRED_COUNT}}"

echo "Scaled ${NODE_POOL} to ${DESIRED_COUNT} nodes"
```

**Trigger opties**:
1. **Manual**: `./scale-transip-nodes.sh 5`
2. **Scheduled**: Cron job voor predictable spikes (bijv. Black Friday)
3. **Alert-based**: Prometheus AlertManager triggers script

**Voordelen**:
- ✅ Sneller dan manual console access
- ✅ Scriptable (kan in runbook automation)
- ✅ Auditeerbaar (logs van scaling events)

**Nadelen**:
- ⚠️ Custom code om te onderhouden
- ⚠️ Geen smart scheduling (geen pod-pending detection)
- ⚠️ Geen scale-down logic (manual cleanup vereist)

#### Optie C: Event-driven Scaling (Advanced)

**Aanpak**: Kubernetes event watcher + TransIP API

**Architectuur**:
```
Kubernetes Metrics 
    ↓
Custom Controller (in-cluster)
    ↓
Detects pod pending / high resource usage
    ↓
Calls TransIP API
    ↓
Scales node pool
```

**Implementatie**: Custom Kubernetes operator (Go/Python) die:
1. Watches voor pending pods
2. Checks node resource usage
3. Calls TransIP API voor scaling
4. Implements cool-down logic

**Voordelen**:
- ✅ Near-native autoscaling experience
- ✅ Intelligent scaling decisions
- ✅ Scale-up én scale-down

**Nadelen**:
- ❌ Significant development effort
- ❌ Operational complexity (extra component om te monitoren)
- ❌ TransIP API rate limits can be a problem

**When suitable**:
- Team has Golang/Python expertise
- Unpredictable, spiky traffic
- Budget for development investment

### 3.3 Aanbeveling per Team Maturity

| Team Maturity | Traffic Pattern | Aanbeveling |
|---------------|----------------|-------------|
| **Beginner** (geen K8s ervaring) | Predictable | **Optie A** (Manual) + monitoring alerts |
| **Intermediate** | Mostly predictable | **Optie A** + scheduled Optie B voor known spikes |
| **Advanced** | Unpredictable/spiky | **Optie B** triggered by alerts, consider Optie C later |

**Voor webshop case (SME, geen K8s ervaring)**: Start met **Optie A** + goede monitoring. Evalueer na 3 maanden of Optie B nodig is.

---

## 4. Vendor Independence bij TransIP

### 4.1 Risico Assessment

**Vraag**: Als TransIP geen Terraform heeft, hoe waarborgen we vendor independence (Priority 0 requirement)?

**Antwoord**: Vendor independence heeft meerdere lagen:

| Laag | TransIP Status | Mitigatie |
|------|----------------|-----------|
| **Kubernetes API** | ✅ Standaard | Applicaties zijn portable (elke K8s provider) |
| **In-cluster resources** | ✅ Terraform K8s provider | Config is portable naar andere provider |
| **Cluster lifecycle** | ❌ Geen Terraform | Documented manual process (runbooks) |
| **Node scaling** | ❌ Geen autoscaler | Manual/scripted (API calls) |

### 4.2 Portability Checklist

**Om binnen 1 kwartaal te kunnen migreren**:

- [x] **Gebruik geen TransIP-specific features**
  - ❌ Geen TransIP-only storage classes (use standard CSI)
  - ❌ Geen TransIP-only networking
  - ✅ Gebruik standaard Kubernetes resources

- [x] **Document cluster setup**
  - ✅ Runbook voor cluster provisioning
  - ✅ Node pool configuratie gedocumenteerd
  - ✅ Kubeconfig backup procedure

- [x] **Alle in-cluster config in Git**
  - ✅ Terraform for namespaces, RBAC, storage
  - ✅ GitOps voor applicaties
  - ✅ Helm charts voor platform components

- [x] **Test disaster recovery**
  - ✅ Velero backups (cluster state)
  - ✅ Database backups (managed DB)
  - ✅ Documented restore procedure

- [x] **Prepare migration path**
  - ✅ Document equivalents bij andere providers
  - ✅ Terraform modules zijn provider-agnostic waar mogelijk
  - ✅ Quarterly review: "Kunnen we binnen 1 week migreren?"

### 4.3 Migration Scenario (TransIP → Scaleway)

**Scenario**: Na 1 jaar wil je naar Scaleway (betere pricing, Terraform support)

**Migratie stappen** (total: 2-4 weken):
1. **Week 1**: Provision Scaleway cluster via Terraform
   ```hcl
   # terraform/environments/production/main.tf
   resource "scaleway_k8s_cluster" "webshop" {
     name    = "webshop-prod"
     version = "1.28"
     cni     = "cilium"
     # ... rest of config
   }
   ```

2. **Week 2**: Deploy platform components (ArgoCD, monitoring)
   - Reuse existing Terraform modules (provider-agnostic)
   - Update DNS to point to new cluster (via Terraform)

3. **Week 3**: Migrate applications
   - GitOps sync naar nieuwe cluster
   - Database migration (managed DB → managed DB)
   - Parallel run (old + new)

4. **Week 4**: Cutover
   - Update DNS (atomic switch)
   - Monitor for 72 hours
   - Decomission TransIP cluster

**Effort**: 2-4 weken voor complete migratie (binnen 1 kwartaal requirement ✅)

---

## 5. Decision Rules Update

### 5.1 Provider Selectie met IaC Criteria

**Update voor DECISION_RULES.md:**

#### Use TransIP unless
**Condition**: Terraform cluster lifecycle automation is **kritisch** requirement (not "nice to have")

**Primary Choice**: TransIP Kubernetes (voor Nederlandse organisaties)

**Priority 0 Rationale**:
- **GDPR Compliance**: Nederlandse datacenter, Nederlandse support
- **Vendor Trust**: Gevestigde Nederlandse provider
- **Pricing**: Transparant, euro-based pricing
- **Kubernetes API**: Standaard (applicaties blijven portable)

**IaC Trade-off**:
- ✅ In-cluster IaC: Fully supported (Terraform Kubernetes provider)
- ⚠️ Cluster lifecycle: Documented manual process (reproducible via runbooks)
- ⚠️ Node scaling: Manual or API scripts (geen native autoscaler)

**Alternative A**: Scaleway
**When**:
- Terraform cluster lifecycle is must-have
- Team heeft capaciteit voor Franse support (if needed)
- Budget voor Terraform automation development > operational manual work

**Alternative B**: OVHcloud
**When**:
- Terraform + EU datacenter both required
- Larger scale (enterprise features)
- Budget allows for slightly higher costs

**Alternative C**: DigitalOcean
**When**:
- Terraform automation is kritisch
- US-based provider acceptabel (datacenter = Amsterdam)
- Prefer English documentation/support

**Decision Logic**:
```javascript
if (gdpr_strict && dutch_support_required && budget_conscious) {
  if (terraform_lifecycle_critical) {
    return "Scaleway or OVHcloud (Terraform + EU)";
  } else {
    return "TransIP (accept manual cluster lifecycle)";
  }
} else if (terraform_automation_priority === "high") {
  return "DigitalOcean or Scaleway";
} else {
  return "TransIP (best for Dutch SMEs)";
}
```

---

## 6. Praktische Implementatie Gids

### 6.1 Folder Structuur

```
infrastructure/
├── docs/
│   └── runbooks/
│       ├── transip-cluster-provisioning.md
│       ├── transip-node-scaling.md
│       └── disaster-recovery.md
├── terraform/
│   ├── modules/
│   │   ├── kubernetes-base/       # Namespaces, RBAC, storage
│   │   ├── argocd/               # GitOps platform
│   │   ├── prometheus/           # Monitoring
│   │   └── dns/                  # TransIP DNS records
│   └── environments/
│       ├── dev/
│       ├── staging/
│       └── production/
├── kubernetes/
│   └── platform/                 # Manifests for GitOps
│       ├── cilium/
│       ├── cert-manager/
│       └── external-secrets/
└── scripts/
    ├── scale-transip-nodes.sh
    └── backup-kubeconfig.sh
```

### 6.2 CI/CD Pipeline Aanpassing

**Voorbeeld: `.github/workflows/terraform-apply.yml`**
```yaml
name: Terraform Apply

on:
  push:
    branches: [main]
    paths:
      - 'terraform/**'

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      # Get kubeconfig from secrets manager (not from Terraform)
      - name: Retrieve kubeconfig
        run: |
          # Vault/1Password CLI to get kubeconfig
          op read "op://infrastructure/transip-prod-kubeconfig" > /tmp/kubeconfig
          chmod 600 /tmp/kubeconfig
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        
      - name: Terraform Init
        run: terraform init
        working-directory: terraform/environments/production
        
      - name: Terraform Plan
        run: terraform plan -out=tfplan
        working-directory: terraform/environments/production
        env:
          KUBECONFIG: /tmp/kubeconfig
          TRANSIP_API_KEY: ${{ secrets.TRANSIP_API_KEY }}
          
      - name: Terraform Apply
        run: terraform apply tfplan
        working-directory: terraform/environments/production
        env:
          KUBECONFIG: /tmp/kubeconfig
          TRANSIP_API_KEY: ${{ secrets.TRANSIP_API_KEY }}
```

### 6.3 Onboarding Checklist (Nieuwe TeamLid)

**Voor nieuwe platform engineer die met TransIP moet werken**:

- [ ] **Week 1: Begrijp de hybrid IaC aanpak**
  - [ ] Lees dit document
  - [ ] Review runbooks in `docs/runbooks/`
  - [ ] Begrijp wat WEL/NIET in Terraform kan

- [ ] **Week 2: Access & Credentials**
  - [ ] TransIP console toegang
  - [ ] TransIP API key aanvragen
  - [ ] Secrets manager toegang (kubeconfig)
  - [ ] Terraform state backend toegang

- [ ] **Week 3: Hands-on (dev environment)**
  - [ ] Provision dev cluster (volg runbook)
  - [ ] Apply Terraform (in-cluster resources)
  - [ ] Deploy test app via GitOps
  - [ ] Test node scaling (manual)

- [ ] **Week 4: Production shadowing**
  - [ ] Observe production deployment
  - [ ] Review monitoring dashboards
  - [ ] Participate in node scaling decision

---

## 7. Veelgestelde Vragen (FAQ)

### Q1: Is TransIP nog steeds een goede keuze zonder Terraform?
**A**: Ja, voor Nederlandse SMEs met GDPR requirements. De voordelen (Nederlandse support, GDPR compliance, betrouwbaarheid) wegen op tegen het gemis van Terraform cluster lifecycle. In-cluster IaC werkt perfect via Kubernetes provider.

### Q2: Kunnen we niet gewoon naar een provider met Terraform support?
**A**: Ja, maar weeg af:
- **Scaleway/OVHcloud**: Terraform support + EU, maar Franse support
- **DigitalOcean**: Terraform support, maar US-based bedrijf (datacenter = EU)
- **Hyperscalers** (AWS/Azure/GCP): Fully Terraform, but more expensive + higher vendor lock-in risk

For the webshop case (Priority 0 constraint: vendor independence, GDPR, budget) TransIP remains valid.

### Q3: How do we automate disaster recovery without Terraform?
**A**: 
1. **Cluster state**: Velero backups (in-cluster, Terraform-managed)
2. **Cluster config**: Gedocumenteerde runbook (version-controlled)
3. **Applications**: GitOps (volledig reproduceerbaar)
4. **Data**: Managed database PITR backups

Test quarterly: "Kunnen we cluster rebuilden binnen 4 uur?"

### Q4: Wat als TransIP later Terraform support krijgt?
**A**: Perfect! Dan migreer je Priority 1 (cluster lifecycle) naar Terraform. Priority 2 (in-cluster) blijft ongewijzigd. Effort: 1-2 dagen om runbook naar Terraform te converteren.

### Q5: Hoe schaal ik tijdens Black Friday zonder autoscaler?
**A**:
1. **Pre-scale** (week ervoor): Handmatig nodes opschalen naar expected capacity
2. **Monitor**: Grafana dashboards + alerts
3. **On-call**: Team member ready om bij te schalen indien nodig
4. **Post-mortem**: Gebruik metrics om volgend jaar beter te voorspellen

### Q6: Is manual node scaling niet "onprofessioneel"?
**A**: Nee. Veel organisaties kiezen bewust tegen autoscaling voor:
- **Kostbaarheid**: Autoscaling kan leiden tot onverwachte kosten
- **Predictability**: Manual scaling = voorspelbare budget
- **Simplicity**: Minder moving parts = minder operationele complexiteit

Voor webshop case (SME, eerste K8s ervaring): manual scaling is **pragmatisch**, niet onprofessioneel.

---

## 8. Conclusion & Recommendations

### For the Webshop Case

**Recommendation**: ✅ **TransIP remains the best choice**, despite Terraform limitations

**Rationale**:
1. **Priority 0 Priorities**:
   - ✅ GDPR compliance (Nederlandse datacenter)
   - ✅ Team maturity (Nederlandse support kritiek)
   - ✅ Vendor independence (K8s API is portable)
   - ✅ Budget (TransIP competitive pricing)

2. **IaC Trade-off is acceptabel**:
   - 80% van IaC werkt perfect (Terraform Kubernetes provider)
   - 20% is documented manual process (reproduceerbaar)
   - Team heeft geen Terraform expertise, learning curve is gelijk

3. **Node Scaling is geen blocker**:
   - Traffic is redelijk predictable (e-commerce)
   - Team kan starten met manual scaling + monitoring
   - Evalueer na 6 maanden of API-based scaling nodig is

### Implementatie Roadmap

**Phase 1: Foundation (Week 1-2)**
- [ ] Provision TransIP cluster (volg runbook)
- [ ] Setup Terraform for in-cluster resources
- [ ] Deploy GitOps (ArgoCD)
- [ ] Setup monitoring (Prometheus/Grafana)

**Phase 2: Operations (Maand 1-3)**
- [ ] Monitor resource usage patterns
- [ ] Document scaling decisions (when/why nodes added)
- [ ] Refine monitoring alerts
- [ ] Test backup/restore procedures

**Phase 3: Optimization (Maand 3-6)**
- [ ] Evaluate: Is manual scaling still acceptable?
- [ ] If needed: Implement API-based scaling (Optie B)
- [ ] Review: Would different provider be better long-term?
- [ ] Decision: Stay with TransIP or migrate?

### Fallback Plan

**Als TransIP toch niet werkt**:
1. **Migrate to Scaleway** (best Terraform + EU alternative)
2. **Effort**: 2-4 weken (binnen 1 kwartaal requirement)
3. **Cost**: Terraform modules zijn grotendeels reusable

---

## 9. Bronnen & Links

### TransIP Resources
- [TransIP Kubernetes Documentation](https://www.transip.nl/vps/kubernetes/)
- [TransIP API Documentation](https://api.transip.nl/rest/docs.html)
- [TransIP Terraform Provider (Community)](https://github.com/aequitas/terraform-provider-transip)

### Alternative Providers (met Terraform)
- [Scaleway Kubernetes](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/k8s_cluster)
- [OVHcloud Kubernetes](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube)
- [DigitalOcean Kubernetes](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_cluster)

### Terraform Kubernetes Provider
- [Official Documentation](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Best Practices](https://www.arthurkoziel.com/managing-kubernetes-resources-in-terraform-kubernetes-provider/)

### Related KubeCompass Docs
- [Priority 0: Foundation](cases/PRIORITY_0_WEBSHOP_CASE.md)
- [Priority 1: Tool Selection](cases/PRIORITY_1_WEBSHOP_CASE.md)
- [Decision Rules](DECISION_RULES.md)
- [Open Questions](OPEN_QUESTIONS.md)

---

**Last Updated**: 2025-12-27  
**Maintainers**: Platform Engineering Team  
**Review Cycle**: Quarterly (check for TransIP Terraform provider updates)
