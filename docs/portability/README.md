# Provider Portability Framework

Deze directory bevat guides en frameworks voor het bouwen van provider-agnostische Kubernetes applicaties en infrastructuur.

---

## Doel

**Vendor independence door design**, niet door accident:
- Abstractions voor provider-specifieke features
- Testing frameworks voor cross-provider compatibility
- Migration playbooks tussen providers
- Best practices voor portability

---

## Inhoud

```
portability/
├── testing-framework.md        # Hoe test je cross-provider compatibility
├── compatibility-matrix.md     # Feature compatibility tussen providers
├── abstraction-layers.md       # Design patterns voor abstraction
├── migration-playbooks.md      # Step-by-step migration guides
└── README.md                   # This file
```

---

## Portability Principles

### 1. Gebruik Standaard Kubernetes APIs

**DO**:
```yaml
# Standard LoadBalancer Service
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: LoadBalancer
  ports:
  - port: 80
```

**DON'T**:
```yaml
# AWS-specific annotations everywhere
apiVersion: v1
kind: Service
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:..."
```

---

### 2. Abstract Provider-Specific Resources

**Pattern: ConfigMap-based configuration**

```yaml
# Base service configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloud-config
data:
  provider: "aws"  # Change per environment
  region: "eu-west-1"
  storage-class: "gp3"  # Provider-specific but externalized
```

**Application blijft provider-agnostic**, configuratie is externalized.

---

### 3. Use External Secrets Operator

**DO**: Abstract secrets management
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: cloud-secrets
spec:
  provider:
    # Can be AWS, Azure, GCP, Vault, etc.
    aws:
      service: SecretsManager
      region: eu-west-1
```

**DON'T**: Hard-code provider in application
```go
// Don't do this
import "github.com/aws/aws-sdk-go/service/secretsmanager"
```

---

### 4. Storage Class Abstraction

**Pattern: Named storage classes per workload type**

```yaml
# Define intent, not implementation
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd      # Generic name
provisioner: ...      # Provider-specific (set per environment)
parameters:
  type: gp3           # AWS
  # OR type: Premium_LRS  # Azure
  # OR type: pd-ssd       # GCP
```

**Applications reference `fast-ssd`**, niet `gp3` of `pd-ssd`.

---

## Testing Framework

### Cross-Provider Validation

**Goal**: Ensure manifests work on all target providers

**Test Matrix**:
```
Provider | Cluster Setup | Deploy | Smoke Test | Load Test
---------|---------------|--------|------------|----------
AWS EKS  |       ✅      |   ✅   |     ✅     |    ✅
Azure AK |       ✅      |   ✅   |     ✅     |    ✅
GCP GKE  |       ✅      |   ✅   |     ✅     |    ⚠️
DO DOKS  |       ✅      |   ✅   |     ❌     |    ❌
```

**Automated Testing**:
```bash
#!/bin/bash
# test-all-providers.sh

providers=("eks" "aks" "gke" "doks")

for provider in "${providers[@]}"; do
  echo "Testing on $provider..."
  
  # 1. Provision cluster
  terraform apply -var="provider=$provider"
  
  # 2. Deploy application
  kubectl apply -f manifests/
  
  # 3. Run smoke tests
  ./scripts/smoke-test.sh
  
  # 4. Cleanup
  terraform destroy -auto-approve
done
```

---

## Compatibility Matrix

### Storage Classes

| Feature | AWS | Azure | GCP | DO |
|---------|-----|-------|-----|-----|
| **Block Storage** | ✅ EBS | ✅ Disk | ✅ PD | ✅ Volume |
| **File Storage** | ✅ EFS | ✅ Files | ✅ Filestore | ❌ |
| **Object Storage** | ✅ S3 | ✅ Blob | ✅ GCS | ✅ Spaces |
| **Dynamic Provisioning** | ✅ | ✅ | ✅ | ✅ |
| **Volume Snapshots** | ✅ | ✅ | ✅ | ⚠️ Manual |
| **Resize** | ✅ | ✅ | ✅ | ❌ |

---

### Load Balancers

| Feature | AWS | Azure | GCP | DO |
|---------|-----|-------|-----|-----|
| **Layer 4 LB** | ✅ NLB | ✅ LB | ✅ TCP LB | ✅ |
| **Layer 7 LB** | ✅ ALB | ✅ App GW | ✅ HTTP LB | ⚠️ Limited |
| **SSL Termination** | ✅ | ✅ | ✅ | ✅ |
| **WebSockets** | ✅ | ✅ | ✅ | ✅ |
| **Custom Domains** | ✅ | ✅ | ✅ | ✅ |
| **DDoS Protection** | ✅ Shield | ✅ DDoS | ✅ Armor | ⚠️ Basic |

---

### Network Policies

| Feature | AWS | Azure | GCP | DO |
|---------|-----|-------|-----|-----|
| **CNI Support** | ✅ | ✅ | ✅ | ✅ |
| **NetworkPolicy** | ✅ | ✅ | ✅ | ✅ |
| **Egress Rules** | ✅ | ✅ | ✅ | ✅ |
| **DNS Policies** | ✅ | ✅ | ✅ | ✅ |
| **IP Whitelisting** | ✅ | ✅ | ✅ | ✅ |

---

## Migration Playbooks

### Playbook 1: AWS EKS → Azure AKS

**Prerequisites**:
- [ ] Azure subscription with appropriate permissions
- [ ] Target AKS cluster provisioned
- [ ] Network connectivity between clusters (if needed for data sync)

**Phase 1: Preparation (Week -2)**
1. Audit current AWS-specific resources
   ```bash
   kubectl get all -A -o yaml | grep -i "aws"
   ```
2. Identify lock-in points (ALB, IAM Roles, etc.)
3. Create Azure equivalents
4. Test manifests on AKS test cluster

**Phase 2: Data Migration (Week -1)**
1. Setup database replication (if stateful)
2. Sync persistent volumes to Azure Disks
3. Test data integrity

**Phase 3: Application Migration (Week 0)**
1. Deploy applications to AKS
2. Run smoke tests
3. Parallel run (AWS + Azure) for validation

**Phase 4: Cutover (Week 0, Day 5)**
1. Update DNS to point to AKS
2. Monitor new environment
3. Keep AWS as fallback for 1 week

**Phase 5: Decommission (Week +1)**
1. Scale down AWS workloads
2. Backup final state
3. Destroy AWS resources

**Estimated Downtime**: 0-5 minutes (DNS propagation)

---

### Playbook 2: Self-Managed → Managed Kubernetes

**Common Migration Path**: On-premise/Self-managed → Cloud Managed (EKS/AKS/GKE)

**Advantages of Managed K8s**:
- No control plane management
- Automatic upgrades
- Better integration with cloud services
- Reduced operational overhead

**Migration Strategy**:
1. **Lift and Shift**: Move workloads as-is
2. **Refactor**: Optimize for cloud-native patterns
3. **Hybrid**: Keep some workloads on-premise

**Step-by-Step**:
- Zie [migration-playbooks.md](migration-playbooks.md) voor gedetailleerde guide

---

## Abstraction Layer Patterns

### Pattern 1: Configuration Externalization

**Problem**: Hard-coded provider-specific values in manifests

**Solution**: Externalize to ConfigMaps/Secrets per environment

```yaml
# base/deployment.yaml (provider-agnostic)
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: app-data
      containers:
      - name: app
        envFrom:
        - configMapRef:
            name: cloud-config

---
# overlays/aws/kustomization.yaml
resources:
- ../../base

configMapGenerator:
- name: cloud-config
  literals:
  - STORAGE_CLASS=gp3
  - REGION=eu-west-1
  - PROVIDER=aws

---
# overlays/azure/kustomization.yaml
resources:
- ../../base

configMapGenerator:
- name: cloud-config
  literals:
  - STORAGE_CLASS=Premium_LRS
  - REGION=westeurope
  - PROVIDER=azure
```

---

### Pattern 2: Adapter Services

**Problem**: Different cloud APIs for same functionality

**Solution**: Create adapter layer

```
Application
    ↓
Adapter Service (Kubernetes Service)
    ↓
    ├─ AWS S3
    ├─ Azure Blob Storage
    ├─ GCP Cloud Storage
    └─ MinIO (on-premise)
```

**Example**: S3-compatible interface voor alle object storage

---

### Pattern 3: Feature Flags

**Problem**: Provider heeft bepaalde feature niet

**Solution**: Feature flags per provider

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: feature-flags
data:
  ENABLE_AUTOSCALING: "true"      # AWS, Azure, GCP: YES
  ENABLE_FILE_STORAGE: "false"    # DO: NO
  ENABLE_PRIVATE_ENDPOINT: "true" # AWS, Azure, GCP: YES
```

Application checkt feature flags en past gedrag aan.

---

## Best Practices

### ✅ DO

1. **Use Kubernetes-native resources** waar mogelijk
2. **Externalize provider-specific config** via ConfigMaps
3. **Test on multiple providers** vanaf dag 1
4. **Document provider quirks** in code comments
5. **Use abstraction layers** (External Secrets, CSI drivers)
6. **Version control everything** inclusief provider configs
7. **Automate testing** met CI/CD voor alle providers
8. **Monitor portability metrics** (provider-specific resources)

### ❌ DON'T

1. **Hard-code cloud provider SDKs** in application code
2. **Use provider annotations** zonder fallback
3. **Assume features work everywhere** without testing
4. **Skip provider-specific documentation**
5. **Ignore migration costs** tijdens architecture design
6. **Couple tightly to managed services** (RDS, etc.)
7. **Forget about egress costs** bij multi-cloud
8. **Skip disaster recovery testing** cross-provider

---

## Tooling Recommendations

### Infrastructure as Code

**Multi-Provider IaC**:
- **Terraform**: Beste cross-provider support
- **Pulumi**: Modernere alternative, meerdere languages
- **Crossplane**: Kubernetes-native, infrastructure-as-Kubernetes

**Recommendation**: Start met Terraform, consider Crossplane voor K8s-native approach

---

### Policy Enforcement

**Portability Policies with OPA/Kyverno**:

```rego
# Deny AWS-specific annotations unless explicitly allowed
package kubernetes.admission

deny[msg] {
  input.request.kind.kind == "Service"
  annotation := input.request.object.metadata.annotations[key]
  startswith(key, "service.beta.kubernetes.io/aws-")
  not allowed_aws_annotation(key)
  
  msg := sprintf("AWS-specific annotation not allowed: %v", [key])
}

allowed_aws_annotation(key) {
  # Whitelist specific necessary annotations
  key == "service.beta.kubernetes.io/aws-load-balancer-type"
}
```

---

### Testing Tools

- **KubeBench**: CIS benchmark compliance (works everywhere)
- **Polaris**: Best practices validation (provider-agnostic)
- **Kubeconform**: Manifest validation against K8s schemas
- **Pluto**: Deprecated API detection (before migration)

---

## Metrics & Monitoring

### Portability Health Metrics

Track deze metrics om portability te monitoren:

```prometheus
# Percentage provider-specific resources
portability_provider_specific_resources_ratio{provider="aws"} 0.15

# Number of provider-specific annotations
portability_annotations_count{type="aws"} 5
portability_annotations_count{type="azure"} 0

# Migration readiness score (0-100)
portability_migration_readiness_score{target_provider="azure"} 85
```

**Dashboard**:
- Provider-specific resource count
- Lock-in risk score
- Migration complexity estimate
- Test coverage per provider

---

## Case Studies

### Case Study 1: DigitalOcean → AWS Migration

**Company**: Dutch webshop (zie [cases/webshop](../../cases/webshop/))  
**Reason**: Outgrown DO, need enterprise features  
**Downtime**: 0 minutes

**Lessons Learned**:
- Storage classes were easy (both use CSI)
- LoadBalancer annotations needed adjustment
- No major application changes needed (good abstraction!)

**Key Success Factor**: Used External Secrets Operator from day 1

---

### Case Study 2: On-Premise → Multi-Cloud

**Company**: Enterprise with compliance requirements  
**Strategy**: Hybrid cloud (keep sensitive data on-premise)  
**Timeline**: 6 months  
**Result**: 70% workloads in cloud, 30% on-premise

**Lessons Learned**:
- Network latency between environments was challenge
- Secrets management was complex (Vault helped)
- Cost optimization required constant monitoring

---

## Further Reading

- [Kubernetes Multi-Cloud Best Practices](https://kubernetes.io/docs/concepts/cluster-administration/)
- [CNCF Cloud Native Trail Map](https://github.com/cncf/trailmap)
- [12 Factor App Methodology](https://12factor.net/)
- [Cloud Native Patterns](https://www.manning.com/books/cloud-native-patterns)

---

## Bijdragen

Wil je bijdragen aan portability guides?

Topics die hulp nodig hebben:
- [ ] Automated cross-provider testing scripts
- [ ] More migration playbooks (GCP → Azure, etc.)
- [ ] Abstraction layer implementations
- [ ] Cost comparison tooling
- [ ] Performance benchmarking cross-provider

Zie [CONTRIBUTING.md](../../CONTRIBUTING.md) voor guidelines.
