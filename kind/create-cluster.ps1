#!/usr/bin/env pwsh
# Kind Cluster Bootstrap Script
# Creates a Kind cluster with specified configuration

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("base", "cilium", "calico", "multinode")]
    [string]$ClusterType = "base",
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Success { Write-Host "✓ $args" -ForegroundColor Green }
function Write-Info { Write-Host "→ $args" -ForegroundColor Cyan }
function Write-Warning { Write-Host "⚠ $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "✗ $args" -ForegroundColor Red }

Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Blue
Write-Host "  KubeCompass - Kind Cluster Bootstrap" -ForegroundColor Blue
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Blue
Write-Host ""

# Configuration
$ClusterName = "kubecompass-$ClusterType"
$ConfigFile = "kind/cluster-$ClusterType.yaml"

# Pre-flight checks
Write-Info "Running pre-flight checks..."

# Check if kind is installed
try {
    $kindVersion = kind version 2>&1
    Write-Success "Kind is installed: $kindVersion"
} catch {
    Write-Error "Kind is not installed or not in PATH"
    Write-Warning "Install from: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    exit 1
}

# Check if kubectl is installed
try {
    $kubectlVersion = kubectl version --client --short 2>&1
    Write-Success "Kubectl is installed"
} catch {
    Write-Error "Kubectl is not installed or not in PATH"
    exit 1
}

# Check if Docker is running
try {
    docker ps 2>&1 | Out-Null
    Write-Success "Docker is running"
} catch {
    Write-Error "Docker is not running or not accessible"
    Write-Warning "Start Docker Desktop and ensure WSL2 integration is enabled"
    exit 1
}

# Check if config file exists
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Configuration file not found: $ConfigFile"
    exit 1
}
Write-Success "Configuration file found: $ConfigFile"

Write-Host ""

# Check if cluster already exists
$existingCluster = kind get clusters 2>&1 | Where-Object { $_ -eq $ClusterName }

if ($existingCluster) {
    if ($Force) {
        Write-Warning "Cluster '$ClusterName' already exists. Deleting..."
        kind delete cluster --name $ClusterName
        Write-Success "Existing cluster deleted"
    } else {
        Write-Warning "Cluster '$ClusterName' already exists."
        Write-Info "Use -Force to recreate the cluster"
        
        $response = Read-Host "Do you want to delete and recreate? (y/N)"
        if ($response -eq 'y' -or $response -eq 'Y') {
            kind delete cluster --name $ClusterName
            Write-Success "Existing cluster deleted"
        } else {
            Write-Info "Aborted. Using existing cluster."
            kubectl cluster-info --context kind-$ClusterName
            exit 0
        }
    }
}

Write-Host ""
Write-Info "Creating cluster: $ClusterName"
Write-Info "Configuration: $ClusterType"
Write-Host ""

# Create cluster
kind create cluster --config $ConfigFile

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create cluster"
    exit 1
}

Write-Host ""
Write-Success "Cluster created successfully!"
Write-Host ""

# Validate cluster
Write-Info "Validating cluster..."
kubectl cluster-info --context kind-$ClusterName

Write-Host ""
Write-Info "Checking nodes..."
kubectl get nodes

Write-Host ""
Write-Success "Cluster '$ClusterName' is ready!"

# CNI-specific post-install instructions
if ($ClusterType -eq "cilium") {
    Write-Host ""
    Write-Warning "═══════════════════════════════════════════════════"
    Write-Warning "  Cilium CNI needs to be installed manually"
    Write-Warning "═══════════════════════════════════════════════════"
    Write-Host ""
    Write-Info "Install Cilium:"
    Write-Host "  helm repo add cilium https://helm.cilium.io/"
    Write-Host "  helm install cilium cilium/cilium --namespace kube-system"
    Write-Host ""
    Write-Info "Or use Cilium CLI:"
    Write-Host "  cilium install"
    Write-Host ""
}

if ($ClusterType -eq "calico") {
    Write-Host ""
    Write-Warning "═══════════════════════════════════════════════════"
    Write-Warning "  Calico CNI needs to be installed manually"
    Write-Warning "═══════════════════════════════════════════════════"
    Write-Host ""
    Write-Info "Install Calico:"
    Write-Host "  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml"
    Write-Host ""
}

Write-Host ""
Write-Info "Context set to: kind-$ClusterName"
Write-Host ""
