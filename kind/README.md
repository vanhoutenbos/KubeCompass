# Kind Cluster Management

This directory contains Kind cluster configurations and management scripts for KubeCompass testing.

## Overview

**Important**: Different CNIs require **separate Kind clusters**. You cannot run multiple CNIs in a single cluster.

## Available Cluster Configurations

### 1. Base Cluster (Default)
- **File**: `cluster-base.yaml`
- **Name**: `kubecompass-base`
- **CNI**: kindnet (default)
- **Use case**: General testing, baseline validation

### 2. Cilium Cluster
- **File**: `cluster-cilium.yaml`
- **Name**: `kubecompass-cilium`
- **CNI**: None (install Cilium manually)
- **Use case**: Testing eBPF-based networking, observability, security

### 3. Calico Cluster
- **File**: `cluster-calico.yaml`
- **Name**: `kubecompass-calico`
- **CNI**: None (install Calico manually)
- **Use case**: Testing network policies, BGP routing

### 4. Multi-node Cluster
- **File**: `cluster-multinode.yaml`
- **Name**: `kubecompass-multinode`
- **CNI**: kindnet (default)
- **Nodes**: 1 control-plane + 2 workers
- **Use case**: Testing scheduling, affinity, node selectors

## Quick Start

### Windows (PowerShell)

```powershell
# Create base cluster
.\kind\create-cluster.ps1

# Create specific cluster type
.\kind\create-cluster.ps1 -ClusterType cilium

# Force recreate
.\kind\create-cluster.ps1 -ClusterType base -Force
```

### Linux/WSL (Bash)

```bash
# Create base cluster
./kind/create-cluster.sh

# Create specific cluster type
./kind/create-cluster.sh cilium

# Force recreate
./kind/create-cluster.sh base force
```

## Prerequisites

### Required
- Docker Desktop (Windows) or Docker Engine (Linux)
- kubectl
- kind

### Optional (for CNI testing)
- Helm (for Cilium)
- Cilium CLI

## Installation Instructions

### Windows

```powershell
# Install kind
curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe C:\Windows\System32\kind.exe

# Install kubectl
curl.exe -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
Move-Item .\kubectl.exe C:\Windows\System32\kubectl.exe
```

### WSL/Linux

```bash
# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

## Post-Installation

### Cilium

```bash
# Using Helm
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --namespace kube-system

# Or using Cilium CLI
cilium install
```

### Calico

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

## Cluster Management

### List clusters
```bash
kind get clusters
```

### Switch context
```bash
kubectl config use-context kind-kubecompass-base
```

### Delete cluster
```bash
kind delete cluster --name kubecompass-base
```

### Get cluster info
```bash
kubectl cluster-info
kubectl get nodes
```

## Port Mappings

All clusters expose these ports on localhost:

- **8080**: HTTP services (NodePort 30080)
- **8443**: HTTPS services (NodePort 30443)
- **9090**: Metrics/Monitoring (NodePort 30090)

## Network Architecture

### kindnet (default)
- Simple overlay network
- Good for basic testing
- No advanced features

### Cilium
- eBPF-based dataplane
- Advanced observability (Hubble)
- Service mesh capabilities
- Network policies with L7 awareness

### Calico
- Traditional CNI with iptables or eBPF
- Strong network policy support
- BGP routing capabilities
- Enterprise-grade networking

## Testing Strategy

1. **Start with base cluster**: Validate basic functionality
2. **Test CNI-specific features**: Use dedicated clusters per CNI
3. **Multi-node testing**: Use multinode cluster for scheduling/affinity
4. **Isolation**: Each use case gets its own namespace, NOT cluster (unless testing CNI)

## Directory Structure

```
kind/
  ├── README.md                    # This file
  ├── cluster-base.yaml            # Base configuration
  ├── cluster-cilium.yaml          # Cilium configuration
  ├── cluster-calico.yaml          # Calico configuration
  ├── cluster-multinode.yaml       # Multi-node configuration
  ├── create-cluster.ps1           # Windows bootstrap script
  └── create-cluster.sh            # Linux bootstrap script
```

## Troubleshooting

### Cluster won't start
```bash
# Check Docker
docker ps

# Check logs
kind export logs

# Recreate
kind delete cluster --name kubecompass-base
kind create cluster --config kind/cluster-base.yaml
```

### Nodes not ready (CNI clusters)
```bash
# Check if CNI is installed
kubectl get pods -n kube-system

# If not, install appropriate CNI (see Post-Installation)
```

### Port conflicts
```bash
# Check what's using the port
netstat -ano | findstr :8080  # Windows
lsof -i :8080                  # Linux

# Change port in cluster YAML extraPortMappings
```

## Best Practices

✅ **DO**:
- Use descriptive cluster names
- One CNI per cluster
- Commit cluster configs to Git
- Document custom configurations
- Clean up unused clusters

❌ **DON'T**:
- Mix CNIs in one cluster
- Use production data in Kind
- Rely on persistent storage
- Expose to public network
- Skip validation steps

## Next Steps

After cluster creation:
1. Deploy test workload (see `/manifests/base/`)
2. Run smoke tests (see `/tests/smoke/`)
3. Configure namespaces (see `/manifests/namespaces/`)
4. Set up RBAC (see `/manifests/rbac/`)

## Resources

- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Cilium Documentation](https://docs.cilium.io/)
- [Calico Documentation](https://docs.projectcalico.org/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
