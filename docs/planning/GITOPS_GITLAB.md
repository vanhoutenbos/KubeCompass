# GitOps with GitLab

GitLab offers multiple approaches to GitOps for Kubernetes. Here's how they work and how to test them locally.

## GitLab GitOps Options

### 1. GitLab Agent for Kubernetes (Recommended)

**What it is:**
- GitLab's native Kubernetes integration
- Agent runs **in** your cluster
- Pull-based GitOps (cluster pulls from GitLab)
- No cluster credentials stored in GitLab

**Architecture:**
```
GitLab Repository
    ↓ (agent pulls)
GitLab Agent (in cluster)
    ↓ (applies)
Kubernetes Resources
```

### 2. GitLab CI/CD with kubectl (Push-based)

**What it is:**
- Traditional CI/CD pipeline
- GitLab Runner pushes to cluster
- Requires cluster credentials in GitLab
- Not true "pull-based" GitOps

### 3. GitLab + ArgoCD/Flux (Hybrid)

**What it is:**
- Use GitLab for Git hosting
- Use ArgoCD or Flux for GitOps engine
- Best of both worlds

## Comparison with Dedicated GitOps Tools

| Feature | GitLab Agent | ArgoCD | Flux |
|---------|--------------|--------|------|
| **GitOps Model** | Pull-based | Pull-based | Pull-based |
| **UI** | GitLab (basic) | ⭐⭐⭐⭐⭐ Rich | ❌ Minimal |
| **Multi-cluster** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Helm Support** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Kustomize Support** | ✅ Yes | ✅ Yes | ✅ Yes |
| **SSO/RBAC** | GitLab native | ✅ Excellent | 🟡 Basic |
| **Maturity** | 🟡 Newer | ⭐⭐⭐⭐⭐ Mature | ⭐⭐⭐⭐ Mature |
| **CNCF Status** | ❌ Not CNCF | ✅ Graduated | ✅ Graduated |
| **Learning Curve** | Low (if GitLab user) | Medium | Medium-High |
| **Vendor Lock-in** | 🔴 GitLab | 🟢 Low | 🟢 Low |

## Decision Framework

### Choose GitLab Agent if:
- ✅ Already using GitLab (self-hosted or SaaS)
- ✅ Want single platform (Git + CI/CD + GitOps)
- ✅ Need tight GitLab integration
- ✅ Prefer simpler setup over advanced features
- ⚠️ Accept some vendor lock-in

### Choose ArgoCD if:
- ✅ Want best-in-class GitOps UI
- ✅ Need advanced sync strategies
- ✅ Want CNCF graduated project
- ✅ Platform agnostic (works with any Git provider)
- ✅ Need strong RBAC and multi-tenancy

### Choose Flux if:
- ✅ Want pure GitOps (no UI dependencies)
- ✅ Need GitOps toolkit approach
- ✅ Prefer CLI/automation over UI
- ✅ Want CNCF graduated project
- ✅ Need Flagger for progressive delivery

### Choose GitLab CI/CD (push-based) if:
- ✅ Simple deployments only
- ❌ Don't need true GitOps (not recommended for production)

## Setting up GitLab Agent on Kind Cluster

### Prerequisites
- Kind cluster running
- GitLab account (gitlab.com or self-hosted)
- kubectl configured
- GitLab repository for manifests

### Step 1: Create GitLab Agent Configuration

In your GitLab repository, create `.gitlab/agents/kubecompass/config.yaml`:

```yaml
# .gitlab/agents/kubecompass/config.yaml
gitops:
  # Path to Kubernetes manifests
  manifest_projects:
  - id: your-group/your-project
    paths:
    - glob: 'manifests/**/*.yaml'
    - glob: 'manifests/**/*.yml'
    reconcile_timeout: 3600s
    dry_run_strategy: none
    prune: true
    prune_timeout: 3600s
    prune_propagation_policy: foreground
    inventory_policy: must_match

ci_access:
  projects:
  - id: your-group/your-project
```

### Step 2: Register Agent in GitLab

1. Go to your GitLab project
2. Navigate to **Infrastructure → Kubernetes clusters**
3. Click **Connect a cluster (agent)**
4. Select **kubecompass** agent
5. Copy the installation command

### Step 3: Install Agent in Kind Cluster

```bash
# The command from GitLab looks like this:
helm repo add gitlab https://charts.gitlab.io
helm repo update

helm upgrade --install kubecompass gitlab/gitlab-agent \
    --namespace gitlab-agent-kubecompass \
    --create-namespace \
    --set image.tag=v16.8.0 \
    --set config.token=YOUR-AGENT-TOKEN \
    --set config.kasAddress=wss://kas.gitlab.com
```

### Step 4: Verify Agent Connection

```bash
# Check agent pod
kubectl get pods -n gitlab-agent-kubecompass

# Check agent logs
kubectl logs -n gitlab-agent-kubecompass -l app=gitlab-agent
```

You should see: `Connected to GitLab`

### Step 5: Create Manifest Repository Structure

```
your-repo/
├── .gitlab/
│   └── agents/
│       └── kubecompass/
│           └── config.yaml
├── manifests/
│   ├── namespaces/
│   │   └── base-namespaces.yaml
│   ├── base/
│   │   ├── echo-server.yaml
│   │   └── nginx-test.yaml
│   └── kustomization.yaml (optional)
└── README.md
```

### Step 6: Test GitOps Workflow

1. **Commit manifest to GitLab:**
   ```bash
   git add manifests/
   git commit -m "feat: Add test workload"
   git push
   ```

2. **Agent automatically syncs** (within 5 minutes by default)

3. **Verify deployment:**
   ```bash
   kubectl get all -n kube-compass-test
   ```

## Complete Kind + GitLab Setup Example

### Repository Structure for Testing

```bash
# Create test repository structure
mkdir -p gitlab-gitops-test/.gitlab/agents/kubecompass
cd gitlab-gitops-test

# Create agent config
cat > .gitlab/agents/kubecompass/config.yaml <<EOF
gitops:
  manifest_projects:
  - id: your-username/gitlab-gitops-test
    paths:
    - glob: 'manifests/**/*.{yaml,yml}'
    reconcile_timeout: 3600s
    prune: true
EOF

# Copy manifests from KubeCompass
cp -r /path/to/KubeCompass/manifests .

# Initialize git
git init
git add .
git commit -m "Initial commit"
git remote add origin git@gitlab.com:your-username/gitlab-gitops-test.git
git push -u origin main
```

### Test Workflow

1. **Deploy something:**
   ```bash
   # Edit manifests/base/nginx-test.yaml
   # Change replicas: 2 to replicas: 3
   git add manifests/base/nginx-test.yaml
   git commit -m "Scale nginx to 3 replicas"
   git push
   ```

2. **Watch GitLab Agent sync:**
   ```bash
   kubectl logs -n gitlab-agent-kubecompass -l app=gitlab-agent -f
   ```

3. **Verify changes:**
   ```bash
   kubectl get deployment nginx-test -n kube-compass-test
   # Should show 3/3 replicas after sync
   ```

## GitLab Agent vs ArgoCD Comparison

### GitLab Agent Workflow

```
Developer → Git Push → GitLab Repository
                          ↓
                    GitLab Agent (polls)
                          ↓
                    Kubernetes Cluster
```

**Pros:**
- ✅ Single platform (Git + CI/CD + GitOps)
- ✅ Simple setup if already on GitLab
- ✅ Good for teams already invested in GitLab

**Cons:**
- ❌ Less mature than ArgoCD
- ❌ Basic UI compared to ArgoCD
- ❌ Vendor lock-in to GitLab
- ❌ Limited sync strategies

### ArgoCD Workflow

```
Developer → Git Push → Any Git Provider (GitHub/GitLab/Gitea)
                          ↓
                    ArgoCD (polls)
                          ↓
                    Kubernetes Cluster
```

**Pros:**
- ✅ Best-in-class GitOps UI
- ✅ Works with any Git provider
- ✅ CNCF Graduated
- ✅ Advanced features (sync waves, hooks, health checks)
- ✅ No vendor lock-in

**Cons:**
- ❌ Separate tool to manage
- ❌ Additional complexity
- ❌ Need to integrate with GitLab for SSO

## Testing Both on Kind

### Scenario 1: GitLab Agent

```bash
# Create cluster
./kind/create-cluster.sh base

# Install GitLab Agent
helm install gitlab-agent gitlab/gitlab-agent \
  --namespace gitlab-agent \
  --create-namespace \
  --set config.token=YOUR_TOKEN

# Test manifest sync
git push  # GitLab Agent syncs automatically
```

### Scenario 2: ArgoCD with GitLab Repository

```bash
# Create cluster
./kind/create-cluster.sh base

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Connect to GitLab repository (any GitLab repo works!)
argocd repo add https://gitlab.com/your-username/your-repo.git \
  --username your-username \
  --password your-gitlab-token
```

## Recommendation for KubeCompass Testing

### **Use ArgoCD with GitLab as Git provider** ✅

**Why:**
- ✅ Test best-in-class GitOps (ArgoCD is industry standard)
- ✅ Keep using GitLab for Git (no migration needed)
- ✅ Learn portable skills (ArgoCD works with any Git)
- ✅ Better for comparing with Flux later
- ✅ No vendor lock-in

### **Use GitLab Agent only if:**
- Already committed to GitLab platform
- Want simplest possible setup
- Don't need advanced GitOps features

## Next Steps for Testing

1. **Create Kind cluster:**
   ```bash
   ./kind/create-cluster.sh base
   ```

2. **Install ArgoCD:**
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

3. **Connect to your GitLab repository:**
   ```bash
   argocd repo add https://gitlab.com/vanhoutenbos/kubecompass.git
   ```

4. **Create ArgoCD Application:**
   ```yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: kubecompass-test
     namespace: argocd
   spec:
     project: default
     source:
       repoURL: https://gitlab.com/your-username/your-repo.git
       targetRevision: main
       path: manifests
     destination:
       server: https://kubernetes.default.svc
       namespace: kube-compass-test
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
   ```

5. **Test GitOps workflow:**
   ```bash
   # Make change in Git
   git commit -am "Scale deployment"
   git push
   
   # Watch ArgoCD sync
   argocd app sync kubecompass-test
   argocd app wait kubecompass-test
   ```

## Resources

- [GitLab Agent Documentation](https://docs.gitlab.com/ee/user/clusters/agent/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD with GitLab](https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories/)
- [Flux Documentation](https://fluxcd.io/docs/)

## Summary

**Yes, GitLab has GitOps!** But consider:

- **GitLab Agent** = Good if all-in on GitLab
- **ArgoCD + GitLab repo** = Best practice (recommended)
- **Flux + GitLab repo** = Alternative for CLI-first approach

**For KubeCompass testing: Use ArgoCD with GitLab as your Git provider.** This gives you the best GitOps experience while keeping your existing GitLab workflow.
