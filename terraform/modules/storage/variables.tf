# Storage Module Variables

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "csi_driver" {
  description = "CSI driver provisioner (e.g., dobs.csi.digitalocean.com)"
  type        = string
  default     = "dobs.csi.digitalocean.com"
}

# Volume Types (provider-specific)
variable "standard_volume_type" {
  description = "Volume type for standard storage class"
  type        = string
  default     = "do-block-storage"
}

variable "fast_volume_type" {
  description = "Volume type for fast storage class (SSD)"
  type        = string
  default     = "do-block-storage"  # DigitalOcean uses same, but can specify SSD tier
}

variable "backup_volume_type" {
  description = "Volume type for backup storage class"
  type        = string
  default     = "do-block-storage"
}

# Storage Limits
variable "enable_storage_quotas" {
  description = "Enable storage resource quotas to prevent disk exhaustion"
  type        = bool
  default     = true
}

variable "storage_quota_dev" {
  description = "Storage quota for dev environment (in Gi)"
  type        = number
  default     = 100
}

variable "storage_quota_staging" {
  description = "Storage quota for staging environment (in Gi)"
  type        = number
  default     = 500
}

variable "storage_quota_production" {
  description = "Storage quota for production environment (in Gi)"
  type        = number
  default     = 2048
}

# Snapshot Configuration
variable "enable_snapshots" {
  description = "Enable volume snapshots for backup"
  type        = bool
  default     = true
}

variable "snapshot_retention_days" {
  description = "Snapshot retention period in days"
  type        = number
  default     = 30
}
