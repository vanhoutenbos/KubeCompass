# Production Environment - Main Configuration

terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
  
  backend "s3" {
    # Configure in backend.tf
  }
}

# Provider Configuration
provider "digitalocean" {
  token = var.do_token
}

provider "kubernetes" {
  host  = module.kubernetes_cluster.cluster_endpoint
  token = module.kubernetes_cluster.kubeconfig_raw
  cluster_ca_certificate = base64decode(
    module.kubernetes_cluster.cluster_ca_certificate
  )
}

# Local Variables
locals {
  environment  = "production"
  cluster_name = "webshop-prod"
  region       = "ams3"  # Amsterdam
  
  common_tags = [
    "environment:production",
    "project:webshop",
    "managed-by:terraform",
    "team:platform"
  ]
}

# Kubernetes Cluster Module
module "kubernetes_cluster" {
  source = "../../modules/kubernetes-cluster"
  
  cluster_name       = local.cluster_name
  region             = local.region
  environment        = local.environment
  kubernetes_version = var.kubernetes_version
  
  # High Availability
  enable_ha = true
  
  # Auto-upgrade (security patches only)
  auto_upgrade_enabled = true
  
  # Maintenance window (Tuesday 3:00 AM UTC = 4:00 AM CET, off-peak)
  maintenance_window_start = "03:00"
  maintenance_window_day   = "tuesday"
  
  # System Node Pool
  system_node_size  = "s-4vcpu-8gb"  # Larger for production
  system_node_count = 2
  
  # Application Node Pool (auto-scaling)
  app_node_size             = "s-4vcpu-8gb"
  app_autoscaling_enabled   = true
  app_node_count_min        = 3
  app_node_count_max        = 6
  
  tags            = local.common_tags
  write_kubeconfig = false  # Don't write kubeconfig in production
}

# Networking Module
module "networking" {
  source = "../../modules/networking"
  
  vpc_name     = "${local.cluster_name}-vpc"
  vpc_cidr     = "10.0.0.0/16"
  region       = local.region
  environment  = local.environment
  cluster_name = local.cluster_name
  cluster_tags = local.common_tags
  
  # Restrict API access to office/VPN IPs
  api_allowed_sources = var.api_allowed_sources
  
  # No NodePort access from outside
  nodeport_allowed_sources = []
  
  # Load Balancer Configuration
  loadbalancer_size      = "medium"  # Medium for production traffic
  enable_proxy_protocol  = true
  create_reserved_ip     = true  # Stable IP for DNS
  
  # Cilium Configuration
  cilium_version   = "1.14.5"
  enable_hubble    = true
  enable_hubble_ui = true
}

# Storage Module
module "storage" {
  source = "../../modules/storage"
  
  environment = local.environment
  csi_driver  = "dobs.csi.digitalocean.com"
  
  # Storage quotas (prevent disk exhaustion)
  enable_storage_quotas      = true
  storage_quota_production   = 2048  # 2TB
  
  # Snapshots
  enable_snapshots         = true
  snapshot_retention_days  = 30
  
  depends_on = [module.kubernetes_cluster]
}
