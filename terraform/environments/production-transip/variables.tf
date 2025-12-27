# Variables for Production TransIP Environment

# ============================================================================
# CLUSTER CONFIGURATION
# ============================================================================

variable "kubeconfig_path" {
  description = "Path to kubeconfig file from TransIP cluster. Should be retrieved from secrets manager."
  type        = string
  default     = "~/.kube/transip-webshop-prod.yaml"
  
  validation {
    condition     = fileexists(var.kubeconfig_path)
    error_message = "Kubeconfig file does not exist. Please retrieve from TransIP and store securely."
  }
}

# ============================================================================
# TRANSIP PROVIDER CONFIGURATION
# ============================================================================

variable "transip_account" {
  description = "TransIP account name for DNS management"
  type        = string
}

variable "transip_private_key" {
  description = "TransIP API private key (PEM format)"
  type        = string
  sensitive   = true
}

# ============================================================================
# DNS CONFIGURATION
# ============================================================================

variable "domain" {
  description = "Primary domain for the webshop (e.g., webshop.example.nl)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+\\.[a-z]{2,}$", var.domain))
    error_message = "Domain must be a valid DNS name."
  }
}

# ============================================================================
# APPLICATION SECRETS
# ============================================================================

variable "argocd_admin_password_bcrypt" {
  description = "Bcrypt hash of ArgoCD admin password. Generate with: htpasswd -nbBC 10 admin <password>"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana dashboard"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.grafana_admin_password) >= 12
    error_message = "Grafana admin password must be at least 12 characters."
  }
}

# ============================================================================
# MONITORING CONFIGURATION
# ============================================================================

variable "prometheus_retention_days" {
  description = "Number of days to retain Prometheus metrics"
  type        = number
  default     = 30
  
  validation {
    condition     = var.prometheus_retention_days >= 7 && var.prometheus_retention_days <= 90
    error_message = "Retention must be between 7 and 90 days."
  }
}

variable "prometheus_storage_size" {
  description = "Storage size for Prometheus (e.g., 50Gi)"
  type        = string
  default     = "50Gi"
}

variable "grafana_storage_size" {
  description = "Storage size for Grafana (e.g., 10Gi)"
  type        = string
  default     = "10Gi"
}

# ============================================================================
# RESOURCE LIMITS
# ============================================================================

variable "ingress_nginx_replicas" {
  description = "Number of NGINX Ingress Controller replicas"
  type        = number
  default     = 2
  
  validation {
    condition     = var.ingress_nginx_replicas >= 2
    error_message = "At least 2 replicas required for high availability."
  }
}

variable "argocd_server_replicas" {
  description = "Number of ArgoCD server replicas"
  type        = number
  default     = 2
  
  validation {
    condition     = var.argocd_server_replicas >= 1
    error_message = "At least 1 replica required."
  }
}

# ============================================================================
# FEATURE FLAGS
# ============================================================================

variable "enable_network_policies" {
  description = "Enable Kubernetes network policies for production namespace"
  type        = bool
  default     = true
}

variable "enable_pod_security_policies" {
  description = "Enable Pod Security Standards enforcement"
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Enable cert-manager for automatic SSL/TLS certificates"
  type        = bool
  default     = true
}

variable "enable_external_secrets" {
  description = "Enable External Secrets Operator for secrets management"
  type        = bool
  default     = true
}

# ============================================================================
# TAGS & LABELS
# ============================================================================

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "additional_labels" {
  description = "Additional labels to apply to Kubernetes resources"
  type        = map(string)
  default     = {}
}
