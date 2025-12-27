# Production Environment - Outputs

# Cluster Outputs
output "cluster_id" {
  description = "Kubernetes cluster ID"
  value       = module.kubernetes_cluster.cluster_id
}

output "cluster_name" {
  description = "Kubernetes cluster name"
  value       = module.kubernetes_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.kubernetes_cluster.cluster_endpoint
  sensitive   = true
}

output "cluster_version" {
  description = "Kubernetes version"
  value       = module.kubernetes_cluster.cluster_version
}

output "cluster_status" {
  description = "Cluster status"
  value       = module.kubernetes_cluster.cluster_status
}

# Networking Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "loadbalancer_ip" {
  description = "Load balancer public IP (for DNS A record)"
  value       = module.networking.loadbalancer_ip
}

output "reserved_ip" {
  description = "Reserved IP address (stable for DNS)"
  value       = module.networking.reserved_ip
}

# Storage Outputs
output "storage_classes" {
  description = "Available storage classes"
  value       = module.storage.storage_classes
}

output "default_storage_class" {
  description = "Default storage class"
  value       = module.storage.default_storage_class
}

# Connection Instructions
output "connection_instructions" {
  description = "Instructions to connect to the cluster"
  value = <<-EOT
    Production Cluster Connection:
    
    1. Get kubeconfig:
       doctl kubernetes cluster kubeconfig save ${module.kubernetes_cluster.cluster_id}
    
    2. Verify connection:
       kubectl cluster-info
       kubectl get nodes
    
    3. Configure DNS:
       Create A record: webshop.example.com → ${module.networking.loadbalancer_ip}
       Create CNAME: www.webshop.example.com → webshop.example.com
    
    4. Next steps:
       - Install Cilium CNI
       - Deploy NGINX Ingress Controller
       - Install cert-manager
       - Deploy ArgoCD
       - Configure observability stack
  EOT
}

# Security Reminder
output "security_checklist" {
  description = "Production security checklist"
  value = <<-EOT
    Production Security Checklist:
    
    [ ] Restrict Kubernetes API access (update api_allowed_sources variable)
    [ ] Configure RBAC policies
    [ ] Enable Pod Security Standards
    [ ] Deploy Network Policies
    [ ] Configure External Secrets Operator
    [ ] Enable audit logging
    [ ] Set up Velero backups
    [ ] Configure Grafana dashboards and alerts
    [ ] Enable Trivy image scanning
    [ ] Document break-glass procedures
    [ ] Test disaster recovery
  EOT
}
