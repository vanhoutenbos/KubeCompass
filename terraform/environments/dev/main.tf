# Dev Environment - Main Configuration

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
  }
  
  backend "s3" {
    # Configure in backend.tf
  }
}

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

locals {
  environment  = "dev"
  cluster_name = "webshop-dev"
  region       = "ams3"
  
  common_tags = [
    "environment:dev",
    "project:webshop",
    "managed-by:terraform"
  ]
}

module "kubernetes_cluster" {
  source = "../../modules/kubernetes-cluster"
  
  cluster_name       = local.cluster_name
  region             = local.region
  environment        = local.environment
  kubernetes_version = var.kubernetes_version
  
  enable_ha            = false  # Cost savings for dev
  auto_upgrade_enabled = true
  
  maintenance_window_start = "01:00"
  maintenance_window_day   = "any"
  
  system_node_size  = "s-2vcpu-4gb"
  system_node_count = 2
  
  app_node_size             = "s-2vcpu-4gb"  # Smaller for dev
  app_autoscaling_enabled   = false  # Fixed size for dev
  app_node_count_min        = 3
  app_node_count_max        = 3
  
  tags = local.common_tags
  write_kubeconfig = true
}

module "networking" {
  source = "../../modules/networking"
  
  vpc_name     = "${local.cluster_name}-vpc"
  vpc_cidr     = "10.2.0.0/16"
  region       = local.region
  environment  = local.environment
  cluster_name = local.cluster_name
  cluster_tags = local.common_tags
  
  api_allowed_sources = ["0.0.0.0/0"]
  
  loadbalancer_size      = "small"
  enable_proxy_protocol  = false  # Simplify for dev
  create_reserved_ip     = false  # Dynamic IP OK for dev
  
  cilium_version   = "1.14.5"
  enable_hubble    = true
  enable_hubble_ui = true
}

module "storage" {
  source = "../../modules/storage"
  
  environment = local.environment
  csi_driver  = "dobs.csi.digitalocean.com"
  
  enable_storage_quotas = true
  storage_quota_dev     = 100  # 100GB
  
  enable_snapshots        = false  # Disable for dev
  snapshot_retention_days = 7
  
  depends_on = [module.kubernetes_cluster]
}
