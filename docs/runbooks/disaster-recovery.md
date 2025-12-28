# Disaster Recovery Runbook - Webshop Platform

## Overview

This runbook provides procedures for recovering from catastrophic failures of the webshop platform.

**Recovery Time Objective (RTO)**: 1 hour  
**Recovery Point Objective (RPO)**: 15 minutes  
**Last Tested**: [Date of last DR test]

---

## Table of Contents

1. [Disaster Scenarios](#disaster-scenarios)
2. [Pre-Recovery Checklist](#pre-recovery-checklist)
3. [Complete Cluster Recovery](#complete-cluster-recovery)
4. [Namespace Recovery](#namespace-recovery)
5. [Database Recovery](#database-recovery)
6. [Verification Procedures](#verification-procedures)

---

## Disaster Scenarios

### Scenario 1: Complete Cluster Loss

**Symptoms**:
- Kubernetes API unreachable
- All nodes down
- Complete infrastructure failure

**Recovery Procedure**: [Complete Cluster Recovery](#complete-cluster-recovery)

### Scenario 2: Namespace Deletion

**Symptoms**:
- Entire namespace deleted (accidental or malicious)
- All resources in namespace gone

**Recovery Procedure**: [Namespace Recovery](#namespace-recovery)

### Scenario 3: Database Corruption

**Symptoms**:
- Database errors in application logs
- Data inconsistency
- Database unavailable

**Recovery Procedure**: [Database Recovery](#database-recovery)

---

## Pre-Recovery Checklist

Before starting recovery:

- [ ] Confirm disaster scope (partial vs. complete)
- [ ] Notify stakeholders (management, customers if needed)
- [ ] Assemble recovery team (platform engineers, DBA, operations)
- [ ] Verify backup availability and integrity
- [ ] Document current state (screenshots, logs)
- [ ] Enable incident communication channel (Slack, Teams)

---

## Complete Cluster Recovery

### Estimated Time: 45-60 minutes

### Step 1: Provision New Infrastructure (15 min)

```bash
# Navigate to Terraform directory
cd terraform/environments/production

# Verify Terraform state is accessible
terraform state list

# Provision new cluster
terraform plan -out=tfplan
terraform apply tfplan

# Wait for cluster to be ready
kubectl get nodes --watch
```

### Step 2: Install Core Platform Components (20 min)

```bash
# Install Cilium CNI
helm install cilium cilium/cilium --version 1.14.5 \
  --namespace kube-system \
  --set operator.replicas=2 \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set k8sServiceHost=$API_SERVER \
  --set k8sServicePort=6443

# Verify Cilium
kubectl wait --for=condition=ready --timeout=300s pod -l k8s-app=cilium -n kube-system

# Install NGINX Ingress
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.replicaCount=3

# Install cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.3 \
  --set installCRDs=true

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for all components
kubectl wait --for=condition=available --timeout=600s \
  deployment/argocd-server -n argocd
```

### Step 3: Restore from Velero Backup (15 min)

```bash
# Install Velero
helm install velero vmware-tanzu/velero \
  --namespace velero \
  --create-namespace \
  --set configuration.backupStorageLocation[0].name=default \
  --set configuration.backupStorageLocation[0].provider=aws \
  --set configuration.backupStorageLocation[0].bucket=webshop-velero-backups

# Wait for Velero
kubectl wait --for=condition=available --timeout=300s \
  deployment/velero -n velero

# List available backups
velero backup get

# Identify latest successful backup
LATEST_BACKUP=$(velero backup get --output json | \
  jq -r '.items[] | select(.status.phase=="Completed") | .metadata.name' | \
  sort -r | head -1)

echo "Latest backup: $LATEST_BACKUP"

# Restore from backup
velero restore create restore-$(date +%Y%m%d-%H%M%S) \
  --from-backup $LATEST_BACKUP

# Monitor restore progress
velero restore describe <restore-name>
velero restore logs <restore-name>

# Wait for restore to complete
kubectl get pods -A --watch
```

### Step 4: Verify Application Recovery (10 min)

```bash
# Check all namespaces
kubectl get pods -A

# Check webshop application
kubectl get pods -n webshop
kubectl get ingress -n webshop

# Verify services
kubectl get svc -A

# Test application endpoints
curl -k https://webshop.example.com/health
curl -k https://webshop.example.com/ready

# Check ArgoCD sync status
argocd app list
argocd app sync webshop-application --force

# Verify database connectivity
kubectl exec -it -n webshop <pod-name> -- \
  psql -h <db-host> -U <db-user> -d webshop -c "SELECT 1"
```

### Step 5: Update DNS (5 min)

```bash
# Get new LoadBalancer IP
NEW_LB_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "Update DNS A record: webshop.example.com -> $NEW_LB_IP"

# Verify DNS propagation
dig webshop.example.com +short

# Test via new IP
curl -H "Host: webshop.example.com" http://$NEW_LB_IP/health
```

---

## Namespace Recovery

### Estimated Time: 15-20 minutes

```bash
# Identify namespace to restore
NAMESPACE=webshop

# Create restore for specific namespace
velero restore create restore-$NAMESPACE-$(date +%Y%m%d-%H%M%S) \
  --from-backup $LATEST_BACKUP \
  --include-namespaces $NAMESPACE \
  --restore-volumes=true

# Monitor restore
velero restore describe <restore-name>

# Verify namespace resources
kubectl get all -n $NAMESPACE

# Check PVCs
kubectl get pvc -n $NAMESPACE

# Verify external secrets sync
kubectl get externalsecrets -n $NAMESPACE

# Test application
kubectl logs -n $NAMESPACE <pod-name>
curl https://webshop.example.com/health
```

---

## Database Recovery

### PostgreSQL Point-in-Time Recovery

#### Estimated Time: 30-45 minutes

### Step 1: Stop Application

```bash
# Scale down application to prevent writes
kubectl scale deployment/prod-webshop-app -n webshop --replicas=0

# Verify no pods running
kubectl get pods -n webshop -l app=webshop
```

### Step 2: Restore Database (Managed PostgreSQL)

```bash
# Using cloud provider CLI (example: DigitalOcean)
doctl databases backups list <database-id>

# Restore to specific backup or timestamp
doctl databases restore <database-id> --backup-id <backup-id>
# OR
doctl databases restore <database-id> --timestamp "2024-01-01 12:00:00"

# Wait for restore to complete (10-20 minutes)
doctl databases get <database-id> --format Status
```

### Step 3: Verify Database

```bash
# Connect to database
kubectl run -it --rm psql --image=postgres:15 --restart=Never -- \
  psql -h <db-host> -U <db-user> -d webshop

# Verify data integrity
SELECT COUNT(*) FROM orders;
SELECT MAX(created_at) FROM orders;
SELECT * FROM orders ORDER BY created_at DESC LIMIT 10;

# Check for inconsistencies
-- Add your specific data validation queries
```

### Step 4: Restart Application

```bash
# Scale up application
kubectl scale deployment/prod-webshop-app -n webshop --replicas=5

# Wait for pods to be ready
kubectl wait --for=condition=ready --timeout=300s \
  pod -l app=webshop -n webshop

# Verify application health
kubectl logs -n webshop -l app=webshop --tail=50
curl https://webshop.example.com/health
```

---

## Verification Procedures

### Health Checks

```bash
# 1. Infrastructure Health
kubectl get nodes
kubectl get pods -A | grep -v Running | grep -v Completed

# 2. Application Health
kubectl get pods -n webshop
kubectl logs -n webshop -l app=webshop --tail=20

# 3. Database Connectivity
kubectl exec -n webshop -it <pod-name> -- curl localhost:8080/health

# 4. Ingress Health
kubectl get ingress -n webshop
curl -I https://webshop.example.com

# 5. Certificate Status
kubectl get certificate -n webshop
```

### Business Verification

```bash
# 1. Test homepage
curl https://webshop.example.com/ | grep -i "webshop"

# 2. Test product listing
curl https://webshop.example.com/api/products | jq '.count'

# 3. Test checkout flow (use test account)
# Manual verification required

# 4. Verify recent orders
kubectl exec -n webshop -it <pod-name> -- \
  psql -c "SELECT COUNT(*) FROM orders WHERE created_at > NOW() - INTERVAL '1 hour'"

# 5. Check Valkey (Redis) connectivity
kubectl exec -n webshop valkey-0 -- valkey-cli ping
kubectl exec -n webshop valkey-0 -- valkey-cli INFO stats
```

### Performance Validation

```bash
# 1. Response time check
time curl -o /dev/null -s -w '%{time_total}\n' https://webshop.example.com/

# 2. Database query performance
kubectl exec -n webshop -it <pod-name> -- \
  psql -c "EXPLAIN ANALYZE SELECT * FROM products LIMIT 100"

# 3. Check Prometheus metrics
kubectl port-forward -n observability svc/prometheus-operated 9090:9090
# Visit: http://localhost:9090
# Query: rate(http_requests_total[5m])

# 4. Check error rates
# Query: rate(http_requests_total{status=~"5.."}[5m])
```

---

## Post-Recovery Actions

### Immediate (within 1 hour)

- [ ] Update incident timeline
- [ ] Notify stakeholders of recovery completion
- [ ] Monitor application closely for 4 hours
- [ ] Document any issues encountered during recovery

### Short-term (within 24 hours)

- [ ] Conduct post-mortem meeting
- [ ] Update DR runbook with lessons learned
- [ ] Review and update backup retention policies
- [ ] Test fail-over to ensure system stability

### Long-term (within 1 week)

- [ ] Schedule next DR drill
- [ ] Improve monitoring and alerting based on incident
- [ ] Review and update RPO/RTO if needed
- [ ] Train team on any new recovery procedures

---

## Escalation

### Level 1: Platform Team
- Email: platform@webshop.example.com
- Slack: #platform-team
- On-call: +31-XX-XXX-XXXX

### Level 2: Engineering Manager
- Email: em@webshop.example.com
- Phone: +31-XX-XXX-XXXX

### Level 3: CTO
- Email: cto@webshop.example.com
- Phone: +31-XX-XXX-XXXX

---

## Backup Verification

Regular backup verification is critical. Run these checks weekly:

```bash
# Check Velero backup status
velero backup get
velero schedule get

# Verify backup age (should be < 24 hours)
LAST_BACKUP=$(velero backup get --output json | \
  jq -r '.items[] | select(.status.phase=="Completed") | .metadata.name' | \
  sort -r | head -1)

BACKUP_AGE=$(velero backup describe $LAST_BACKUP --details | \
  grep "Created:" | awk '{print $2, $3}')

echo "Last successful backup: $LAST_BACKUP at $BACKUP_AGE"

# Check database backups (provider-specific)
doctl databases backups list <database-id>

# Verify backup storage usage
# Check S3 bucket size
```

---

## DR Test Schedule

- **Monthly**: Namespace recovery test (dev environment)
- **Quarterly**: Full cluster recovery test (staging environment)
- **Annually**: Complete DR drill with business stakeholders

**Last Test Date**: [Insert date]  
**Next Scheduled Test**: [Insert date]

---

## References

- [Deployment Runbook](deployment.md)
- [Break-glass Procedures](break-glass.md)
- [Velero Documentation](https://velero.io/docs/)
- [Layer 0 Foundation](../cases/LAYER_0_WEBSHOP_CASE.md)
