# Kubernetes Cluster Module Variables

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "region" {
  description = "Cloud provider region (e.g., ams3 for Amsterdam)"
  type        = string
  default     = "ams3"
}

variable "kubernetes_version" {
  description = "Kubernetes version (N-1 strategy: one version behind latest)"
  type        = string
  # Update quarterly after testing in dev/staging
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "enable_ha" {
  description = "Enable high availability control plane (recommended for production)"
  type        = bool
  default     = false
}

variable "auto_upgrade_enabled" {
  description = "Enable automatic patch upgrades (security patches only)"
  type        = bool
  default     = true
}

variable "maintenance_window_start" {
  description = "Maintenance window start time (HH:MM in UTC, avoid business hours)"
  type        = string
  default     = "03:00"
}

variable "maintenance_window_day" {
  description = "Maintenance window day (monday-sunday or any)"
  type        = string
  default     = "tuesday"
}

# System Node Pool Variables
variable "system_node_size" {
  description = "Node size for system pool (e.g., s-2vcpu-4gb for DigitalOcean)"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "system_node_count" {
  description = "Number of nodes in system pool (minimum 2 for HA)"
  type        = number
  default     = 2
  
  validation {
    condition     = var.system_node_count >= 2
    error_message = "System node pool requires at least 2 nodes for high availability."
  }
}

# Application Node Pool Variables
variable "app_node_size" {
  description = "Node size for application pool (e.g., s-4vcpu-8gb for DigitalOcean)"
  type        = string
  default     = "s-4vcpu-8gb"
}

variable "app_autoscaling_enabled" {
  description = "Enable auto-scaling for application node pool"
  type        = bool
  default     = true
}

variable "app_node_count_min" {
  description = "Minimum number of nodes in application pool"
  type        = number
  default     = 3
  
  validation {
    condition     = var.app_node_count_min >= 3
    error_message = "Application pool requires at least 3 nodes for high availability."
  }
}

variable "app_node_count_max" {
  description = "Maximum number of nodes in application pool (auto-scaling limit)"
  type        = number
  default     = 6
  
  validation {
    condition     = var.app_node_count_max >= var.app_node_count_min
    error_message = "Maximum nodes must be greater than or equal to minimum nodes."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = list(string)
  default     = []
}

variable "write_kubeconfig" {
  description = "Write kubeconfig file locally (useful for initial setup, disable in production)"
  type        = bool
  default     = false
}
