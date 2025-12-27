# Kubernetes Manifests - Webshop Platform

This directory contains Kubernetes manifests for the Dutch webshop platform, organized for GitOps deployment with ArgoCD.

## Directory Structure

```
kubernetes/
├── argocd/                   # ArgoCD installation and configuration
├── platform/                 # Platform infrastructure components
│   ├── cilium/              # Cilium CNI
│   ├── nginx-ingress/       # NGINX Ingress Controller
│   ├── cert-manager/        # Let's Encrypt SSL/TLS
│   ├── external-secrets/    # External Secrets Operator
│   └── harbor/              # Harbor container registry
├── observability/           # Monitoring and logging
│   ├── prometheus/          # Metrics collection
│   ├── grafana/             # Dashboards and visualization
│   └── loki/                # Log aggregation
├── security/                # Security policies
│   ├── rbac/                # Role-Based Access Control
│   ├── network-policies/    # Network isolation
│   └── pod-security/        # Pod Security Standards
├── applications/            # Application workloads
│   ├── webshop/             # Webshop application
│   └── valkey/              # Valkey (Redis) for sessions
└── backup/                  # Backup and disaster recovery
    └── velero/              # Velero cluster backup
```

## GitOps Workflow

### Branching Strategy: Trunk-Based Development

- **main branch**: Auto-deploy to dev and staging
- **Pull Requests**: Manual approval for production
- **ArgoCD Sync Policies**:
  - Dev: Automated sync
  - Staging: Automated sync
  - Production: Manual sync (approval required)

### Deployment Flow

```
Developer → Git PR → Review → Merge to main
                                    ↓
                          ArgoCD watches main
                                    ↓
                    ┌──────────────┴────────────────┐
                    ↓                                ↓
              Auto-sync dev                  Auto-sync staging
                    ↓                                ↓
              Verify in dev                  Integration tests
                                                     ↓
                                        Manual approval (ArgoCD UI)
                                                     ↓
                                            Sync to production
```

## Installation Order

Follow this order for platform bootstrapping:

### Phase 1: Core Platform (Week 1-2)
1. ArgoCD (bootstrap)
2. Cilium CNI
3. NGINX Ingress Controller
4. cert-manager

### Phase 2: Security & Secrets (Week 3-4)
5. External Secrets Operator
6. RBAC policies
7. Network Policies
8. Pod Security Standards

### Phase 3: Observability (Week 5-6)
9. Prometheus
10. Grafana
11. Loki

### Phase 4: Platform Services (Week 7-8)
12. Harbor registry
13. Velero backup

### Phase 5: Applications (Week 9-12)
14. Valkey (session storage)
15. Webshop application (dev)
16. Database migration

## ArgoCD Bootstrap

### Initial Installation

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f argocd/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s \
  deployment/argocd-server -n argocd

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Port-forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Login: https://localhost:8080
# Username: admin
# Password: <from above command>
```

### Configure ArgoCD Applications

After ArgoCD is running, apply the App-of-Apps pattern:

```bash
kubectl apply -f argocd/applications/
```

This will create ArgoCD Application resources that automatically deploy all platform components.

## Environment-Specific Configurations

Each environment (dev, staging, production) has specific configurations:

### Development
- Minimal resources
- No HA requirements
- Relaxed security policies (for testing)
- Debug logging enabled

### Staging
- Production-like resources
- HA enabled
- Full security policies
- Integration tests enabled

### Production
- Full resources with auto-scaling
- HA required
- Strict security policies
- Audit logging enabled
- Manual deployment approval

Use Kustomize overlays for environment-specific customizations.

## Security Considerations

### Secrets Management

**NEVER commit secrets to Git!**

Use External Secrets Operator to sync secrets from:
- HashiCorp Vault
- Cloud provider KMS (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager)
- Kubernetes secrets in separate cluster

### RBAC Strategy

- **Default**: Read-only access to production
- **Developers**: Write access to dev/staging via GitOps
- **Break-glass**: Temporary elevated privileges via `kubectl as` or privilege manager
- **Audit**: All elevated actions are logged

### Network Policies

- **Default deny**: All namespaces have default deny ingress/egress
- **Whitelist**: Explicitly allow required connections
- **Egress control**: External APIs (payment, shipping) whitelisted

## Monitoring and Alerting

### Key Metrics

- **Application**: Checkout conversion, order processing time, payment success rate
- **Infrastructure**: CPU, memory, disk, network
- **Availability**: Uptime, error rates, response times

### Alert Levels

1. **Pager-Worthy**: Production down, data loss risk
2. **Slack/Email**: Degraded performance, warnings
3. **Info**: Routine events, successful deployments

### Dashboards

- **Overview**: Business metrics, system health
- **Infrastructure**: Node status, resource usage
- **Application**: Request rates, error rates, latencies
- **Security**: Failed authentications, policy violations

## Backup and Disaster Recovery

### Backup Strategy

- **Velero**: Cluster-level backups (etcd, resources)
- **Database**: Managed PostgreSQL native backups
- **Retention**: 30 days for production, 14 days for staging

### Recovery Testing

- **Quarterly**: Full DR test in staging
- **Monthly**: Partial recovery test (single namespace)
- **RPO**: 15 minutes (maximum data loss)
- **RTO**: 1 hour (maximum recovery time)

## Troubleshooting

### ArgoCD Sync Issues

```bash
# Check application status
kubectl get applications -n argocd

# View sync errors
kubectl describe application <app-name> -n argocd

# Manual sync
argocd app sync <app-name>

# Refresh application (re-detect changes)
argocd app get <app-name> --refresh
```

### Platform Component Issues

```bash
# Check pod status
kubectl get pods -A

# View logs
kubectl logs -n <namespace> <pod-name>

# Describe resource
kubectl describe pod -n <namespace> <pod-name>
```

### Network Connectivity Issues

```bash
# Test DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default

# Test service connectivity
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -- curl http://service-name.namespace.svc.cluster.local
```

## Maintenance

### Regular Updates

- **Weekly**: Security patches (auto-applied to dev)
- **Monthly**: Review and apply to staging
- **Quarterly**: Major version upgrades (tested in dev → staging → production)

### Capacity Planning

- Monitor resource usage trends
- Scale node pools before reaching 80% capacity
- Review storage growth monthly

### Cost Optimization

- Right-size resources based on actual usage
- Enable auto-scaling for variable workloads
- Use spot/preemptible nodes for non-critical workloads (dev/staging)

## References

- [Layer 0 Foundation](../LAYER_0_WEBSHOP_CASE.md)
- [Layer 1 Tool Selection](../LAYER_1_WEBSHOP_CASE.md)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Cilium Documentation](https://docs.cilium.io/)
- [Prometheus Documentation](https://prometheus.io/docs/)
