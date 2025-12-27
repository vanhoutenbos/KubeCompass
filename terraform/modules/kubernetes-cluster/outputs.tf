# Kubernetes Cluster Module Outputs

output "cluster_id" {
  description = "Kubernetes cluster ID"
  value       = digitalocean_kubernetes_cluster.webshop.id
}

output "cluster_name" {
  description = "Kubernetes cluster name"
  value       = digitalocean_kubernetes_cluster.webshop.name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = digitalocean_kubernetes_cluster.webshop.endpoint
}

output "cluster_version" {
  description = "Kubernetes version"
  value       = digitalocean_kubernetes_cluster.webshop.version
}

output "cluster_region" {
  description = "Cluster region"
  value       = digitalocean_kubernetes_cluster.webshop.region
}

output "cluster_status" {
  description = "Cluster status"
  value       = digitalocean_kubernetes_cluster.webshop.status
}

output "cluster_created_at" {
  description = "Cluster creation timestamp"
  value       = digitalocean_kubernetes_cluster.webshop.created_at
}

output "cluster_updated_at" {
  description = "Cluster last update timestamp"
  value       = digitalocean_kubernetes_cluster.webshop.updated_at
}

# Node Pool Outputs
output "system_node_pool_id" {
  description = "System node pool ID"
  value       = digitalocean_kubernetes_node_pool.system.id
}

output "application_node_pool_id" {
  description = "Application node pool ID"
  value       = digitalocean_kubernetes_node_pool.application.id
}

output "system_node_count" {
  description = "Number of nodes in system pool"
  value       = digitalocean_kubernetes_node_pool.system.node_count
}

output "application_node_count" {
  description = "Number of nodes in application pool"
  value       = digitalocean_kubernetes_node_pool.application.actual_node_count
}

# Kubeconfig (sensitive)
output "kubeconfig_raw" {
  description = "Raw kubeconfig for cluster access (sensitive)"
  value       = digitalocean_kubernetes_cluster.webshop.kube_config[0].raw_config
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate (base64 encoded, sensitive)"
  value       = digitalocean_kubernetes_cluster.webshop.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "client_certificate" {
  description = "Client certificate for cluster access (base64 encoded, sensitive)"
  value       = digitalocean_kubernetes_cluster.webshop.kube_config[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Client key for cluster access (base64 encoded, sensitive)"
  value       = digitalocean_kubernetes_cluster.webshop.kube_config[0].client_key
  sensitive   = true
}
