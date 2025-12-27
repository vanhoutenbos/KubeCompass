# Networking Module Outputs

output "vpc_id" {
  description = "VPC ID"
  value       = digitalocean_vpc.kubernetes.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = digitalocean_vpc.kubernetes.ip_range
}

output "vpc_urn" {
  description = "VPC URN"
  value       = digitalocean_vpc.kubernetes.urn
}

output "firewall_id" {
  description = "Firewall ID"
  value       = digitalocean_firewall.kubernetes.id
}

output "loadbalancer_id" {
  description = "Load balancer ID"
  value       = digitalocean_loadbalancer.ingress.id
}

output "loadbalancer_ip" {
  description = "Load balancer public IP"
  value       = digitalocean_loadbalancer.ingress.ip
}

output "loadbalancer_urn" {
  description = "Load balancer URN"
  value       = digitalocean_loadbalancer.ingress.urn
}

output "reserved_ip" {
  description = "Reserved IP address (if created)"
  value       = var.create_reserved_ip ? digitalocean_reserved_ip.ingress[0].ip_address : null
}

output "reserved_ip_urn" {
  description = "Reserved IP URN (if created)"
  value       = var.create_reserved_ip ? digitalocean_reserved_ip.ingress[0].urn : null
}

# Cilium Configuration Reference
output "cilium_notes" {
  description = "Cilium installation notes (installed via Helm, not Terraform)"
  value = <<-EOT
    Cilium CNI Configuration:
    - Version: ${var.cilium_version}
    - Hubble Enabled: ${var.enable_hubble}
    - Hubble UI: ${var.enable_hubble_ui}
    
    Installation:
    1. Add Cilium Helm repo: helm repo add cilium https://helm.cilium.io/
    2. Install Cilium: helm install cilium cilium/cilium --version ${var.cilium_version} \
       --namespace kube-system \
       --set hubble.enabled=${var.enable_hubble} \
       --set hubble.ui.enabled=${var.enable_hubble_ui}
    
    Access Hubble UI (ops only):
    kubectl port-forward -n kube-system svc/hubble-ui 12000:80
  EOT
}
