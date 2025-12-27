# Storage Module Outputs

output "storage_classes" {
  description = "List of created storage classes"
  value = {
    standard = kubernetes_storage_class_v1.standard.metadata[0].name
    fast     = kubernetes_storage_class_v1.fast.metadata[0].name
    backup   = kubernetes_storage_class_v1.backup.metadata[0].name
  }
}

output "default_storage_class" {
  description = "Default storage class name"
  value       = kubernetes_storage_class_v1.standard.metadata[0].name
}

output "snapshot_class" {
  description = "Volume snapshot class name"
  value       = kubernetes_volume_snapshot_class_v1.standard.metadata[0].name
}

output "storage_namespace" {
  description = "Namespace for storage system components"
  value       = kubernetes_namespace_v1.storage_system.metadata[0].name
}

output "storage_quotas" {
  description = "Storage quotas per environment"
  value = {
    environment = var.environment
    quota = var.environment == "dev" ? var.storage_quota_dev : (
      var.environment == "staging" ? var.storage_quota_staging : var.storage_quota_production
    )
  }
}

output "csi_driver" {
  description = "CSI driver name"
  value       = var.csi_driver
}

output "storage_notes" {
  description = "Storage configuration notes"
  value = <<-EOT
    Storage Configuration Summary:
    - CSI Driver: ${var.csi_driver}
    - Default Storage Class: standard (${var.standard_volume_type})
    - Fast Storage Class: fast (${var.fast_volume_type}) - Use for databases
    - Backup Storage Class: backup (${var.backup_volume_type}) - Use for Velero
    - Volume Snapshots: ${var.enable_snapshots ? "Enabled" : "Disabled"}
    - Snapshot Retention: ${var.snapshot_retention_days} days
    
    Usage Examples:
    1. Standard PVC:
       storageClassName: standard
       
    2. Database PVC (fast):
       storageClassName: fast
       
    3. Backup PVC:
       storageClassName: backup
    
    Reclaim Policy: Retain (manual cleanup required)
    Volume Binding: WaitForFirstConsumer (optimal scheduling)
  EOT
}
