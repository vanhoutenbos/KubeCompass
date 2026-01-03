# Deployment Runbook - Webshop Platform

## Overview

This runbook provides step-by-step procedures for deploying and managing the webshop platform on Kubernetes.

**Target Audience**: Platform Engineers, DevOps Engineers, Operations Team  
**Last Updated**: 2024-01-01  
**Environment**: Production

---

## Table of Contents

1. [Initial Cluster Setup](#initial-cluster-setup)
2. [Platform Component Deployment](#platform-component-deployment)
3. [Application Deployment](#application-deployment)
4. [Rolling Updates](#rolling-updates)
5. [Rollback Procedures](#rollback-procedures)
6. [Troubleshooting](#troubleshooting)

---

## Initial Cluster Setup

### Prerequisites

- [ ] Terraform installed (version >= 1.6.0)
- [ ] kubectl installed
- [ ] Helm installed (version >= 3.0)
- [ ] Access to cloud provider API
- [ ] Remote state backend configured (S3-compatible)

### 1. Provision Infrastructure

```bash
# Navigate to Terraform directory
cd terraform/environments/production

# Initialize Terraform
terraform init

# Review planned changes
terraform plan -out=tfplan

# Apply changes (requires approval)
terraform apply tfplan

# Get cluster credentials
doctl kubernetes cluster kubeconfig save <cluster-id>
# OR use provider-specific command

# Verify cluster access
kubectl cluster-info
kubectl get nodes
```

### 2. Install Cilium CNI

```bash
# Add Cilium Helm repository
helm repo add cilium https://helm.cilium.io/
helm repo update

# Get API server IP
API_SERVER=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}' | sed 's|https://||')

# Install Cilium
helm install cilium cilium/cilium --version 1.14.5 \
  --namespace kube-system \
  --set operator.replicas=2 \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}" \
  --set ipam.mode=kubernetes \
  --set kubeProxyReplacement=strict \
  --set k8sServiceHost=$API_SERVER \
  --set k8sServicePort=6443 \
  --set l7Proxy=true

# Verify Cilium installation
kubectl get pods -n kube-system -l k8s-app=cilium
cilium status --wait

# Run connectivity test
cilium connectivity test
```

### 3. Install NGINX Ingress Controller

```bash
# Add NGINX Ingress Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install NGINX Ingress
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.replicaCount=3 \
  --set controller.service.type=LoadBalancer \
  --set controller.metrics.enabled=true

# Wait for LoadBalancer IP
kubectl get svc -n ingress-nginx ingress-nginx-controller --watch

# Get LoadBalancer IP
LB_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "LoadBalancer IP: $LB_IP"
echo "Create DNS A record: webshop.example.com -> $LB_IP"
```

### 4. Install cert-manager

```bash
# Add cert-manager Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.3 \
  --set installCRDs=true \
  --set prometheus.enabled=true

# Verify installation
kubectl get pods -n cert-manager

# Apply ClusterIssuer
kubectl apply -f kubernetes/platform/cert-manager/install.yaml

# Verify ClusterIssuer
kubectl get clusterissuer
```

### 5. Install ArgoCD

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s \
  deployment/argocd-server -n argocd

# Apply custom configurations
kubectl apply -f kubernetes/argocd/install.yaml

# Get initial admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)

echo "ArgoCD Admin Password: $ARGOCD_PASSWORD"

# Port-forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access: https://localhost:8080
# Username: admin
# Password: <from above>

# Change admin password
argocd login localhost:8080
argocd account update-password
```

---

## Platform Component Deployment

### 6. Deploy Observability Stack

```bash
# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace observability \
  --create-namespace \
  --set prometheus.prometheusSpec.retention=30d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi \
  --set grafana.enabled=true \
  --set alertmanager.enabled=true

# Apply custom Prometheus rules
kubectl apply -f kubernetes/observability/prometheus/install.yaml

# Install Loki
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install loki grafana/loki-stack \
  --namespace observability \
  --set loki.persistence.enabled=true \
  --set loki.persistence.size=50Gi \
  --set promtail.enabled=true

# Apply Grafana dashboards
kubectl apply -f kubernetes/observability/grafana/dashboards.yaml

# Get Grafana admin password
GRAFANA_PASSWORD=$(kubectl get secret -n observability \
  kube-prometheus-stack-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d)

echo "Grafana Admin Password: $GRAFANA_PASSWORD"
```

### 7. Deploy Security Policies

```bash
# Apply RBAC policies
kubectl apply -f kubernetes/security/rbac/policies.yaml

# Apply Network Policies
kubectl apply -f kubernetes/security/network-policies/webshop.yaml

# Apply Pod Security Standards
kubectl apply -f kubernetes/security/pod-security/standards.yaml

# Verify policies
kubectl get networkpolicies -A
kubectl get podsecuritypolicies
```

### 8. Install Harbor Registry

```bash
# Add Harbor Helm repository
helm repo add harbor https://helm.goharbor.io
helm repo update

# Install Harbor
helm install harbor harbor/harbor \
  --namespace harbor \
  --create-namespace \
  --set expose.type=ingress \
  --set expose.ingress.hosts.core=harbor.webshop.example.com \
  --set expose.tls.enabled=true \
  --set expose.tls.certSource=secret \
  --set expose.tls.secret.secretName=harbor-tls \
  --set persistence.enabled=true \
  --set persistence.persistentVolumeClaim.registry.storageClass=fast \
  --set persistence.persistentVolumeClaim.registry.size=100Gi \
  --set trivy.enabled=true

# Wait for Harbor to be ready
kubectl wait --for=condition=available --timeout=300s \
  deployment/harbor-core -n harbor

# Access Harbor UI
echo "Harbor URL: https://harbor.webshop.example.com"
echo "Default username: admin"
echo "Default password: Harbor12345"
echo "⚠️  Change password immediately!"
```

### 9. Install External Secrets Operator

```bash
# Add External Secrets Helm repository
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

# Install External Secrets Operator
helm install external-secrets external-secrets/external-secrets \
  --namespace external-secrets-system \
  --create-namespace

# Apply secret stores and external secrets
kubectl apply -f kubernetes/platform/external-secrets/install.yaml

# Verify external secrets sync
kubectl get externalsecrets -A
kubectl get secrets -A | grep external
```

### 10. Install Velero Backup

```bash
# Add Velero Helm repository
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update

# Install Velero
helm install velero vmware-tanzu/velero \
  --namespace velero \
  --create-namespace \
  --set configuration.backupStorageLocation[0].name=default \
  --set configuration.backupStorageLocation[0].provider=aws \
  --set configuration.backupStorageLocation[0].bucket=webshop-velero-backups \
  --set configuration.backupStorageLocation[0].config.region=eu-west-1 \
  --set configuration.volumeSnapshotLocation[0].name=default \
  --set configuration.volumeSnapshotLocation[0].provider=aws \
  --set initContainers[0].name=velero-plugin-for-aws \
  --set initContainers[0].image=velero/velero-plugin-for-aws:v1.8.0

# Apply backup schedules
kubectl apply -f kubernetes/backup/velero/install.yaml

# Verify backup schedules
velero schedule get
velero backup get
```

---

## Application Deployment

### 11. Deploy Valkey (Redis)

```bash
# Apply Valkey StatefulSet
kubectl apply -f kubernetes/applications/valkey/statefulset.yaml

# Wait for Valkey to be ready
kubectl wait --for=condition=ready --timeout=300s \
  pod -l app=valkey -n webshop

# Verify Valkey
kubectl exec -it valkey-0 -n webshop -- valkey-cli ping
```

### 12. Deploy Webshop Application via ArgoCD

```bash
# Apply ArgoCD Applications (App-of-Apps)
kubectl apply -f kubernetes/argocd/applications/production/app-of-apps.yaml

# Sync applications
argocd app sync platform-infrastructure
argocd app sync observability
argocd app sync security
argocd app sync webshop-application

# Wait for sync
argocd app wait platform-infrastructure --health
argocd app wait webshop-application --health

# Verify deployment
kubectl get pods -n webshop
kubectl get ingress -n webshop
```

---

## Rolling Updates

### Update Application Image

```bash
# Update image tag in Git repository
cd kubernetes/applications/webshop/overlays/production
kustomize edit set image harbor.webshop.example.com/webshop/webshop-app:v1.2.3

# Commit and push
git add kustomization.yaml
git commit -m "Update webshop to v1.2.3"
git push

# ArgoCD will automatically detect and sync (if auto-sync enabled)
# OR manually sync
argocd app sync webshop-application

# Monitor rollout
kubectl rollout status deployment/prod-webshop-app -n webshop --watch

# Verify new pods
kubectl get pods -n webshop -l app=webshop
```

---

## Rollback Procedures

### Rollback via kubectl

```bash
# Rollback to previous deployment
kubectl rollout undo deployment/prod-webshop-app -n webshop

# Rollback to specific revision
kubectl rollout history deployment/prod-webshop-app -n webshop
kubectl rollout undo deployment/prod-webshop-app -n webshop --to-revision=3

# Verify rollback
kubectl rollout status deployment/prod-webshop-app -n webshop
```

### Rollback via ArgoCD

```bash
# View ArgoCD history
argocd app history webshop-application

# Rollback to previous sync
argocd app rollback webshop-application

# Rollback to specific revision
argocd app rollback webshop-application <revision-id>
```

---

## Troubleshooting

### Pod Issues

```bash
# Check pod status
kubectl get pods -n webshop

# Describe pod
kubectl describe pod <pod-name> -n webshop

# View logs
kubectl logs <pod-name> -n webshop
kubectl logs <pod-name> -n webshop --previous  # Previous container

# Execute into pod
kubectl exec -it <pod-name> -n webshop -- /bin/sh
```

### Network Issues

```bash
# Test DNS
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default

# Test service connectivity
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never \
  -- curl http://webshop.webshop.svc.cluster.local

# Check network policies
kubectl get networkpolicies -n webshop
kubectl describe networkpolicy <policy-name> -n webshop

# Check Cilium connectivity
cilium connectivity test
kubectl -n kube-system exec -it ds/cilium -- cilium endpoint list
```

### Ingress Issues

```bash
# Check ingress status
kubectl get ingress -n webshop
kubectl describe ingress webshop -n webshop

# Check NGINX Ingress logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Check certificate status
kubectl get certificate -n webshop
kubectl describe certificate webshop-tls -n webshop
```

---

## Emergency Contacts

- **Platform Team**: platform@webshop.example.com
- **On-call**: +31-XX-XXX-XXXX
- **Escalation**: CTO

---

## References

- [Priority 0 Foundation](../cases/PRIORITY_0_WEBSHOP_CASE.md)
- [Priority 1 Tool Selection](../cases/PRIORITY_1_WEBSHOP_CASE.md)
- [Disaster Recovery Runbook](disaster-recovery.md)
- [Break-glass Procedures](break-glass.md)
