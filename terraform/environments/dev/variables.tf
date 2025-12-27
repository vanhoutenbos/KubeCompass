# Production Environment - Variables

variable "do_token" {
  description = "DigitalOcean API token (sensitive)"
  type        = string
  sensitive   = true
}

variable "kubernetes_version" {
  description = "Kubernetes version (N-1 strategy)"
  type        = string
  default     = "1.28.2-do.0"  # Update quarterly after testing
}

variable "api_allowed_sources" {
  description = "CIDR blocks allowed to access Kubernetes API"
  type        = list(string)
  # Example: Office IP, VPN gateway
  # default = ["203.0.113.0/24", "198.51.100.0/24"]
  default = ["0.0.0.0/0"]  # CHANGE IN PRODUCTION!
}

# Tagging
variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = list(string)
  default     = []
}
