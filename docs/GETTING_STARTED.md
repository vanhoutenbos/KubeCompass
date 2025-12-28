# Getting Started with KubeCompass Local Testing

This guide walks you through setting up your local Kind-based testing platform.

## Prerequisites

### Required
- **Docker Desktop** (Windows) or **Docker Engine** (Linux)
  - WSL2 backend enabled (Windows)
  - Kubernetes in Docker Desktop **disabled** (we use Kind)
- **kubectl** - Kubernetes command-line tool
- **kind** - Kubernetes in Docker
- **Git** - Version control
- **VS Code** (recommended) - Code editor

### Optional
- **Helm** - Package manager (for Cilium, etc.)
- **Cilium CLI** - Cilium management
- **WSL2 Ubuntu** - Windows Subsystem for Linux (recommended for Windows users)

## Installation

### Windows (PowerShell)

```powershell
# Install kind
curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe C:\Windows\System32\kind.exe

# Install kubectl
curl.exe -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
Move-Item .\kubectl.exe C:\Windows\System32\kubectl.exe

# Verify
kind version
kubectl version --client
docker version
```

### Linux/WSL2 (Bash)

```bash
# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify
kind version
kubectl version --client
docker version
```

## Quick Start

### Step 1: Clone Repository

```bash
git clone https://github.com/vanhoutenbos/KubeCompass.git
cd KubeCompass
```

### Step 2: Create Base Cluster

**Windows:**
```powershell
.\kind\create-cluster.ps1
```

**Linux/WSL:**
```bash
./kind/create-cluster.sh
```

This creates a single-node cluster named `kubecompass-base`.

### Step 3: Validate Cluster

```bash
kubectl cluster-info
kubectl get nodes
```

### Step 4: Run Smoke Tests

**Windows:**
```powershell
.\tests\smoke\run-tests.ps1
```

**Linux/WSL:**
```bash
./tests/smoke/run-tests.sh
```

All tests should pass.

### Step 5: Deploy Test Workloads

```bash
# Create namespaces
kubectl apply -f manifests/namespaces/

# Deploy test workloads
kubectl apply -f manifests/base/

# Verify
kubectl get all -n kube-compass-test
```

### Step 6: Test Connectivity

```bash
# Echo server should be accessible on localhost:8080
curl http://localhost:8080
```

You should get a JSON response with request details.

## Next Steps

### Test Different CNIs

#### Cilium

```bash
# Create Cilium cluster
./kind/create-cluster.sh cilium

# Install Cilium
cilium install

# Verify
cilium status
```

#### Calico

```bash
# Create Calico cluster
./kind/create-cluster.sh calico

# Install Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

# Verify
kubectl get pods -n kube-system
```

### Multi-Node Cluster

```bash
# Create multi-node cluster
./kind/create-cluster.sh multinode

# Check nodes
kubectl get nodes
```

## Common Tasks

### Switch Between Clusters

```bash
# List contexts
kubectl config get-contexts

# Switch context
kubectl config use-context kind-kubecompass-cilium

# Verify current context
kubectl config current-context
```

### Delete Cluster

```bash
kind delete cluster --name kubecompass-base
```

### List All Clusters

```bash
kind get clusters
```

### Export Logs

```bash
kind export logs --name kubecompass-base
```

## Troubleshooting

### Docker not running

**Error:** `Cannot connect to Docker daemon`

**Solution:**
- Start Docker Desktop
- Ensure WSL2 integration is enabled (Windows)
- Check: `docker ps`

### Nodes not ready

**Error:** `NotReady` nodes

**Solution:**
- Check if CNI is installed: `kubectl get pods -n kube-system`
- For Cilium/Calico clusters, install the CNI manually
- Wait a few minutes for initialization

### Port already in use

**Error:** `port is already allocated`

**Solution:**
- Check what's using the port: `netstat -ano | findstr :8080` (Windows) or `lsof -i :8080` (Linux)
- Stop the conflicting service
- Or change the port in `kind/cluster-*.yaml`

### kubectl context not set

**Error:** `The connection to the server localhost:8080 was refused`

**Solution:**
```bash
kubectl config use-context kind-kubecompass-base
```

### Can't reach localhost:8080

**Error:** Connection refused

**Solution:**
- Check if echo-server pod is running: `kubectl get pods -n kube-compass-test`
- Check if service exists: `kubectl get svc -n kube-compass-test`
- Verify port mapping: `docker ps` (look for port 8080 mapping)

## Learning Path

1. ✅ **Basic Cluster** - Single node, default CNI
2. **CNI Comparison** - Test Cilium vs Calico
3. **Multi-Node** - Scheduling, affinity, taints
4. **RBAC** - Service accounts, roles, policies
5. **Network Policies** - Isolation, egress control
6. **Observability** - Prometheus, Grafana, Loki
7. **GitOps** - ArgoCD or Flux
8. **Chaos Testing** - Resilience validation

## Repository Structure

```
KubeCompass/
├── kind/              # Cluster configurations and scripts
├── manifests/         # Kubernetes manifests (layered)
├── tests/             # Test suites
├── docs/              # Documentation
├── cases/             # Use case definitions
└── README.md          # This file
```

## Resources

- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Cilium Documentation](https://docs.cilium.io/)
- [Calico Documentation](https://docs.projectcalico.org/)

## Support

- Issues: [GitHub Issues](https://github.com/vanhoutenbos/KubeCompass/issues)
- Documentation: [docs/](docs/)
- Cases: [cases/](cases/)

---

**Important:** This is a **validation and learning platform**, not for production use.
