# Networking Module Variables

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "region" {
  description = "Cloud provider region"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
}

variable "cluster_name" {
  description = "Kubernetes cluster name (for firewall and LB naming)"
  type        = string
}

variable "cluster_tags" {
  description = "Tags to apply to cluster resources"
  type        = list(string)
}

# Firewall Variables
variable "api_allowed_sources" {
  description = "CIDR blocks allowed to access Kubernetes API"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Restrict in production to office/VPN IPs
}

variable "nodeport_allowed_sources" {
  description = "CIDR blocks allowed to access NodePort services"
  type        = list(string)
  default     = []  # Empty = no NodePort access from outside
}

# Load Balancer Variables
variable "loadbalancer_size" {
  description = "Load balancer size (small, medium, large)"
  type        = string
  default     = "small"
  
  validation {
    condition     = contains(["small", "medium", "large"], var.loadbalancer_size)
    error_message = "Load balancer size must be small, medium, or large."
  }
}

variable "enable_proxy_protocol" {
  description = "Enable proxy protocol to pass client IP to backend"
  type        = bool
  default     = true
}

variable "create_reserved_ip" {
  description = "Create reserved IP for load balancer (stable DNS)"
  type        = bool
  default     = true
}

# Cilium Configuration (applied via Helm in Kubernetes, not Terraform)
variable "cilium_version" {
  description = "Cilium version to document (actual installation via Helm)"
  type        = string
  default     = "1.14.5"
}

variable "enable_hubble" {
  description = "Enable Hubble for network observability"
  type        = bool
  default     = true
}

variable "enable_hubble_ui" {
  description = "Enable Hubble UI (access via port-forward only)"
  type        = bool
  default     = true
}
