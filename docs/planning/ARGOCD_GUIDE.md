# ArgoCD Implementation Guide

**Complete hands-on guide for ArgoCD deployment and configuration**

---

## Table of Contents

1. [Why ArgoCD?](#why-argocd)
2. [Architecture Overview](#architecture-overview)
3. [Installation](#installation)
4. [First Application](#first-application)
5. [Multi-Cluster Setup](#multi-cluster-setup)
6. [RBAC Configuration](#rbac-configuration)
7. [Progressive Delivery with Argo Rollouts](#progressive-delivery)
8. [Production Hardening](#production-hardening)
9. [Troubleshooting](#troubleshooting)

---

## Why ArgoCD?

### Best For

✅ Teams wanting **UI + CLI** for GitOps  
✅ Organizations with **multiple teams** needing RBAC  
✅ **Multi-cluster** Kubernetes environments  
✅ **Progressive delivery** with canary/blue-green deployments  
✅ Developers who prefer **visual feedback**

### Not Best For

❌ Pure GitOps practitioners (prefer Flux)  
❌ Organizations wanting **minimal components** (Flux is lighter)  
❌ Teams comfortable with **CLI-only** workflows

---

## Architecture Overview

### Components

```
┌─────────────────────────────────────────────────────────────┐
│                         ArgoCD Architecture                  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐          ┌──────────────┐                │
│  │              │          │              │                │
│  │  Git Repo    │◄─────────┤ Repo Server  │                │
│  │              │          │              │                │
│  └──────────────┘          └───────┬──────┘                │
│                                     │                        │
│                                     ▼                        │
│  ┌──────────────┐          ┌──────────────┐                │
│  │              │          │              │                │
│  │  Redis       │◄─────────┤  API Server  │◄──── UI/CLI   │
│  │  (cache)     │          │              │                │
│  └──────────────┘          └───────┬──────┘                │
│                                     │                        │
│                                     ▼                        │
│                            ┌──────────────┐                │
│                            │              │                │
│                            │ Application  │                │
│                            │ Controller   │                │
│                            │              │                │
│                            └───────┬──────┘                │
│                                     │                        │
│                                     ▼                        │
│                            ┌──────────────┐                │
│                            │              │                │
│                            │  Kubernetes  │                │
│                            │   Cluster    │                │
│                            └──────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

### Component Roles

| Component | Purpose | Resource Usage |
|-----------|---------|----------------|
| **argocd-server** | API/UI server, handles web requests | ~100MB RAM, 0.1 CPU |
| **argocd-repo-server** | Clones Git repos, renders manifests | ~200MB RAM, 0.2 CPU |
| **argocd-application-controller** | Monitors applications, syncs state | ~150MB RAM, 0.2 CPU |
| **argocd-dex-server** | SSO/OIDC authentication | ~50MB RAM, 0.05 CPU |
| **argocd-redis** | Caching layer for performance | ~50MB RAM, 0.05 CPU |

**Total**: ~550MB RAM, 0.6 CPU

---

## Installation

### Prerequisites

```bash
# 1. Kubernetes cluster (v1.24+)
kubectl version --client

# 2. kubectl access with admin permissions
kubectl auth can-i create namespace

# 3. Helm (optional, for Helm-based install)
helm version
```

### Option 1: Manifest-Based Installation (Recommended for Learning)

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# Get initial admin password
argocd admin initial-password -n argocd

# Port-forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Access UI: https://localhost:8080  
Username: `admin`  
Password: (from `argocd admin initial-password` command)

### Option 2: Helm Installation (Recommended for Production)

```bash
# Add Helm repo
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install with custom values
helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --set server.service.type=LoadBalancer \
  --set server.ingress.enabled=true \
  --set server.ingress.hosts[0]=argocd.example.com \
  --set redis-ha.enabled=true \
  --set controller.replicas=2 \
  --set server.replicas=2 \
  --set repoServer.replicas=2

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Install ArgoCD CLI

```bash
# macOS
brew install argocd

# Linux
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# Windows (PowerShell)
$version = (Invoke-RestMethod https://api.github.com/repos/argoproj/argo-cd/releases/latest).tag_name
Invoke-WebRequest -Uri "https://github.com/argoproj/argo-cd/releases/download/$version/argocd-windows-amd64.exe" -OutFile "$env:USERPROFILE\bin\argocd.exe"
```

### Initial Configuration

```bash
# Login via CLI
argocd login localhost:8080 --username admin --password <initial-password> --insecure

# Change admin password
argocd account update-password

# Add Git repository
argocd repo add https://github.com/myorg/myrepo --username myuser --password <token>

# Or use SSH
argocd repo add git@github.com:myorg/myrepo.git --ssh-private-key-path ~/.ssh/id_rsa
```

---

## First Application

### Step 1: Prepare Git Repository

Create a repository with Kubernetes manifests:

```bash
mkdir -p ~/argocd-demo
cd ~/argocd-demo
git init

# Create simple application
mkdir -p manifests
cat <<EOF > manifests/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

cat <<EOF > manifests/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
EOF

# Commit and push
git add manifests/
git commit -m "Initial nginx application"
git remote add origin https://github.com/myorg/argocd-demo.git
git push -u origin main
```

### Step 2: Create ArgoCD Application (UI Method)

1. Open ArgoCD UI: https://localhost:8080
2. Click **"+ New App"**
3. Fill in details:
   - **Application Name**: nginx-demo
   - **Project**: default
   - **Sync Policy**: Automatic
   - **Repository URL**: https://github.com/myorg/argocd-demo
   - **Path**: manifests
   - **Cluster**: https://kubernetes.default.svc
   - **Namespace**: default
4. Click **Create**

### Step 3: Create ArgoCD Application (CLI Method)

```bash
argocd app create nginx-demo \
  --repo https://github.com/myorg/argocd-demo \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Check status
argocd app get nginx-demo

# Manual sync if needed
argocd app sync nginx-demo
```

### Step 4: Create ArgoCD Application (Declarative Method - GitOps!)

```yaml
# argocd/applications/nginx-demo.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nginx-demo
  namespace: argocd
spec:
  project: default
  
  source:
    repoURL: https://github.com/myorg/argocd-demo
    targetRevision: HEAD
    path: manifests
  
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  
  syncPolicy:
    automated:
      prune: true      # Delete resources not in Git
      selfHeal: true   # Force sync when cluster state differs
    syncOptions:
    - CreateNamespace=true
```

Apply it:

```bash
kubectl apply -f argocd/applications/nginx-demo.yaml
```

### Step 5: Verify Deployment

```bash
# Check app status
argocd app get nginx-demo

# Check pods
kubectl get pods -l app=nginx

# Check service
kubectl get svc nginx
```

---

## Multi-Cluster Setup

### Add External Clusters

```bash
# Method 1: Using kubeconfig context
kubectl config get-contexts
argocd cluster add my-prod-cluster

# Method 2: Manual cluster registration
argocd cluster add my-cluster \
  --server https://my-cluster-api:6443 \
  --service-account argocd-manager

# List clusters
argocd cluster list
```

### ApplicationSet for Multi-Cluster

```yaml
# argocd/applicationsets/webshop-multi-cluster.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: webshop
  namespace: argocd
spec:
  generators:
  - clusters:
      selector:
        matchLabels:
          environment: production
  
  template:
    metadata:
      name: 'webshop-{{name}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/myorg/webshop
        targetRevision: HEAD
        path: 'manifests/{{metadata.labels.environment}}'
      destination:
        server: '{{server}}'
        namespace: webshop
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - CreateNamespace=true
```

### Progressive Rollout Across Clusters

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: webshop-progressive
spec:
  generators:
  - list:
      elements:
      - cluster: dev
        weight: "100"
      - cluster: staging
        weight: "50"
        waitTime: "1h"
      - cluster: production
        weight: "25"
        waitTime: "24h"
  
  strategy:
    type: RollingSync
    rollingSync:
      steps:
      - matchExpressions:
        - key: cluster
          operator: In
          values:
          - dev
      - matchExpressions:
        - key: cluster
          operator: In
          values:
          - staging
      - matchExpressions:
        - key: cluster
          operator: In
          values:
          - production
```

---

## RBAC Configuration

### Project-Based Isolation

```yaml
# argocd/projects/webshop.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: webshop
  namespace: argocd
spec:
  description: Webshop application project
  
  # Allowed source repositories
  sourceRepos:
  - 'https://github.com/myorg/webshop*'
  
  # Allowed destination clusters
  destinations:
  - namespace: 'webshop-*'
    server: '*'
  
  # Allowed Kubernetes resources
  clusterResourceWhitelist:
  - group: ''
    kind: Namespace
  namespaceResourceWhitelist:
  - group: 'apps'
    kind: Deployment
  - group: 'apps'
    kind: StatefulSet
  - group: ''
    kind: Service
  - group: ''
    kind: ConfigMap
  - group: ''
    kind: Secret
```

### RBAC Policy Configuration

```yaml
# argocd-rbac-cm ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.default: role:readonly
  
  policy.csv: |
    # Developers role
    p, role:developers, applications, get, webshop/*, allow
    p, role:developers, applications, sync, webshop/*, allow
    p, role:developers, applications, override, webshop/*, deny
    p, role:developers, applications, delete, webshop/*, deny
    
    # Platform Engineers role
    p, role:platform-engineers, applications, *, */*, allow
    p, role:platform-engineers, clusters, *, *, allow
    p, role:platform-engineers, repositories, *, *, allow
    
    # Bind OIDC groups to roles
    g, myorg:developers, role:developers
    g, myorg:platform-team, role:platform-engineers
```

### SSO Integration (OIDC)

```yaml
# argocd-cm ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  url: https://argocd.example.com
  
  dex.config: |
    connectors:
    - type: oidc
      id: google
      name: Google
      config:
        issuer: https://accounts.google.com
        clientID: $dex.google.clientId
        clientSecret: $dex.google.clientSecret
        redirectURI: https://argocd.example.com/api/dex/callback
```

---

## Progressive Delivery

### Install Argo Rollouts

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# Install Rollouts kubectl plugin
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x kubectl-argo-rollouts-linux-amd64
sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
```

### Canary Deployment Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: webshop
spec:
  replicas: 10
  revisionHistoryLimit: 3
  
  selector:
    matchLabels:
      app: webshop
  
  template:
    metadata:
      labels:
        app: webshop
    spec:
      containers:
      - name: webshop
        image: myorg/webshop:v2.0.0
        ports:
        - containerPort: 8080
  
  strategy:
    canary:
      steps:
      # 1. Deploy 10% traffic
      - setWeight: 10
      - pause: {duration: 5m}
      
      # 2. Deploy 25% traffic
      - setWeight: 25
      - pause: {duration: 10m}
      
      # 3. Deploy 50% traffic
      - setWeight: 50
      - pause: {duration: 15m}
      
      # 4. Deploy 75% traffic
      - setWeight: 75
      - pause: {duration: 10m}
      
      # 5. Full rollout
      - setWeight: 100
      
      # Analysis for automatic rollback
      analysis:
        templates:
        - templateName: webshop-error-rate
        args:
        - name: service-name
          value: webshop
```

### Blue-Green Deployment

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: webshop-bg
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webshop
  
  template:
    metadata:
      labels:
        app: webshop
    spec:
      containers:
      - name: webshop
        image: myorg/webshop:v2.0.0
  
  strategy:
    blueGreen:
      activeService: webshop-active
      previewService: webshop-preview
      autoPromotionEnabled: false
      scaleDownDelaySeconds: 300
```

---

## Production Hardening

### High Availability Setup

```yaml
# values.yaml for Helm
controller:
  replicas: 2
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 1Gi

server:
  replicas: 3
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

repoServer:
  replicas: 2
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

redis-ha:
  enabled: true
  replicas: 3
```

### Backup Strategy

```bash
# Backup ArgoCD configuration
kubectl get applications -n argocd -o yaml > argocd-apps-backup.yaml
kubectl get appprojects -n argocd -o yaml > argocd-projects-backup.yaml
kubectl get secrets -n argocd -o yaml > argocd-secrets-backup.yaml

# Restore
kubectl apply -f argocd-apps-backup.yaml
kubectl apply -f argocd-projects-backup.yaml
kubectl apply -f argocd-secrets-backup.yaml
```

### Monitoring with Prometheus

```yaml
# ServiceMonitor for ArgoCD
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: argocd-metrics
  namespace: argocd
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-metrics
  endpoints:
  - port: metrics
```

---

## Troubleshooting

### Common Issues

**Application Stuck in "Progressing"**
```bash
# Check sync status
argocd app get myapp

# Check controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# Force refresh
argocd app get myapp --refresh
```

**Out of Sync Despite Auto-Sync**
```bash
# Check if self-heal is enabled
argocd app get myapp | grep selfHeal

# Enable self-heal
argocd app set myapp --self-heal

# Manual sync
argocd app sync myapp --force
```

**Repository Connection Issues**
```bash
# Test repository connection
argocd repo get https://github.com/myorg/myrepo

# Update credentials
argocd repo rm https://github.com/myorg/myrepo
argocd repo add https://github.com/myorg/myrepo --username myuser --password <token>
```

---

## Related Documentation

- 📊 [GitOps Comparison](GITOPS_COMPARISON.md) - ArgoCD vs Flux vs GitLab
- 📖 [Flux Guide](FLUX_GUIDE.md) - Alternative GitOps tool
- 🔧 [Kind Setup](../../kind/README.md) - Local testing
- 📚 [Getting Started](../GETTING_STARTED.md) - Complete walkthrough

---

**Last Updated**: December 28, 2025  
**Official Docs**: https://argo-cd.readthedocs.io/
