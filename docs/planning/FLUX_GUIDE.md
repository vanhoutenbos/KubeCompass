# Flux Implementation Guide

**Complete hands-on guide for Flux v2 GitOps deployment**

---

## Table of Contents

1. [Why Flux?](#why-flux)
2. [Architecture Overview](#architecture-overview)
3. [Installation & Bootstrap](#installation--bootstrap)
4. [First Application](#first-application)
5. [Multi-Cluster Setup](#multi-cluster-setup)
6. [Image Automation](#image-automation)
7. [Production Hardening](#production-hardening)
8. [Troubleshooting](#troubleshooting)

---

## Why Flux?

### Best For

✅ **Pure GitOps** practitioners (Git as single source of truth)  
✅ Teams comfortable with **CLI-driven** workflows  
✅ **Lightweight** architecture needs (~200MB RAM)  
✅ **Modular** design (install only what you need)  
✅ Organizations wanting **zero vendor lock-in**

### Not Best For

❌ Teams requiring **rich UI** (use ArgoCD instead)  
❌ Non-technical users needing **visual feedback**  
❌ Organizations wanting **out-of-the-box SSO/RBAC**

---

## Architecture Overview

### Components (Modular)

```
┌──────────────────────────────────────────────────────────────┐
│                        Flux v2 Architecture                   │
├──────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌────────────────┐                                          │
│  │                │                                          │
│  │   Git Repo     │◄──────────────┐                         │
│  │                │                │                         │
│  └────────────────┘                │                         │
│                                     │                         │
│                          ┌──────────┴──────────┐            │
│                          │                      │            │
│                          │  Source Controller   │            │
│                          │  (Git/Helm/OCI)      │            │
│                          │                      │            │
│                          └──────────┬───────────┘            │
│                                     │                         │
│                  ┌──────────────────┼──────────────────┐     │
│                  │                  │                   │     │
│         ┌────────▼────────┐ ┌──────▼───────┐ ┌────────▼──────┐
│         │                 │ │              │ │                │
│         │   Kustomize     │ │     Helm     │ │  Notification  │
│         │   Controller    │ │  Controller  │ │   Controller   │
│         │                 │ │              │ │                │
│         └────────┬────────┘ └──────┬───────┘ └────────────────┘
│                  │                  │                         │
│                  └──────────────────┼───────────────┐         │
│                                     │                │         │
│                            ┌────────▼────────┐      │         │
│                            │                 │      │         │
│                            │   Kubernetes    │◄─────┘         │
│                            │    Cluster      │                │
│                            │                 │                │
│                            └─────────────────┘                │
└──────────────────────────────────────────────────────────────┘
```

### Controllers (Install What You Need)

| Controller | Purpose | Required | Resource Usage |
|------------|---------|----------|----------------|
| **source-controller** | Fetches Git/Helm/OCI sources | ✅ Yes | ~50MB RAM, 0.1 CPU |
| **kustomize-controller** | Applies Kustomize manifests | ✅ Yes | ~50MB RAM, 0.1 CPU |
| **helm-controller** | Manages Helm releases | ⚠️ If using Helm | ~50MB RAM, 0.1 CPU |
| **notification-controller** | Sends alerts/webhooks | ⚠️ Optional | ~30MB RAM, 0.05 CPU |
| **image-reflector-controller** | Scans image registries | ⚠️ Optional | ~30MB RAM, 0.05 CPU |
| **image-automation-controller** | Updates Git with new images | ⚠️ Optional | ~30MB RAM, 0.05 CPU |

**Total (all components)**: ~240MB RAM, 0.5 CPU  
**Minimal (source + kustomize)**: ~100MB RAM, 0.2 CPU

---

## Installation & Bootstrap

### Prerequisites

```bash
# 1. Kubernetes cluster (v1.24+)
kubectl version --client

# 2. kubectl access with admin permissions
kubectl auth can-i create namespace

# 3. GitHub/GitLab account with repository access
# 4. Personal Access Token with repo permissions
```

### Install Flux CLI

```bash
# macOS
brew install fluxcd/tap/flux

# Linux
curl -s https://fluxcd.io/install.sh | sudo bash

# Windows (PowerShell)
choco install flux

# Or manual download
curl -s https://raw.githubusercontent.com/fluxcd/flux2/main/install/flux.sh | bash
```

### Verify Installation

```bash
flux --version
flux check --pre
```

### Bootstrap Flux (GitHub)

**This is the GitOps way** - Flux will commit its own configuration to Git!

```bash
# Export GitHub token
export GITHUB_TOKEN=<your-github-pat>

# Bootstrap Flux
flux bootstrap github \
  --owner=myorg \
  --repository=fleet-infra \
  --branch=main \
  --path=clusters/production \
  --personal \
  --token-auth

# What this does:
# 1. Creates 'fleet-infra' repo if not exists
# 2. Installs Flux components in cluster
# 3. Commits Flux manifests to 'clusters/production/'
# 4. Configures Flux to sync from this repo
# 5. Self-manages Flux (Flux watches its own Git repo!)
```

### Bootstrap Flux (GitLab)

```bash
export GITLAB_TOKEN=<your-gitlab-pat>

flux bootstrap gitlab \
  --owner=myorg \
  --repository=fleet-infra \
  --branch=main \
  --path=clusters/production \
  --token-auth
```

### Bootstrap Flux (Generic Git)

```bash
flux bootstrap git \
  --url=ssh://git@github.com/myorg/fleet-infra \
  --branch=main \
  --path=clusters/production \
  --private-key-file=~/.ssh/id_rsa
```

### Verify Bootstrap

```bash
# Check Flux installation
flux check

# List GitRepository sources
flux get sources git

# List Kustomizations
flux get kustomizations

# Watch reconciliation
flux logs --follow --all-namespaces
```

Expected output:
```
✔ flux-system successfully reconciled
✔ source-controller: deployment ready
✔ kustomize-controller: deployment ready
✔ helm-controller: deployment ready
✔ notification-controller: deployment ready
```

---

## First Application

### Step 1: Create Application Repository

```bash
cd ~/flux-demo
git init

# Create Kustomize structure
mkdir -p nginx/{base,overlays/production}

# Base deployment
cat <<EOF > nginx/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
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

# Base service
cat <<EOF > nginx/base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  type: ClusterIP
  ports:
  - port: 80
  selector:
    app: nginx
EOF

# Base kustomization
cat <<EOF > nginx/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
EOF

# Production overlay
cat <<EOF > nginx/overlays/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
bases:
- ../../base
patchesStrategicMerge:
- replica-patch.yaml
EOF

cat <<EOF > nginx/overlays/production/replica-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 5
EOF

# Commit and push
git add nginx/
git commit -m "Add nginx application"
git remote add origin https://github.com/myorg/flux-demo.git
git push -u origin main
```

### Step 2: Add GitRepository Source

```bash
# Create source pointing to your app repo
flux create source git nginx-app \
  --url=https://github.com/myorg/flux-demo \
  --branch=main \
  --interval=1m \
  --export > ~/fleet-infra/clusters/production/nginx-source.yaml

# Commit to fleet repo
cd ~/fleet-infra
git add clusters/production/nginx-source.yaml
git commit -m "Add nginx GitRepository source"
git push
```

Or manually create:

```yaml
# clusters/production/nginx-source.yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: nginx-app
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/myorg/flux-demo
  ref:
    branch: main
```

### Step 3: Create Kustomization

```bash
# Create Kustomization pointing to app path
flux create kustomization nginx-app \
  --source=GitRepository/nginx-app \
  --path="./nginx/overlays/production" \
  --prune=true \
  --interval=5m \
  --target-namespace=default \
  --export > ~/fleet-infra/clusters/production/nginx-kustomization.yaml

cd ~/fleet-infra
git add clusters/production/nginx-kustomization.yaml
git commit -m "Add nginx Kustomization"
git push
```

Or manually:

```yaml
# clusters/production/nginx-kustomization.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: nginx-app
  namespace: flux-system
spec:
  interval: 5m
  path: ./nginx/overlays/production
  prune: true
  sourceRef:
    kind: GitRepository
    name: nginx-app
  targetNamespace: default
```

### Step 4: Verify Deployment

```bash
# Watch Flux reconcile
flux logs --follow

# Check source status
flux get sources git nginx-app

# Check kustomization status
flux get kustomizations nginx-app

# Check deployed resources
kubectl get deployments,svc -l app=nginx
```

### Step 5: Test GitOps Workflow

```bash
# Update replicas in Git
cd ~/flux-demo
sed -i 's/replicas: 5/replicas: 10/' nginx/overlays/production/replica-patch.yaml
git add nginx/overlays/production/replica-patch.yaml
git commit -m "Scale nginx to 10 replicas"
git push

# Flux will detect change within 1 minute (source interval)
# Then reconcile within 5 minutes (kustomization interval)

# Or force immediate reconciliation
flux reconcile source git nginx-app
flux reconcile kustomization nginx-app

# Verify scaling
kubectl get deployment nginx
```

---

## Multi-Cluster Setup

### Approach 1: Repository per Cluster

Each cluster has its own bootstrap:

```bash
# Cluster 1 (production)
flux bootstrap github \
  --owner=myorg \
  --repository=fleet-infra \
  --branch=main \
  --path=clusters/production

# Cluster 2 (staging)
flux bootstrap github \
  --owner=myorg \
  --repository=fleet-infra \
  --branch=main \
  --path=clusters/staging

# Cluster 3 (dev)
flux bootstrap github \
  --owner=myorg \
  --repository=fleet-infra \
  --branch=main \
  --path=clusters/dev
```

**Repository Structure**:
```
fleet-infra/
├── clusters/
│   ├── production/
│   │   ├── flux-system/
│   │   ├── apps.yaml           # Points to apps/ dir
│   │   └── infrastructure.yaml # Points to infra/ dir
│   ├── staging/
│   │   └── ...
│   └── dev/
│       └── ...
├── apps/
│   ├── base/
│   │   └── nginx/
│   └── production/
│       └── nginx/
└── infrastructure/
    ├── base/
    └── production/
```

### Approach 2: Cluster API + Flux

```yaml
# Infrastructure Cluster bootstrapped with Flux
# Then provisions workload clusters via Cluster API

apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: cluster-production
  namespace: flux-system
spec:
  interval: 10m
  path: ./clusters/production
  prune: true
  sourceRef:
    kind: GitRepository
    name: fleet-infra
  postBuild:
    substitute:
      cluster_name: production
      region: us-west-2
```

---

## Image Automation

### Enable Image Automation Controllers

```bash
# These are not installed by default
flux install --components-extra=image-reflector-controller,image-automation-controller
```

### Configure Image Repository Scanning

```yaml
# clusters/production/image-repo.yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageRepository
metadata:
  name: nginx
  namespace: flux-system
spec:
  image: nginx
  interval: 1m
```

### Define Image Policy

```yaml
# clusters/production/image-policy.yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImagePolicy
metadata:
  name: nginx
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: nginx
  policy:
    semver:
      range: '>=1.25.0 <2.0.0'
```

### Enable Image Update Automation

```yaml
# clusters/production/image-update.yaml
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImageUpdateAutomation
metadata:
  name: nginx-auto-update
  namespace: flux-system
spec:
  interval: 5m
  sourceRef:
    kind: GitRepository
    name: flux-demo
  git:
    checkout:
      ref:
        branch: main
    commit:
      author:
        email: fluxbot@myorg.com
        name: Flux Bot
      messageTemplate: |
        Automated image update
        
        Automation name: {{ .AutomationObject }}
        
        Files:
        {{ range $filename, $_ := .Updated.Files -}}
        - {{ $filename }}
        {{ end -}}
        
        Objects:
        {{ range $resource, $_ := .Updated.Objects -}}
        - {{ $resource.Kind }} {{ $resource.Name }}
        {{ end -}}
    push:
      branch: main
  update:
    path: ./nginx/base
    strategy: Setters
```

### Mark Image for Auto-Update

```yaml
# nginx/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:1.25.0 # {"$imagepolicy": "flux-system:nginx"}
```

When a new nginx image matching the semver policy is detected, Flux will:
1. Update the image tag in Git
2. Commit the change
3. Reconcile the deployment

---

## Helm Releases with Flux

### Add Helm Repository

```yaml
# clusters/production/helm-sources.yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRepository
metadata:
  name: bitnami
  namespace: flux-system
spec:
  interval: 1h
  url: https://charts.bitnami.com/bitnami
```

### Create HelmRelease

```yaml
# clusters/production/postgres-release.yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: postgresql
  namespace: default
spec:
  interval: 5m
  chart:
    spec:
      chart: postgresql
      version: '12.x.x'
      sourceRef:
        kind: HelmRepository
        name: bitnami
        namespace: flux-system
  values:
    auth:
      postgresPassword: changeme
    primary:
      persistence:
        size: 10Gi
```

### Helm Release with Git Source

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: webshop-charts
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/myorg/webshop-charts
  ref:
    branch: main

---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: webshop
  namespace: default
spec:
  interval: 5m
  chart:
    spec:
      chart: ./charts/webshop
      sourceRef:
        kind: GitRepository
        name: webshop-charts
        namespace: flux-system
  values:
    replicaCount: 5
    image:
      tag: v2.0.0
```

---

## Production Hardening

### High Availability

```yaml
# Increase controller replicas
apiVersion: apps/v1
kind: Deployment
metadata:
  name: source-controller
  namespace: flux-system
spec:
  replicas: 2

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kustomize-controller
  namespace: flux-system
spec:
  replicas: 2
```

### Resource Limits

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- gotk-components.yaml
patches:
- target:
    kind: Deployment
    name: "(source-controller|kustomize-controller)"
  patch: |
    - op: add
      path: /spec/template/spec/containers/0/resources
      value:
        requests:
          cpu: 100m
          memory: 64Mi
        limits:
          cpu: 500m
          memory: 512Mi
```

### Notifications (Slack)

```yaml
# clusters/production/slack-alert.yaml
apiVersion: notification.toolkit.fluxcd.io/v1beta1
kind: Provider
metadata:
  name: slack
  namespace: flux-system
spec:
  type: slack
  channel: platform-alerts
  secretRef:
    name: slack-webhook

---
apiVersion: notification.toolkit.fluxcd.io/v1beta1
kind: Alert
metadata:
  name: on-call-alerts
  namespace: flux-system
spec:
  providerRef:
    name: slack
  eventSeverity: error
  eventSources:
  - kind: Kustomization
    name: '*'
  - kind: HelmRelease
    name: '*'
```

### Monitoring with Prometheus

```yaml
# ServiceMonitor for Flux controllers
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: flux-system
  namespace: flux-system
spec:
  selector:
    matchLabels:
      app: flux
  endpoints:
  - port: http-prom
```

---

## Troubleshooting

### Common Issues

**Kustomization Not Reconciling**
```bash
# Check status
flux get kustomizations

# Get detailed events
flux describe kustomization myapp

# Force reconciliation
flux reconcile kustomization myapp --with-source

# Check logs
flux logs --kind=Kustomization --name=myapp
```

**Source Repository Not Updating**
```bash
# Check source status
flux get sources git

# Describe source
flux describe source git myrepo

# Force refresh
flux reconcile source git myrepo

# Check credentials
kubectl get secret -n flux-system myrepo -o yaml
```

**Image Automation Not Working**
```bash
# Check image repository
flux get image repository

# Check image policy
flux get image policy

# Check image update automation
flux get image update

# Reconcile all
flux reconcile image repository nginx
flux reconcile image policy nginx
flux reconcile image update nginx-auto-update
```

---

## Related Documentation

- 📊 [GitOps Comparison](GITOPS_COMPARISON.md) - Flux vs ArgoCD vs GitLab
- 📖 [ArgoCD Guide](ARGOCD_GUIDE.md) - Alternative GitOps tool
- 🔧 [Kind Setup](../../kind/README.md) - Local testing
- 📚 [Getting Started](../GETTING_STARTED.md) - Complete walkthrough

---

**Last Updated**: December 28, 2025  
**Official Docs**: https://fluxcd.io/flux/
