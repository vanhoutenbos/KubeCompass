#!/usr/bin/env bash
# Kind Cluster Bootstrap Script for WSL/Linux
# Creates a Kind cluster with specified configuration

set -euo pipefail

# Configuration
CLUSTER_TYPE="${1:-base}"
FORCE="${2:-false}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
info() { echo -e "${CYAN}→${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warning() { echo -e "${YELLOW}⚠${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*" >&2; }

# Banner
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  KubeCompass - Kind Cluster Bootstrap${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Validate cluster type
case "$CLUSTER_TYPE" in
    base|cilium|calico|multinode)
        ;;
    *)
        error "Invalid cluster type: $CLUSTER_TYPE"
        echo "Valid types: base, cilium, calico, multinode"
        exit 1
        ;;
esac

CLUSTER_NAME="kubecompass-$CLUSTER_TYPE"
CONFIG_FILE="kind/cluster-$CLUSTER_TYPE.yaml"

# Pre-flight checks
info "Running pre-flight checks..."

# Check kind
if ! command -v kind &> /dev/null; then
    error "Kind is not installed or not in PATH"
    warning "Install from: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    exit 1
fi
success "Kind is installed: $(kind version)"

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    error "Kubectl is not installed or not in PATH"
    exit 1
fi
success "Kubectl is installed"

# Check Docker
if ! docker ps &> /dev/null; then
    error "Docker is not running or not accessible"
    warning "Ensure Docker is running and your user has permissions"
    exit 1
fi
success "Docker is running"

# Check config file
if [[ ! -f "$CONFIG_FILE" ]]; then
    error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi
success "Configuration file found: $CONFIG_FILE"

echo ""

# Check if cluster exists
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    if [[ "$FORCE" == "true" ]]; then
        warning "Cluster '$CLUSTER_NAME' already exists. Deleting..."
        kind delete cluster --name "$CLUSTER_NAME"
        success "Existing cluster deleted"
    else
        warning "Cluster '$CLUSTER_NAME' already exists."
        info "Run with 'force' as second argument to recreate"
        
        read -p "Do you want to delete and recreate? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kind delete cluster --name "$CLUSTER_NAME"
            success "Existing cluster deleted"
        else
            info "Aborted. Using existing cluster."
            kubectl cluster-info --context "kind-${CLUSTER_NAME}"
            exit 0
        fi
    fi
fi

echo ""
info "Creating cluster: $CLUSTER_NAME"
info "Configuration: $CLUSTER_TYPE"
echo ""

# Create cluster
kind create cluster --config "$CONFIG_FILE"

echo ""
success "Cluster created successfully!"
echo ""

# Validate cluster
info "Validating cluster..."
kubectl cluster-info --context "kind-${CLUSTER_NAME}"

echo ""
info "Checking nodes..."
kubectl get nodes

echo ""
success "Cluster '$CLUSTER_NAME' is ready!"

# CNI-specific post-install instructions
if [[ "$CLUSTER_TYPE" == "cilium" ]]; then
    echo ""
    warning "═══════════════════════════════════════════════════"
    warning "  Cilium CNI needs to be installed manually"
    warning "═══════════════════════════════════════════════════"
    echo ""
    info "Install Cilium:"
    echo "  helm repo add cilium https://helm.cilium.io/"
    echo "  helm install cilium cilium/cilium --namespace kube-system"
    echo ""
    info "Or use Cilium CLI:"
    echo "  cilium install"
    echo ""
fi

if [[ "$CLUSTER_TYPE" == "calico" ]]; then
    echo ""
    warning "═══════════════════════════════════════════════════"
    warning "  Calico CNI needs to be installed manually"
    warning "═══════════════════════════════════════════════════"
    echo ""
    info "Install Calico:"
    echo "  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml"
    echo ""
fi

echo ""
info "Context set to: kind-${CLUSTER_NAME}"
echo ""
