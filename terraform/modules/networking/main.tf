# Networking Module
# Configures VPC, firewall rules, and prepares for Cilium CNI

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# VPC for Kubernetes cluster
resource "digitalocean_vpc" "kubernetes" {
  name        = var.vpc_name
  region      = var.region
  description = "VPC for ${var.environment} Kubernetes cluster"
  ip_range    = var.vpc_cidr
}

# Firewall for Kubernetes nodes
resource "digitalocean_firewall" "kubernetes" {
  name = "${var.cluster_name}-firewall"
  
  tags = var.cluster_tags
  
  # Inbound Rules
  
  # Allow Kubernetes API (6443)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "6443"
    source_addresses = var.api_allowed_sources
  }
  
  # Allow HTTPS ingress (443)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  # Allow HTTP ingress (80) - redirect to HTTPS
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  # Allow NodePort range (if needed for services)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "30000-32767"
    source_addresses = var.nodeport_allowed_sources
  }
  
  # Allow Cilium VXLAN/Geneve (for multi-cluster, future)
  inbound_rule {
    protocol         = "udp"
    port_range       = "8472"
    source_addresses = [var.vpc_cidr]
  }
  
  # Allow Cilium health checks
  inbound_rule {
    protocol         = "tcp"
    port_range       = "4240"
    source_addresses = [var.vpc_cidr]
  }
  
  # Allow Hubble metrics/UI (only from VPC)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "4244-4245"
    source_addresses = [var.vpc_cidr]
  }
  
  # Outbound Rules
  
  # Allow all outbound TCP
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  # Allow all outbound UDP
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  # Allow ICMP (ping)
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Load Balancer for Ingress Controller
resource "digitalocean_loadbalancer" "ingress" {
  name   = "${var.cluster_name}-ingress-lb"
  region = var.region
  vpc_uuid = digitalocean_vpc.kubernetes.id
  
  size = var.loadbalancer_size
  
  # HTTP forwarding (redirect to HTTPS)
  forwarding_rule {
    entry_protocol  = "http"
    entry_port      = 80
    target_protocol = "http"
    target_port     = 80
  }
  
  # HTTPS forwarding
  forwarding_rule {
    entry_protocol  = "https"
    entry_port      = 443
    target_protocol = "http"
    target_port     = 80
    tls_passthrough = false
  }
  
  # Health check
  healthcheck {
    protocol               = "http"
    port                   = 80
    path                   = "/healthz"
    check_interval_seconds = 10
    response_timeout_seconds = 5
    unhealthy_threshold    = 3
    healthy_threshold      = 2
  }
  
  # Sticky sessions for webshop (optional, can be removed if using Redis sessions)
  sticky_sessions {
    type               = "cookies"
    cookie_name        = "lb-session"
    cookie_ttl_seconds = 3600
  }
  
  # Droplet tag for automatic node discovery
  droplet_tag = "k8s:${var.cluster_name}"
  
  # Enable proxy protocol for real client IP
  enable_proxy_protocol = var.enable_proxy_protocol
}

# Reserved IP for Load Balancer (optional, for stable DNS)
resource "digitalocean_reserved_ip" "ingress" {
  count  = var.create_reserved_ip ? 1 : 0
  region = var.region
}

resource "digitalocean_reserved_ip_assignment" "ingress" {
  count        = var.create_reserved_ip ? 1 : 0
  ip_address   = digitalocean_reserved_ip.ingress[0].ip_address
  droplet_id   = digitalocean_loadbalancer.ingress.id
}
