# Storage Module
# Configures storage classes and CSI driver for persistent storage

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# Standard Storage Class (default)
resource "kubernetes_storage_class_v1" "standard" {
  metadata {
    name = "standard"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
    labels = {
      "managed-by" = "terraform"
      "layer"      = "storage"
    }
  }
  
  storage_provisioner    = var.csi_driver
  reclaim_policy         = "Retain"  # Don't delete data on PVC deletion
  volume_binding_mode    = "WaitForFirstConsumer"  # Schedule pod first
  allow_volume_expansion = true
  
  parameters = {
    type = var.standard_volume_type
  }
}

# Fast Storage Class (SSD for databases)
resource "kubernetes_storage_class_v1" "fast" {
  metadata {
    name = "fast"
    labels = {
      "managed-by" = "terraform"
      "layer"      = "storage"
      "purpose"    = "database"
    }
  }
  
  storage_provisioner    = var.csi_driver
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  
  parameters = {
    type = var.fast_volume_type
  }
}

# Backup Storage Class (for Velero)
resource "kubernetes_storage_class_v1" "backup" {
  metadata {
    name = "backup"
    labels = {
      "managed-by" = "terraform"
      "layer"      = "storage"
      "purpose"    = "backup"
    }
  }
  
  storage_provisioner    = var.csi_driver
  reclaim_policy         = "Retain"
  volume_binding_mode    = "Immediate"  # Create immediately for backups
  allow_volume_expansion = true
  
  parameters = {
    type = var.backup_volume_type
  }
}

# Volume Snapshot Class (for backups)
resource "kubernetes_volume_snapshot_class_v1" "standard" {
  metadata {
    name = "standard-snapshots"
    labels = {
      "managed-by" = "terraform"
      "layer"      = "storage"
    }
  }
  
  driver         = var.csi_driver
  deletion_policy = "Retain"
  
  parameters = {
    snapshot_type = "standard"
  }
}

# Namespace for storage system components
resource "kubernetes_namespace_v1" "storage_system" {
  metadata {
    name = "storage-system"
    labels = {
      "name"       = "storage-system"
      "managed-by" = "terraform"
    }
  }
}

# Resource Quotas for storage (prevent disk exhaustion)
resource "kubernetes_resource_quota_v1" "storage_dev" {
  count = var.environment == "dev" ? 1 : 0
  
  metadata {
    name      = "storage-quota"
    namespace = "default"
  }
  
  spec {
    hard = {
      "requests.storage"           = "100Gi"
      "persistentvolumeclaims"     = "10"
    }
  }
}

resource "kubernetes_resource_quota_v1" "storage_staging" {
  count = var.environment == "staging" ? 1 : 0
  
  metadata {
    name      = "storage-quota"
    namespace = "default"
  }
  
  spec {
    hard = {
      "requests.storage"           = "500Gi"
      "persistentvolumeclaims"     = "25"
    }
  }
}

resource "kubernetes_resource_quota_v1" "storage_production" {
  count = var.environment == "production" ? 1 : 0
  
  metadata {
    name      = "storage-quota"
    namespace = "default"
  }
  
  spec {
    hard = {
      "requests.storage"           = "2Ti"
      "persistentvolumeclaims"     = "50"
    }
  }
}
