# Cloud Provider Guides

Deze directory bevat provider-specifieke guides, quirks, en migration playbooks voor verschillende Kubernetes managed services.

---

## Doel

**Provider-agnostisch blijven** terwijl je provider-specifieke realiteiten erkent:
- Documenteer verschillen tussen providers
- Maak abstractions waar mogelijk
- Geef migration paths tussen providers
- Identificeer lock-in risks en mitigations

---

## Structuur

```
providers/
├── aws/                    # Amazon Web Services (EKS)
├── azure/                  # Microsoft Azure (AKS)
├── gcp/                    # Google Cloud Platform (GKE)
├── digitalocean/           # DigitalOcean (DOKS)
├── comparison-matrix.md    # Cross-provider feature comparison
└── README.md              # This file
```

---

## Per Provider

Elke provider directory bevat:

### 1. Setup Guide
- Cluster provisioning
- IaC templates (Terraform, Pulumi)
- Authentication & authorization setup
- Networking configuration
- Storage classes & CSI drivers

### 2. Quirks & Gotchas
- Provider-specific limitations
- Default behaviors die afwijken
- Common pitfalls
- Performance characteristics
- Cost surprises

### 3. Migration Guide
- Migration FROM this provider
- Migration TO this provider
- Data export/import procedures
- Downtime minimization strategies
- Validation checklists

---

## Provider Comparison Matrix

**Zie**: [comparison-matrix.md](comparison-matrix.md) voor volledige vergelijking.

### Quick Overview

| Feature | AWS EKS | Azure AKS | GCP GKE | DO DOKS |
|---------|---------|-----------|---------|---------|
| **Managed Control Plane** | ✅ | ✅ | ✅ | ✅ |
| **Node Auto-scaling** | ✅ | ✅ | ✅ | ⚠️ Manual |
| **Private Clusters** | ✅ | ✅ | ✅ | ❌ |
| **Windows Nodes** | ✅ | ✅ | ✅ | ❌ |
| **Integrated Registry** | ECR | ACR | GCR/AR | DOCR |
| **Native Load Balancer** | ALB/NLB | Azure LB | GCP LB | DO LB |
| **Cost (Basic 3-node)** | ~$150/mo | ~$140/mo | ~$160/mo | ~$60/mo |
| **GDPR EU Region** | ✅ | ✅ | ✅ | ✅ |

---

## Provider Selection Decision Tree

```
START: Wat zijn je requirements?

├─ Budget < $100/month?
│   └─ DigitalOcean DOKS
│       - Pros: Goedkoop, simpel, transparant
│       - Cons: Minder enterprise features
│
├─ Bestaande cloud workloads?
│   ├─ AWS → EKS
│   │   - Pros: Beste AWS integratie
│   │   - Cons: Duurder, vendor lock-in
│   ├─ Azure → AKS
│   │   - Pros: Goede Azure integratie
│   │   - Cons: Azure-specific features
│   └─ GCP → GKE
│       - Pros: Meest K8s-native
│       - Cons: Google Cloud lock-in
│
├─ Maximum vendor independence?
│   └─ DigitalOcean DOKS of Self-Managed
│       - Minste proprietary features
│       - Gemakkelijkst te migreren
│
└─ Enterprise compliance (SOC2, ISO)?
    └─ AWS EKS, Azure AKS, of GCP GKE
        - Enterprise support beschikbaar
        - Compliance certifications
```

---

## Lock-in Risk Assessment

### High Lock-in Risk Features

**Vermijd deze features als je provider-agnostisch wilt blijven:**

| Provider | High Lock-in Features | Alternative |
|----------|----------------------|-------------|
| **AWS** | ALB Ingress Controller | NGINX Ingress |
| **AWS** | AWS Secrets Manager (direct) | External Secrets Operator |
| **AWS** | EBS CSI Driver (direct) | Generic CSI patterns |
| **Azure** | Azure AD Pod Identity | Workload Identity (standard) |
| **Azure** | Azure Key Vault (direct) | External Secrets Operator |
| **GCP** | Workload Identity (GKE) | Standard ServiceAccounts |
| **GCP** | GCS CSI Driver | Generic object storage |

### Abstraction Strategies

1. **Ingress**: Gebruik NGINX/Traefik, niet cloud-native LB controllers
2. **Secrets**: Gebruik External Secrets Operator met meerdere backends
3. **Storage**: Gebruik Storage Classes met standaard interfaces
4. **Identity**: Gebruik OIDC waar mogelijk, niet provider-specific
5. **Registry**: Gebruik Harbor of GHCR, niet ECR/ACR/GCR direct

---

## Migration Patterns

### Pattern 1: Blue/Green Cross-Provider

**Scenario**: Migratie met zero downtime

```
Current Provider (Blue)    New Provider (Green)
        │                         │
        ├─── Database Replication ──┤
        │                         │
        ├─── DNS Switch ──────────►│
        │                         │
        └─── Decommission         Active
```

**Steps**:
1. Provision nieuwe cluster op target provider
2. Setup database replication (if stateful)
3. Deploy applicaties op nieuwe cluster
4. Smoke test op nieuwe cluster
5. DNS/Load balancer cutover
6. Monitor nieuwe cluster
7. Decommission oude cluster

**Downtime**: Zero (als goed uitgevoerd)

---

### Pattern 2: Gradual Migration

**Scenario**: Risk-averse, service-by-service

```
Week 1: Non-critical service → New Provider
Week 2: Another service → New Provider
Week 3: Critical service → New Provider
Week 4: Database migration → New Provider
```

**Pros**: Minimale risk, gemakkelijk rollback  
**Cons**: Langere dual-provider period (hogere cost)

---

## Testing Strategy

### Cross-Provider Testing

**Doel**: Valideer dat manifests werken op alle providers

**Approach**:
```bash
# Test matrix
providers=(aws azure gcp digitalocean)
for provider in "${providers[@]}"; do
    echo "Testing on $provider..."
    ./scripts/test-provider.sh $provider
done
```

**Validatie checklist**:
- [ ] Pods starten succesvol
- [ ] Services zijn bereikbaar
- [ ] Persistent volumes werken
- [ ] Network policies werken
- [ ] Ingress/LoadBalancer werkt
- [ ] Secrets zijn toegankelijk
- [ ] Metrics worden verzameld

---

## Cost Optimization

### Cross-Provider Cost Comparison

**Zie**: [comparison-matrix.md](comparison-matrix.md) voor gedetailleerde cost breakdown.

**Algemene tips**:
1. **Spot/Preemptible Instances**: AWS Spot, Azure Spot, GCP Preemptible
2. **Committed Use Discounts**: Reservations voor langdurige workloads
3. **Right-sizing**: Gebruik cluster autoscaler om overhead te minimaliseren
4. **Storage tiering**: Gebruik appropriate storage classes (niet altijd premium)
5. **Egress costs**: Minimaliseer cross-region/internet traffic

---

## Compliance & Data Residency

### GDPR Considerations

| Provider | EU Regions | Data Residency | GDPR Tooling |
|----------|-----------|----------------|--------------|
| **AWS** | Frankfurt, Ireland, Paris, Stockholm | ✅ | AWS Config, CloudTrail |
| **Azure** | Netherlands, Ireland, France, Germany | ✅ | Azure Policy, Monitor |
| **GCP** | Belgium, Netherlands, Finland, Germany | ✅ | Security Command Center |
| **DO** | Amsterdam, Frankfurt | ✅ | Basic monitoring |

**Best Practice**: 
- Deploy clusters in EU regions voor GDPR compliance
- Gebruik network policies om data flows te controleren
- Audit logging voor alle API access
- Encrypt data at rest en in transit

---

## Bijdragen

Wil je een provider guide toevoegen of verbeteren?

1. Gebruik bestaande provider guide als template
2. Test praktisch op de provider
3. Documenteer quirks en gotchas
4. Voeg toe aan comparison matrix
5. Open een PR

Zie [CONTRIBUTING.md](../../CONTRIBUTING.md) voor guidelines.
