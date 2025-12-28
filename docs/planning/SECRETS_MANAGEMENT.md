# Secrets Management for Kubernetes

**Complete guide to managing secrets in Kubernetes environments**

---

## Executive Summary

**TL;DR Decision Rules:**

```javascript
// Primary decision factors
if (using_aws || using_azure || using_gcp) {
  // Cloud-native secrets management
  recommend("External Secrets Operator");
  
  if (multi_cloud || planning_cloud_migration) {
    prefer("External Secrets Operator"); // Supports 30+ backends
  }
  
  if (want_gitops_only && no_external_dependencies) {
    fallback("Sealed Secrets"); // Pure GitOps, cluster-scoped
  }
}

if (on_premises || bare_metal) {
  if (have_vault || planning_vault) {
    recommend("External Secrets Operator with Vault");
  } else if (simple_setup && gitops_workflow) {
    recommend("Sealed Secrets"); // No external dependencies
  } else if (sophisticated_git_workflow && age_encryption) {
    recommend("SOPS"); // File-level encryption in Git
  }
}

if (compliance_requirement === "strict_audit_trail") {
  recommend("External Secrets Operator + Vault"); // Full audit logs
  avoid("Sealed Secrets"); // Limited auditability
}

if (team_size < 5 && low_complexity) {
  recommend("Sealed Secrets"); // Simplest setup
} else if (team_size > 20 || multi_team) {
  recommend("External Secrets Operator"); // Centralized management
}

// Default recommendation
default: "External Secrets Operator" // Most flexible, industry standard
```

**Quick Comparison:**

| Factor | External Secrets Operator | Sealed Secrets | SOPS |
|--------|---------------------------|----------------|------|
| **Maturity** | ⭐⭐⭐⭐⭐ CNCF Incubating | ⭐⭐⭐⭐ Stable | ⭐⭐⭐⭐ Stable |
| **Complexity** | Medium (requires backend) | Low (self-contained) | Medium (CI/CD integration) |
| **Backend Support** | 30+ (AWS, Azure, Vault, etc.) | None (cluster-scoped) | Git repos only |
| **GitOps Native** | ⚠️ Partial (external backend) | ✅ Yes (100% GitOps) | ✅ Yes (file encryption) |
| **Secret Rotation** | ✅ Automatic (backend-driven) | ❌ Manual | ❌ Manual |
| **Audit Trail** | ✅ Full (backend provides) | ⚠️ Limited | ⚠️ Git history only |
| **Multi-Cluster** | ✅ Easy (shared backend) | ⚠️ Complex (per-cluster keys) | ✅ Easy (shared keys) |
| **Vendor Lock-in** | Low (many backends) | None | None |
| **Best For** | Cloud-native, enterprise | Pure GitOps, simplicity | Git-centric workflows |

**Weighted Scoring (0-5):**

| Criteria | ESO | Sealed Secrets | SOPS | Weight |
|----------|-----|----------------|------|--------|
| Ease of Use | 3 | 5 | 3 | 20% |
| Security | 5 | 4 | 4 | 30% |
| Flexibility | 5 | 2 | 3 | 25% |
| Operational Complexity | 3 | 5 | 3 | 15% |
| Cost | 4 | 5 | 5 | 10% |
| **Total** | **4.1** | **3.9** | **3.5** | |

**Recommendation:** **External Secrets Operator** for 80% of use cases, **Sealed Secrets** for pure GitOps simplicity.

---

## Table of Contents

1. [Problem Statement](#problem-statement)
2. [Architecture Overview](#architecture-overview)
3. [External Secrets Operator](#external-secrets-operator)
4. [Sealed Secrets](#sealed-secrets)
5. [SOPS](#sops)
6. [Feature Comparison](#feature-comparison)
7. [Decision Framework](#decision-framework)
8. [Migration Paths](#migration-paths)
9. [Best Practices](#best-practices)
10. [Related Documentation](#related-documentation)

---

## Problem Statement

**Why not just use Kubernetes Secrets?**

Kubernetes Secrets are **base64-encoded**, not encrypted. Anyone with read access to the namespace can decode them:

```bash
kubectl get secret my-secret -o jsonpath='{.data.password}' | base64 -d
# Output: SuperSecretPassword123
```

**Problems with plain Secrets:**
- ❌ Cannot be stored in Git (security risk)
- ❌ Manual management (no GitOps)
- ❌ No audit trail (who changed what when?)
- ❌ No automatic rotation
- ❌ Difficult to share across clusters

**What we need:**
- ✅ Secrets stored in Git (encrypted)
- ✅ GitOps workflow (declarative, version-controlled)
- ✅ Automatic sync from external sources
- ✅ Secret rotation without code changes
- ✅ Audit trail and compliance
- ✅ Separation of concerns (ops own secrets, devs own manifests)

---

## Architecture Overview

### Three Approaches

#### 1. External Secrets Operator (ESO)
**External backend + operator sync**

```
┌─────────────┐         ┌──────────────────┐         ┌──────────────┐
│  AWS SSM    │◄────────┤  External Secret │────────►│   K8s Secret │
│  Azure KV   │  Sync   │    Operator      │ Creates │   (Runtime)  │
│  Vault      │         └──────────────────┘         └──────────────┘
└─────────────┘                   ▲
                                  │
                          ┌───────┴────────┐
                          │  Git Repo      │
                          │  (ExternalSecret)│
                          │  manifests only │
                          └────────────────┘
```

**Flow:**
1. Store actual secrets in AWS Secrets Manager / Azure Key Vault / Vault
2. Commit `ExternalSecret` manifests to Git (metadata only, no actual secrets)
3. ESO controller syncs secrets from backend → creates K8s Secrets
4. Pods consume K8s Secrets normally

#### 2. Sealed Secrets
**Asymmetric encryption + controller decrypt**

```
┌─────────────┐         ┌──────────────────┐         ┌──────────────┐
│  Developer  │ Encrypt │  Sealed Secret   │────────►│   K8s Secret │
│  (kubeseal) ├────────►│   (in Git)       │ Decrypt │   (Runtime)  │
└─────────────┘         └──────────────────┘         └──────────────┘
                                  ▲
                                  │
                          ┌───────┴────────┐
                          │  Public Key    │
                          │  (cluster-wide)│
                          └────────────────┘
                                  │
                          ┌───────▼────────┐
                          │  Private Key   │
                          │  (controller)  │
                          └────────────────┘
```

**Flow:**
1. Developer encrypts secret with `kubeseal` CLI (using cluster public key)
2. Commit encrypted `SealedSecret` to Git (safe to commit!)
3. Controller decrypts using private key → creates K8s Secret
4. Pods consume K8s Secrets normally

#### 3. SOPS
**File-level encryption + CI/CD decrypt**

```
┌─────────────┐         ┌──────────────────┐         ┌──────────────┐
│  Developer  │ Encrypt │  Encrypted YAML  │────────►│   ArgoCD/    │
│  (sops)     ├────────►│   (in Git)       │ Decrypt │   Flux       │
└─────────────┘         └──────────────────┘         └──────┬───────┘
                                  ▲                          │
                          ┌───────┴────────┐         ┌──────▼───────┐
                          │  AGE / KMS     │         │  K8s Secret  │
                          │  Encryption    │         │  (Runtime)   │
                          └────────────────┘         └──────────────┘
```

**Flow:**
1. Developer encrypts entire YAML file with `sops` (AGE or cloud KMS)
2. Commit encrypted file to Git
3. ArgoCD/Flux decrypts during deployment → applies Secret
4. Pods consume K8s Secrets normally

---

## External Secrets Operator

### Overview

**External Secrets Operator (ESO)** syncs secrets from external secret management systems (AWS Secrets Manager, Azure Key Vault, HashiCorp Vault, etc.) into Kubernetes Secrets.

**Pros:**
- ✅ **30+ backend support** (AWS, Azure, GCP, Vault, 1Password, etc.)
- ✅ **Automatic secret rotation** (backend-driven)
- ✅ **Full audit trail** (backend provides)
- ✅ **Multi-cluster easy** (shared backend)
- ✅ **CNCF Incubating** project (strong governance)
- ✅ **Separation of concerns** (ops manage secrets, devs commit manifests)

**Cons:**
- ❌ **Requires external backend** (not pure GitOps)
- ❌ **Dependency on external service** (availability risk)
- ❌ **Cloud costs** (AWS Secrets Manager charges per secret)
- ❌ **More complexity** (two systems to manage)

### Architecture

```yaml
# 1. SecretStore - Connection to backend
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets-manager
  namespace: webshop
spec:
  provider:
    aws:
      service: SecretsManager
      region: eu-west-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa

---
# 2. ExternalSecret - What to sync
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: database-credentials
  namespace: webshop
spec:
  refreshInterval: 1h  # Sync every hour
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: postgres-credentials  # K8s Secret name
    creationPolicy: Owner
  data:
  - secretKey: username        # K8s Secret key
    remoteRef:
      key: webshop/postgres    # AWS secret name
      property: username       # JSON property
  - secretKey: password
    remoteRef:
      key: webshop/postgres
      property: password

---
# 3. Result: Regular K8s Secret (auto-created)
# apiVersion: v1
# kind: Secret
# metadata:
#   name: postgres-credentials
# data:
#   username: <base64>
#   password: <base64>
```

### Installation

```bash
# Helm installation
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm install external-secrets \
  external-secrets/external-secrets \
  -n external-secrets-system \
  --create-namespace \
  --set installCRDs=true

# Verify
kubectl get pods -n external-secrets-system
kubectl get crd | grep external-secrets
```

### AWS Secrets Manager Example

**Step 1: Create secret in AWS**
```bash
aws secretsmanager create-secret \
  --name webshop/postgres \
  --secret-string '{"username":"dbadmin","password":"SuperSecret123!"}' \
  --region eu-west-1
```

**Step 2: Create IAM role for IRSA (EKS)**
```bash
# Create IAM policy
cat > secrets-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:eu-west-1:*:secret:webshop/*"
    }
  ]
}
EOF

aws iam create-policy \
  --policy-name ExternalSecretsPolicy \
  --policy-document file://secrets-policy.json

# Create service account with IRSA
eksctl create iamserviceaccount \
  --name external-secrets-sa \
  --namespace webshop \
  --cluster your-cluster \
  --attach-policy-arn arn:aws:iam::ACCOUNT_ID:policy/ExternalSecretsPolicy \
  --approve
```

**Step 3: Create SecretStore and ExternalSecret**
```yaml
# secretstore.yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets-manager
  namespace: webshop
spec:
  provider:
    aws:
      service: SecretsManager
      region: eu-west-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa

---
# externalsecret.yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: postgres-credentials
  namespace: webshop
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
  target:
    name: postgres-credentials
  data:
  - secretKey: username
    remoteRef:
      key: webshop/postgres
      property: username
  - secretKey: password
    remoteRef:
      key: webshop/postgres
      property: password
```

**Step 4: Verify sync**
```bash
kubectl apply -f secretstore.yaml
kubectl apply -f externalsecret.yaml

# Check ExternalSecret status
kubectl get externalsecret postgres-credentials -n webshop
kubectl describe externalsecret postgres-credentials -n webshop

# Check created Secret
kubectl get secret postgres-credentials -n webshop
kubectl get secret postgres-credentials -n webshop -o jsonpath='{.data.username}' | base64 -d
```

### Azure Key Vault Example

```yaml
# SecretStore for Azure
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: azure-keyvault
  namespace: webshop
spec:
  provider:
    azurekv:
      vaultUrl: "https://my-keyvault.vault.azure.net"
      authType: WorkloadIdentity
      serviceAccountRef:
        name: external-secrets-sa

---
# ExternalSecret
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: database-credentials
  namespace: webshop
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: azure-keyvault
  target:
    name: postgres-credentials
  data:
  - secretKey: username
    remoteRef:
      key: postgres-username
  - secretKey: password
    remoteRef:
      key: postgres-password
```

### HashiCorp Vault Example

```yaml
# SecretStore for Vault
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
  namespace: webshop
spec:
  provider:
    vault:
      server: "https://vault.example.com"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "external-secrets"
          serviceAccountRef:
            name: external-secrets-sa

---
# ExternalSecret
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: database-credentials
  namespace: webshop
spec:
  refreshInterval: 15m
  secretStoreRef:
    name: vault-backend
  target:
    name: postgres-credentials
  data:
  - secretKey: username
    remoteRef:
      key: webshop/database
      property: username
  - secretKey: password
    remoteRef:
      key: webshop/database
      property: password
```

### ClusterSecretStore (Multi-Namespace)

```yaml
# ClusterSecretStore - usable across all namespaces
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: aws-secrets-manager-cluster
spec:
  provider:
    aws:
      service: SecretsManager
      region: eu-west-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
            namespace: external-secrets-system

---
# ExternalSecret in any namespace
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-credentials
  namespace: team-a
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager-cluster
    kind: ClusterSecretStore  # Note the kind
  target:
    name: app-credentials
  data:
  - secretKey: api-key
    remoteRef:
      key: team-a/api-key
```

### Secret Rotation

ESO automatically syncs secrets based on `refreshInterval`:

```yaml
spec:
  refreshInterval: 15m  # Check backend every 15 minutes
```

**Trigger immediate refresh:**
```bash
# Force immediate sync
kubectl annotate externalsecret postgres-credentials \
  force-sync=$(date +%s) \
  -n webshop
```

### Monitoring

```bash
# Check ESO controller logs
kubectl logs -n external-secrets-system -l app.kubernetes.io/name=external-secrets

# Check ExternalSecret status
kubectl get externalsecret -A
kubectl describe externalsecret <name> -n <namespace>

# Prometheus metrics
kubectl port-forward -n external-secrets-system svc/external-secrets-webhook 8080:8080
curl http://localhost:8080/metrics
```

---

## Sealed Secrets

### Overview

**Sealed Secrets** uses asymmetric encryption to safely store secrets in Git. Only the cluster controller can decrypt them.

**Pros:**
- ✅ **Pure GitOps** (everything in Git, no external dependencies)
- ✅ **Simple setup** (one controller, one CLI)
- ✅ **No external costs** (cluster-scoped)
- ✅ **Mature project** (Bitnami, widely adopted)
- ✅ **Portable** (works anywhere Kubernetes runs)

**Cons:**
- ❌ **No automatic rotation** (manual process)
- ❌ **Limited audit trail** (Git history only)
- ❌ **Multi-cluster complex** (separate keys per cluster)
- ❌ **Key management burden** (backup private key!)
- ❌ **Namespace-scoped** by default (can't share secrets easily)

### Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    Sealed Secrets                        │
│                                                          │
│  1. Developer encrypts with PUBLIC KEY                   │
│     kubeseal --format yaml < secret.yaml > sealed.yaml   │
│                                                          │
│  2. Commit encrypted SealedSecret to Git                 │
│     git add sealed.yaml && git commit                    │
│                                                          │
│  3. Controller decrypts with PRIVATE KEY                 │
│     kubectl apply -f sealed.yaml                         │
│     → SealedSecret controller → K8s Secret               │
│                                                          │
│  ⚠️ CRITICAL: Backup private key!                        │
│     kubectl get secret -n kube-system \                  │
│       sealed-secrets-key -o yaml > backup.yaml           │
└──────────────────────────────────────────────────────────┘
```

### Installation

```bash
# Install controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

# Verify
kubectl get pods -n kube-system -l name=sealed-secrets-controller

# Install kubeseal CLI
# macOS
brew install kubeseal

# Linux
KUBESEAL_VERSION='0.24.0'
wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
tar -xvzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal

# Windows (via Chocolatey)
choco install kubeseal
```

### Basic Usage

**Step 1: Create regular Secret (DO NOT COMMIT!)**
```yaml
# secret.yaml (NEVER commit this file!)
apiVersion: v1
kind: Secret
metadata:
  name: postgres-credentials
  namespace: webshop
type: Opaque
stringData:
  username: dbadmin
  password: SuperSecret123!
```

**Step 2: Encrypt with kubeseal**
```bash
# Encrypt secret (safe to commit result!)
kubeseal --format yaml < secret.yaml > sealed-secret.yaml

# Or encrypt inline
kubectl create secret generic postgres-credentials \
  --from-literal=username=dbadmin \
  --from-literal=password=SuperSecret123! \
  --dry-run=client -o yaml | \
  kubeseal --format yaml > sealed-secret.yaml

# Result: sealed-secret.yaml
cat sealed-secret.yaml
```

**sealed-secret.yaml** (safe to commit):
```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: postgres-credentials
  namespace: webshop
spec:
  encryptedData:
    username: AgBy3i4OJSWK+PiTySYZZA9rO43cGDEq...  # Encrypted!
    password: AgAjqMAiQsC2CNHLhVESZhXz0JCiCBkf...  # Encrypted!
  template:
    metadata:
      name: postgres-credentials
      namespace: webshop
    type: Opaque
```

**Step 3: Commit and apply**
```bash
# Safe to commit!
git add sealed-secret.yaml
git commit -m "Add postgres credentials (encrypted)"
git push

# Apply to cluster
kubectl apply -f sealed-secret.yaml

# Controller automatically creates K8s Secret
kubectl get secret postgres-credentials -n webshop
```

### Scopes

Sealed Secrets has three scopes:

#### 1. **Strict** (default) - Namespace + Name locked
```bash
# Can only be decrypted in specific namespace with specific name
kubeseal --scope strict < secret.yaml > sealed.yaml
```

✅ Most secure  
❌ Cannot rename or move to different namespace

#### 2. **Namespace-wide** - Any name, locked namespace
```bash
# Can be used with any name, but only in specific namespace
kubeseal --scope namespace-wide < secret.yaml > sealed.yaml
```

✅ Flexible naming  
❌ Still namespace-locked

#### 3. **Cluster-wide** - Any name, any namespace
```bash
# Can be used anywhere in cluster
kubeseal --scope cluster-wide < secret.yaml > sealed.yaml
```

✅ Maximum flexibility  
⚠️ Less secure (can be moved anywhere)

**Example with scope:**
```bash
# Namespace-wide scope
kubectl create secret generic api-key \
  --from-literal=key=secret123 \
  --namespace=webshop \
  --dry-run=client -o yaml | \
  kubeseal --scope namespace-wide --format yaml > api-key-sealed.yaml
```

### Key Management

**⚠️ CRITICAL: Backup your private key!**

```bash
# Backup sealing key (KEEP SAFE!)
kubectl get secret -n kube-system \
  -l sealedsecrets.bitnami.com/sealed-secrets-key=active \
  -o yaml > sealed-secrets-master-key.yaml

# Store in secure location:
# - 1Password / LastPass
# - AWS Secrets Manager
# - HashiCorp Vault
# - Offline encrypted USB drive
```

**Restore key to new cluster:**
```bash
# Restore master key
kubectl apply -f sealed-secrets-master-key.yaml

# Restart controller to pick up key
kubectl delete pod -n kube-system -l name=sealed-secrets-controller
```

**Key rotation:**
```bash
# Controller auto-rotates keys every 30 days
# Old keys are kept for decryption
# New secrets use new key

# Force key rotation
kubectl delete secret -n kube-system \
  -l sealedsecrets.bitnami.com/sealed-secrets-key=active

# Controller generates new key pair
kubectl logs -n kube-system -l name=sealed-secrets-controller
```

### Re-encryption (Update Secrets)

```bash
# To update a secret, re-encrypt
kubectl create secret generic postgres-credentials \
  --from-literal=username=dbadmin \
  --from-literal=password=NewPassword456! \
  --namespace=webshop \
  --dry-run=client -o yaml | \
  kubeseal --format yaml > sealed-secret.yaml

# Commit and apply
git add sealed-secret.yaml
git commit -m "Update postgres password"
kubectl apply -f sealed-secret.yaml
```

### Troubleshooting

```bash
# Check controller logs
kubectl logs -n kube-system -l name=sealed-secrets-controller

# Verify SealedSecret
kubectl get sealedsecret -n webshop
kubectl describe sealedsecret postgres-credentials -n webshop

# Check if Secret was created
kubectl get secret -n webshop

# Decrypt sealed secret (requires kubeseal with controller access)
kubeseal --recovery-unseal --recovery-private-key master.key < sealed-secret.yaml

# Fetch public key
kubeseal --fetch-cert > public-key.pem
```

---

## SOPS

### Overview

**SOPS (Secrets OPerationS)** encrypts entire YAML/JSON files using AGE, AWS KMS, Azure Key Vault, or GCP KMS. Files are stored encrypted in Git and decrypted during deployment by ArgoCD/Flux.

**Pros:**
- ✅ **File-level encryption** (encrypt any YAML/JSON/ENV)
- ✅ **Multiple key providers** (AGE, KMS, Key Vault)
- ✅ **GitOps native** (encrypted files in Git)
- ✅ **Partial encryption** (only sensitive fields)
- ✅ **Strong audit trail** (Git history)
- ✅ **Flexible** (not Kubernetes-specific)

**Cons:**
- ❌ **CI/CD integration required** (ArgoCD/Flux plugin)
- ❌ **No automatic rotation** (manual re-encryption)
- ❌ **Key distribution complexity** (share AGE keys securely)
- ❌ **Learning curve** (SOPS syntax, .sops.yaml config)
- ❌ **Not Kubernetes-native** (generic tool)

### Architecture

```
┌──────────────────────────────────────────────────────────┐
│                        SOPS                              │
│                                                          │
│  1. Developer encrypts file                              │
│     sops -e secret.yaml > secret.enc.yaml                │
│                                                          │
│  2. Commit encrypted file to Git                         │
│     git add secret.enc.yaml && git commit                │
│                                                          │
│  3. ArgoCD/Flux decrypts during sync                     │
│     argocd-vault-plugin / FluxCD sops-controller         │
│     → Decrypted YAML → kubectl apply                     │
│                                                          │
│  Key Management:                                         │
│  - AGE: age-keygen (local keys)                          │
│  - AWS KMS: IAM-based                                    │
│  - Azure: Key Vault                                      │
│  - GCP: Cloud KMS                                        │
└──────────────────────────────────────────────────────────┘
```

### Installation

```bash
# macOS
brew install sops age

# Linux
# SOPS
SOPS_VERSION="3.8.1"
wget "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64"
sudo mv sops-v${SOPS_VERSION}.linux.amd64 /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops

# AGE
AGE_VERSION="1.1.1"
wget "https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz"
tar xzf age-v${AGE_VERSION}-linux-amd64.tar.gz
sudo mv age/age age/age-keygen /usr/local/bin/

# Windows
choco install sops age
```

### AGE Encryption (Recommended)

**Step 1: Generate AGE key pair**
```bash
# Generate key pair
age-keygen -o key.txt

# Output:
# Public key: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
# Key saved to: key.txt

# ⚠️ BACKUP key.txt SECURELY!
```

**Step 2: Create .sops.yaml config**
```yaml
# .sops.yaml (in repo root)
creation_rules:
  # Encrypt all files in secrets/ folder
  - path_regex: secrets/.*\.yaml$
    age: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
  
  # Encrypt specific files
  - path_regex: manifests/.*/.*secret.*\.yaml$
    age: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
  
  # Different key for production
  - path_regex: environments/production/.*\.yaml$
    age: age1<different-key>
```

**Step 3: Encrypt secret**
```bash
# Create secret file
cat > secrets/postgres.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: postgres-credentials
  namespace: webshop
type: Opaque
stringData:
  username: dbadmin
  password: SuperSecret123!
EOF

# Encrypt (uses .sops.yaml config)
sops -e secrets/postgres.yaml > secrets/postgres.enc.yaml

# Or encrypt in-place
sops -e -i secrets/postgres.yaml
```

**secrets/postgres.enc.yaml** (safe to commit):
```yaml
apiVersion: v1
kind: Secret
metadata:
    name: postgres-credentials
    namespace: webshop
type: Opaque
stringData:
    username: ENC[AES256_GCM,data:Tm90VGVsbGluZw==,iv:...]
    password: ENC[AES256_GCM,data:U3VwZXJTZWNyZXQxMjMh,iv:...]
sops:
    kms: []
    gcp_kms: []
    azure_kv: []
    age:
        - recipient: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
          enc: |
            -----BEGIN AGE ENCRYPTED FILE-----
            YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSB...
            -----END AGE ENCRYPTED FILE-----
    lastmodified: "2025-12-28T10:30:00Z"
    mac: ENC[AES256_GCM,data:abc123...,type:str]
    version: 3.8.1
```

**Step 4: Decrypt (for testing)**
```bash
# Decrypt to stdout
sops -d secrets/postgres.enc.yaml

# Decrypt to file
sops -d secrets/postgres.enc.yaml > /tmp/postgres.yaml

# Apply directly (decrypts inline)
sops -d secrets/postgres.enc.yaml | kubectl apply -f -
```

### Partial Encryption

Encrypt only specific fields:

```yaml
# Before encryption
apiVersion: v1
kind: Secret
metadata:
  name: api-config
  namespace: webshop
type: Opaque
stringData:
  endpoint: https://api.example.com  # Public, no encryption needed
  api_key: sk_live_123456789        # Sensitive, encrypt this!
```

**Encrypt only sensitive fields:**
```bash
# Create .sops.yaml with encrypted_regex
cat > .sops.yaml <<EOF
creation_rules:
  - encrypted_regex: '^(data|stringData|password|api_key|secret)$'
    age: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
EOF

# Encrypt
sops -e config.yaml > config.enc.yaml
```

**Result:**
```yaml
apiVersion: v1
kind: Secret
metadata:
    name: api-config
    namespace: webshop
type: Opaque
stringData:
    endpoint: https://api.example.com  # NOT encrypted (public)
    api_key: ENC[AES256_GCM,data:c2tfc...,iv:...]  # Encrypted!
sops:
    # ... metadata
```

### AWS KMS Integration

```yaml
# .sops.yaml
creation_rules:
  - path_regex: environments/production/.*\.yaml$
    kms: 'arn:aws:kms:eu-west-1:123456789:key/12345678-1234-1234-1234-123456789012'
    aws_profile: production
```

```bash
# Encrypt with KMS
export AWS_PROFILE=production
sops -e secrets/production.yaml > secrets/production.enc.yaml

# Decrypt (requires IAM permissions)
sops -d secrets/production.enc.yaml
```

### Flux Integration

**Install Flux with SOPS support:**
```bash
# Bootstrap Flux with sops-age secret
flux bootstrap github \
  --owner=vanhoutenbos \
  --repository=kubecompass-gitops \
  --path=clusters/production \
  --personal

# Create AGE secret
kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=./key.txt
```

**Kustomization with decryption:**
```yaml
# clusters/production/kustomization.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: apps
  namespace: flux-system
spec:
  interval: 10m
  path: ./apps
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  decryption:
    provider: sops  # Enable SOPS decryption
    secretRef:
      name: sops-age
```

**Encrypted secret in Git:**
```yaml
# apps/webshop/postgres-secret.yaml (encrypted with SOPS)
apiVersion: v1
kind: Secret
metadata:
    name: postgres-credentials
    namespace: webshop
stringData:
    username: ENC[AES256_GCM,data:...]
    password: ENC[AES256_GCM,data:...]
sops:
    age:
        - recipient: age1ql3z7...
    # ...
```

Flux will automatically decrypt and apply!

### ArgoCD Integration

**Install argocd-vault-plugin:**
```yaml
# argocd-cm ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  configManagementPlugins: |
    - name: sops
      generate:
        command: ["sh", "-c"]
        args:
          - |
            sops -d $ARGOCD_APP_SOURCE_PATH/secrets.enc.yaml | \
            kubectl apply -f -
```

**Application with SOPS:**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: webshop
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/vanhoutenbos/kubecompass-gitops
    targetRevision: main
    path: apps/webshop
    plugin:
      name: sops  # Use SOPS plugin
  destination:
    server: https://kubernetes.default.svc
    namespace: webshop
```

### Key Rotation

```bash
# Generate new AGE key
age-keygen -o key-new.txt

# Re-encrypt all secrets with new key
sops rotate \
  --add-age $(grep 'public key:' key-new.txt | awk '{print $3}') \
  secrets/*.enc.yaml

# Or rotate in-place
find secrets/ -name '*.enc.yaml' -exec \
  sops rotate --add-age age1newkey... -i {} \;
```

---

## Feature Comparison

### Detailed Comparison Matrix

| Feature | External Secrets Operator | Sealed Secrets | SOPS |
|---------|---------------------------|----------------|------|
| **Setup Complexity** | Medium (backend + operator) | Low (controller only) | Medium (CI/CD integration) |
| **Backend Support** | 30+ (AWS, Azure, Vault, etc.) | None (cluster-scoped) | 4 (AGE, AWS KMS, Azure KV, GCP KMS) |
| **GitOps Native** | ⚠️ Partial (manifests only) | ✅ Full (encrypted secrets) | ✅ Full (encrypted files) |
| **Secret Rotation** | ✅ Automatic (backend-driven) | ❌ Manual | ❌ Manual |
| **Audit Trail** | ✅ Full (backend provides) | ⚠️ Git history only | ⚠️ Git history only |
| **Multi-Cluster** | ✅ Easy (shared backend) | ⚠️ Complex (per-cluster keys) | ✅ Easy (shared keys) |
| **Multi-Tenancy** | ✅ ClusterSecretStore | ⚠️ Per-namespace scopes | ✅ Path-based rules |
| **Secret Sharing** | ✅ Easy (backend-level) | ❌ Difficult | ✅ Easy (shared keys) |
| **Backup Strategy** | ✅ Backend handles | ⚠️ Must backup keys | ⚠️ Must backup keys |
| **Cost** | ⚠️ Backend costs | ✅ Free | ✅ Free (AGE) / ⚠️ KMS costs |
| **Vendor Lock-in** | Low (many backends) | None | Low (AGE) / Medium (KMS) |
| **Learning Curve** | Medium | Low | Medium |
| **Maturity** | ⭐⭐⭐⭐⭐ CNCF Incubating | ⭐⭐⭐⭐ Stable | ⭐⭐⭐⭐ Stable |
| **Community** | Very Active | Active | Active |
| **ArgoCD Support** | ✅ Native | ✅ Native | ⚠️ Plugin required |
| **Flux Support** | ✅ Native | ✅ Native | ✅ Built-in |
| **Disaster Recovery** | ✅ Backend backup | ⚠️ Key backup required | ⚠️ Key backup required |
| **Compliance** | ✅ Full audit trail | ⚠️ Limited | ⚠️ Limited |
| **Observability** | ✅ Prometheus metrics | ⚠️ Basic | ⚠️ None |

### Use Case Fit

#### **External Secrets Operator** ✅
- Cloud-native applications (AWS, Azure, GCP)
- Multi-cluster environments
- Automatic secret rotation required
- Strict compliance/audit requirements
- Centralized secret management
- Large teams (>20 people)

#### **Sealed Secrets** ✅
- Pure GitOps workflow
- Simple setup (no external dependencies)
- Small to medium teams (<20 people)
- On-premises/bare-metal
- Cost-sensitive (no cloud costs)
- Straightforward secret management

#### **SOPS** ✅
- Git-centric workflow
- Multi-environment (dev/staging/prod with different keys)
- Partial encryption needed (config files with secrets)
- Already using Flux with SOPS
- Fine-grained access control (file-level)
- Non-Kubernetes secrets (env files, configs)

---

## Decision Framework

### Decision Tree

```
START: Need to manage Kubernetes secrets securely
│
├─ Using cloud provider (AWS/Azure/GCP)?
│  ├─ YES → Do you need automatic secret rotation?
│  │  ├─ YES → **External Secrets Operator** ✅
│  │  └─ NO  → Do you want pure GitOps (no external deps)?
│  │     ├─ YES → **Sealed Secrets** ✅
│  │     └─ NO  → **External Secrets Operator** ✅
│  │
│  └─ NO (on-prem/bare-metal)
│     ├─ Have HashiCorp Vault?
│     │  ├─ YES → **External Secrets Operator + Vault** ✅
│     │  └─ NO  → Continue...
│     │
│     └─ Need multi-cluster secret sharing?
│        ├─ YES → **SOPS with shared AGE keys** ✅
│        └─ NO  → **Sealed Secrets** (simplest) ✅
│
├─ Team size?
│  ├─ < 5 people → **Sealed Secrets** (simplicity)
│  ├─ 5-20 people → **External Secrets Operator** or **Sealed Secrets**
│  └─ > 20 people → **External Secrets Operator** (centralized management)
│
├─ Compliance requirements?
│  ├─ Strict audit trail needed → **External Secrets Operator + Vault** ✅
│  ├─ Moderate → **External Secrets Operator** or **SOPS**
│  └─ None → **Sealed Secrets** ✅
│
└─ Already using GitOps tool?
   ├─ ArgoCD → **External Secrets Operator** (native) or **Sealed Secrets**
   ├─ Flux → **SOPS** (built-in) or **External Secrets Operator**
   └─ None → **Sealed Secrets** (simplest setup)

**Default Recommendation: External Secrets Operator**
```

### Scenario-Based Recommendations

#### Scenario 1: Startup MVP (3-person team, AWS)
**Recommendation:** **Sealed Secrets**

**Rationale:**
- ✅ Simple setup (1 hour)
- ✅ No AWS Secrets Manager costs ($0.40/secret/month)
- ✅ Pure GitOps workflow
- ✅ Sufficient for small team
- ⚠️ Migrate to ESO when team grows

**Implementation:**
```bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml
brew install kubeseal
# Start encrypting secrets!
```

#### Scenario 2: Enterprise (100+ people, multi-cloud)
**Recommendation:** **External Secrets Operator**

**Rationale:**
- ✅ Centralized secret management
- ✅ Full audit trail (compliance)
- ✅ Automatic rotation
- ✅ Multi-cloud support (AWS + Azure)
- ✅ ClusterSecretStore for sharing
- ✅ Scales to hundreds of applications

**Implementation:**
```bash
# Deploy ESO
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets-system --create-namespace

# Configure AWS backend
# Configure Azure backend
# Create ClusterSecretStore
# Profit!
```

#### Scenario 3: Regulated Industry (Healthcare, Finance)
**Recommendation:** **External Secrets Operator + HashiCorp Vault**

**Rationale:**
- ✅ Full audit trail (who accessed what when)
- ✅ Dynamic secrets (time-limited credentials)
- ✅ Encryption at rest + in transit
- ✅ Compliance reports
- ✅ Secret versioning
- ✅ Disaster recovery (Vault snapshots)

**Implementation:**
```bash
# Deploy Vault with HA + auto-unseal
# Deploy ESO
# Configure Vault backend
# Implement rotation policies
# Enable audit logging
```

#### Scenario 4: Pure GitOps Purist (Flux, no external deps)
**Recommendation:** **SOPS with AGE**

**Rationale:**
- ✅ Everything in Git (single source of truth)
- ✅ No external dependencies
- ✅ Flux native support
- ✅ File-level encryption
- ✅ Git history = audit trail
- ⚠️ Manual rotation acceptable

**Implementation:**
```bash
# Generate AGE key
age-keygen -o key.txt

# Configure Flux
kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=key.txt

# Start encrypting secrets with sops!
```

#### Scenario 5: Multi-Cluster (10+ clusters)
**Recommendation:** **External Secrets Operator + ClusterSecretStore**

**Rationale:**
- ✅ Single backend for all clusters
- ✅ Consistent secret management
- ✅ Easy disaster recovery (restore backend)
- ✅ Centralized rotation
- ❌ Sealed Secrets = 10 separate key pairs

**Implementation:**
```bash
# Per cluster:
helm install external-secrets external-secrets/external-secrets

# Shared backend:
# AWS Secrets Manager (all clusters read from same backend)
# Or HashiCorp Vault with replication
```

---

## Migration Paths

### From Plain Secrets → Sealed Secrets

```bash
# Step 1: Install Sealed Secrets
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml
brew install kubeseal

# Step 2: Extract existing secrets
kubectl get secret my-secret -n webshop -o yaml > secret.yaml

# Step 3: Encrypt
kubeseal --format yaml < secret.yaml > sealed-secret.yaml

# Step 4: Delete old secret (optional, controller will override anyway)
kubectl delete secret my-secret -n webshop

# Step 5: Apply sealed secret
kubectl apply -f sealed-secret.yaml

# Step 6: Commit encrypted secret to Git
git add sealed-secret.yaml
git commit -m "Migrate to Sealed Secrets"
```

### From Sealed Secrets → External Secrets Operator

```bash
# Step 1: Store secrets in AWS Secrets Manager
# Extract current secrets
kubectl get secret postgres-credentials -n webshop -o json | \
  jq -r '.data.password' | base64 -d

# Create in AWS
aws secretsmanager create-secret \
  --name webshop/postgres \
  --secret-string '{"password":"<value-from-above>"}' \
  --region eu-west-1

# Step 2: Install ESO
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets-system --create-namespace

# Step 3: Create ExternalSecret
kubectl apply -f externalsecret.yaml

# Step 4: Verify sync
kubectl get externalsecret -n webshop
kubectl get secret postgres-credentials -n webshop

# Step 5: Remove SealedSecret
kubectl delete sealedsecret postgres-credentials -n webshop

# Step 6: Update Git repo (remove sealed-secret.yaml, add externalsecret.yaml)
git rm sealed-secret.yaml
git add externalsecret.yaml
git commit -m "Migrate to External Secrets Operator"
```

### From SOPS → External Secrets Operator

```bash
# Step 1: Decrypt SOPS secrets
sops -d secrets/postgres.enc.yaml > /tmp/postgres.yaml

# Step 2: Extract values
cat /tmp/postgres.yaml | yq eval '.stringData.password' -

# Step 3: Store in backend (AWS example)
aws secretsmanager create-secret \
  --name webshop/postgres \
  --secret-string '{"password":"<value>"}' \
  --region eu-west-1

# Step 4: Create ExternalSecret (same as above)
# Step 5: Remove SOPS files from Git
# Step 6: Update Flux/ArgoCD to stop decrypting SOPS
```

---

## Best Practices

### General Best Practices

#### 1. **Least Privilege Access**
```yaml
# ESO: Restrict IAM/RBAC to specific secrets
# Bad: secretsmanager:GetSecretValue on *
# Good: secretsmanager:GetSecretValue on arn:aws:secretsmanager:*:*:secret:webshop/*
```

#### 2. **Separate Secrets per Environment**
```
secrets/
├── dev/
│   └── database.yaml
├── staging/
│   └── database.yaml
└── production/
    └── database.yaml
```

#### 3. **Rotation Strategy**
```yaml
# ESO: Enable automatic rotation
spec:
  refreshInterval: 1h  # Check for updates every hour

# Sealed Secrets / SOPS: Manual rotation schedule
# - Rotate API keys every 90 days
# - Rotate database passwords every 180 days
# - Document rotation dates in comments
```

#### 4. **Backup Strategy**

**Sealed Secrets:**
```bash
# Backup encryption key
kubectl get secret -n kube-system \
  -l sealedsecrets.bitnami.com/sealed-secrets-key=active \
  -o yaml > sealed-secrets-key-$(date +%Y%m%d).yaml

# Store in:
# - 1Password vault
# - Offline encrypted USB drive
# - AWS Secrets Manager (ironic but secure!)
```

**SOPS:**
```bash
# Backup AGE private key
cp key.txt key-backup-$(date +%Y%m%d).txt

# Store in:
# - 1Password vault
# - Hardware security key (YubiKey with age-plugin-yubikey)
# - AWS Secrets Manager
```

**ESO:**
```bash
# Backend handles backups, but backup connection configs
kubectl get secretstore -A -o yaml > secretstore-backup.yaml
kubectl get externalsecret -A -o yaml > externalsecret-backup.yaml
```

#### 5. **Monitoring and Alerting**

**ESO:**
```yaml
# Prometheus alerts
- alert: ExternalSecretSyncFailure
  expr: external_secrets_sync_calls_error > 0
  for: 10m
  annotations:
    summary: "External Secret sync failing"

- alert: ExternalSecretNotSynced
  expr: time() - external_secrets_sync_last_success > 3600
  annotations:
    summary: "External Secret not synced in 1 hour"
```

**Sealed Secrets:**
```bash
# Monitor controller
kubectl logs -n kube-system -l name=sealed-secrets-controller --tail=100

# Check SealedSecret status
kubectl get sealedsecret -A
```

#### 6. **Testing in Non-Production First**
```bash
# Always test secret changes in dev/staging first
kubectl apply -f sealed-secret.yaml --dry-run=server
kubectl apply -f externalsecret.yaml -n dev-webshop
# Wait 5 minutes, verify, then promote to production
```

### Security Hardening

#### ESO Security
```yaml
# Use WorkloadIdentity (GKE) or IRSA (EKS)
# NEVER use long-lived credentials in Secrets!

# Bad: Static AWS credentials
env:
  - name: AWS_ACCESS_KEY_ID
    valueFrom:
      secretKeyRef:
        name: aws-credentials
        key: access-key

# Good: IRSA (EKS)
serviceAccountName: external-secrets-sa  # Has IAM role attached
```

#### Sealed Secrets Security
```yaml
# Use strict scoping
kubeseal --scope strict  # Default, most secure

# Backup key to secure location
# Enable key rotation (automatic every 30 days)

# Audit who can access unsealing key
kubectl get secret -n kube-system sealed-secrets-key -o yaml
kubectl auth can-i get secret sealed-secrets-key -n kube-system --as john.doe
```

#### SOPS Security
```bash
# Use age instead of GPG (simpler, more secure)
# Rotate keys annually
# Store keys in hardware security keys (YubiKey)

# age-plugin-yubikey
age-plugin-yubikey --generate > key-yubikey.txt
sops -e --age $(cat key-yubikey.txt | grep public) secret.yaml
```

### Disaster Recovery

#### Scenario: Lost Sealed Secrets Key

**Prevention:**
```bash
# Backup key BEFORE disaster
kubectl get secret -n kube-system \
  -l sealedsecrets.bitnami.com/sealed-secrets-key=active \
  -o yaml > sealed-secrets-key-backup.yaml
```

**Recovery:**
```bash
# Restore key to new cluster
kubectl apply -f sealed-secrets-key-backup.yaml

# Restart controller
kubectl delete pod -n kube-system -l name=sealed-secrets-controller

# All SealedSecrets will now decrypt successfully
kubectl apply -f sealed-secrets/
```

**If key is truly lost:**
```bash
# ⚠️ Nuclear option: Re-encrypt all secrets
# 1. Extract plaintext secrets from old cluster (if still running)
kubectl get secret -n webshop -o yaml > secrets-backup.yaml

# 2. Install Sealed Secrets in new cluster (generates new key)
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

# 3. Re-encrypt all secrets with new key
for secret in secrets-backup/*.yaml; do
  kubeseal --format yaml < $secret > sealed-$(basename $secret)
done

# 4. Commit new SealedSecrets to Git
git add sealed-*.yaml
git commit -m "Re-encrypt secrets with new key"
```

#### Scenario: ESO Backend Unavailable

**Prevention:**
```yaml
# Configure fallback
spec:
  refreshInterval: 1h
  target:
    creationPolicy: Owner  # Secret persists even if backend fails
```

**Recovery:**
```bash
# Secrets remain in cluster (not deleted)
kubectl get secret postgres-credentials -n webshop  # Still works!

# Fix backend connectivity
# ESO will automatically resume sync
```

---

## Related Documentation

- 🔐 [RBAC Examples](../../manifests/rbac/README.md) - Identity-based access control
- 🔐 [Network Policy Examples](../../manifests/networking/README.md) - Network-level security
- 🧪 [Security Testing](../../tests/security/README.md) - Automated validation
- 📖 [GitOps Comparison](GITOPS_COMPARISON.md) - ArgoCD vs Flux vs GitLab
- 📘 [ArgoCD Guide](ARGOCD_GUIDE.md) - GitOps with ArgoCD
- 📘 [Flux Guide](FLUX_GUIDE.md) - GitOps with Flux
- 🎯 [Decision Matrix](../MATRIX.md) - Complete tool recommendations

---

**Last Updated**: December 28, 2025  
**Maintainers**: Platform Engineering Team  
**Status**: Production Ready ✅

**Quick Links:**
- [External Secrets Operator Docs](https://external-secrets.io/)
- [Sealed Secrets GitHub](https://github.com/bitnami-labs/sealed-secrets)
- [SOPS GitHub](https://github.com/getsops/sops)
- [AGE Encryption](https://github.com/FiloSottile/age)
