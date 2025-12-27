# Kubernetes Cluster Module
# Provisions managed Kubernetes cluster with system and application node pools

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Kubernetes Cluster
resource "digitalocean_kubernetes_cluster" "webshop" {
  name    = var.cluster_name
  region  = var.region
  version = var.kubernetes_version
  
  # High availability control plane
  ha = var.enable_ha
  
  # Auto-upgrade configuration
  auto_upgrade = var.auto_upgrade_enabled
  surge_upgrade = true
  
  # Maintenance window (avoid business hours)
  maintenance_policy {
    start_time = var.maintenance_window_start
    day        = var.maintenance_window_day
  }
  
  tags = concat(
    var.tags,
    [
      "environment:${var.environment}",
      "managed-by:terraform",
      "layer:kubernetes"
    ]
  )
}

# System Node Pool - Control plane workloads
resource "digitalocean_kubernetes_node_pool" "system" {
  cluster_id = digitalocean_kubernetes_cluster.webshop.id
  
  name       = "${var.cluster_name}-system"
  size       = var.system_node_size
  node_count = var.system_node_count
  
  # No auto-scaling for system pool (stability)
  auto_scale = false
  
  # System pool taints
  taint {
    key    = "node-role.kubernetes.io/system"
    value  = "true"
    effect = "NoSchedule"
  }
  
  labels = {
    "node-role.kubernetes.io/system" = "true"
    "workload-type"                  = "system"
  }
  
  tags = concat(
    var.tags,
    [
      "environment:${var.environment}",
      "pool:system",
      "managed-by:terraform"
    ]
  )
}

# Application Node Pool - Application workloads
resource "digitalocean_kubernetes_node_pool" "application" {
  cluster_id = digitalocean_kubernetes_cluster.webshop.id
  
  name       = "${var.cluster_name}-application"
  size       = var.app_node_size
  
  # Auto-scaling configuration
  auto_scale = var.app_autoscaling_enabled
  node_count = var.app_autoscaling_enabled ? null : var.app_node_count_min
  min_nodes  = var.app_autoscaling_enabled ? var.app_node_count_min : null
  max_nodes  = var.app_autoscaling_enabled ? var.app_node_count_max : null
  
  labels = {
    "node-role.kubernetes.io/application" = "true"
    "workload-type"                       = "application"
  }
  
  tags = concat(
    var.tags,
    [
      "environment:${var.environment}",
      "pool:application",
      "managed-by:terraform"
    ]
  )
}

# Kubeconfig for cluster access
resource "local_file" "kubeconfig" {
  count    = var.write_kubeconfig ? 1 : 0
  content  = digitalocean_kubernetes_cluster.webshop.kube_config[0].raw_config
  filename = "${path.root}/kubeconfig-${var.environment}.yaml"
  
  file_permission = "0600"
}
