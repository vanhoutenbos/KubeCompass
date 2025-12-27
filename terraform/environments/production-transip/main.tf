# Production Environment - TransIP Kubernetes
# Hybrid IaC Approach: Manual cluster provisioning + Terraform for in-cluster resources

terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    transip = {
      source  = "aequitas/transip"
      version = "~> 0.7"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
  
  backend "s3" {
    # Configure in backend.tf
    # Uses S3-compatible backend (MinIO, DigitalOcean Spaces, AWS S3)
  }
}

# Local Variables
locals {
  environment  = "production"
  cluster_name = "webshop-prod"
  domain       = var.domain
  
  common_tags = {
    environment = "production"
    project     = "webshop"
    managed-by  = "terraform"
    team        = "platform"
  }
  
  common_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
    "environment"                  = "production"
  }
}

# ============================================================================
# PROVIDERS
# ============================================================================

# Kubernetes Provider - uses kubeconfig from TransIP cluster
# NOTE: Kubeconfig is retrieved from secrets manager, NOT managed by Terraform
provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

# TransIP Provider - for DNS management
provider "transip" {
  account_name = var.transip_account
  private_key  = var.transip_private_key
}

# ============================================================================
# CORE NAMESPACES
# ============================================================================

# Production application namespace
resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
    labels = merge(local.common_labels, {
      "name"                         = "production"
      "pod-security.kubernetes.io/enforce" = "restricted"
    })
  }
}

# Staging namespace
resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
    labels = merge(local.common_labels, {
      "name"                         = "staging"
      "pod-security.kubernetes.io/enforce" = "restricted"
    })
  }
}

# ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = merge(local.common_labels, {
      "name" = "argocd"
    })
  }
}

# Monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = merge(local.common_labels, {
      "name" = "monitoring"
    })
  }
}

# Ingress namespace
resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress-nginx"
    labels = merge(local.common_labels, {
      "name" = "ingress-nginx"
    })
  }
}

# ============================================================================
# STORAGE CLASSES
# ============================================================================

# Fast SSD storage class for databases
resource "kubernetes_storage_class" "fast_ssd" {
  metadata {
    name = "fast-ssd"
    labels = local.common_labels
  }
  
  storage_provisioner = "csi.transip.nl"
  reclaim_policy      = "Retain"  # Don't delete data on PVC deletion
  volume_binding_mode = "WaitForFirstConsumer"
  
  parameters = {
    type = "fast-ssd"
  }
}

# Backup storage class
resource "kubernetes_storage_class" "backup" {
  metadata {
    name = "backup"
    labels = local.common_labels
  }
  
  storage_provisioner = "csi.transip.nl"
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
  
  parameters = {
    type = "standard"
  }
}

# ============================================================================
# RBAC - SERVICE ACCOUNTS
# ============================================================================

# ArgoCD service account with cluster-admin (GitOps automation)
resource "kubernetes_service_account" "argocd" {
  metadata {
    name      = "argocd-application-controller"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels    = local.common_labels
  }
}

resource "kubernetes_cluster_role_binding" "argocd" {
  metadata {
    name   = "argocd-application-controller"
    labels = local.common_labels
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.argocd.metadata[0].name
    namespace = kubernetes_service_account.argocd.metadata[0].namespace
  }
}

# ============================================================================
# NETWORK POLICIES
# ============================================================================

# Default deny all ingress in production namespace
resource "kubernetes_network_policy" "production_default_deny" {
  metadata {
    name      = "default-deny-ingress"
    namespace = kubernetes_namespace.production.metadata[0].name
    labels    = local.common_labels
  }
  
  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

# Allow ingress from NGINX ingress controller
resource "kubernetes_network_policy" "production_allow_ingress" {
  metadata {
    name      = "allow-ingress-nginx"
    namespace = kubernetes_namespace.production.metadata[0].name
    labels    = local.common_labels
  }
  
  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name" = "webshop"
      }
    }
    
    policy_types = ["Ingress"]
    
    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "ingress-nginx"
          }
        }
      }
      
      ports {
        protocol = "TCP"
        port     = "8080"
      }
    }
  }
}

# ============================================================================
# DNS RECORDS (via TransIP provider)
# ============================================================================

# NOTE: This requires getting the LoadBalancer IP from NGINX Ingress
# We use data source to get the IP after ingress controller is deployed

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }
  
  # This will fail if ingress controller is not deployed yet
  # Deploy ingress controller first via Helm (see below)
  depends_on = [helm_release.ingress_nginx]
}

# A record for main domain
resource "transip_dns_record" "webshop_root" {
  domain  = local.domain
  name    = "@"
  type    = "A"
  content = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip
  ttl     = 300
}

# A record for www subdomain
resource "transip_dns_record" "webshop_www" {
  domain  = local.domain
  name    = "www"
  type    = "A"
  content = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip
  ttl     = 300
}

# A record for ArgoCD
resource "transip_dns_record" "argocd" {
  domain  = local.domain
  name    = "argocd"
  type    = "A"
  content = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip
  ttl     = 300
}

# A record for Grafana
resource "transip_dns_record" "grafana" {
  domain  = local.domain
  name    = "grafana"
  type    = "A"
  content = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip
  ttl     = 300
}

# ============================================================================
# HELM RELEASES - PLATFORM COMPONENTS
# ============================================================================

# NGINX Ingress Controller
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.3"
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  
  values = [
    yamlencode({
      controller = {
        replicaCount = 2
        
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/transip-loadbalancer-name" = "${local.cluster_name}-ingress"
          }
        }
        
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }
        
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        affinity = {
          podAntiAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [{
              weight = 100
              podAffinityTerm = {
                labelSelector = {
                  matchExpressions = [{
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values   = ["ingress-nginx"]
                  }]
                }
                topologyKey = "kubernetes.io/hostname"
              }
            }]
          }
        }
      }
    })
  ]
}

# cert-manager for SSL/TLS certificates
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.13.2"
  namespace  = "cert-manager"
  
  create_namespace = true
  
  set {
    name  = "installCRDs"
    value = "true"
  }
  
  set {
    name  = "prometheus.enabled"
    value = "true"
  }
}

# ArgoCD for GitOps
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.4"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  
  values = [
    yamlencode({
      server = {
        replicas = 2
        
        ingress = {
          enabled = true
          ingressClassName = "nginx"
          annotations = {
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
          }
          hosts = ["argocd.${local.domain}"]
          tls = [{
            secretName = "argocd-tls"
            hosts      = ["argocd.${local.domain}"]
          }]
        }
        
        config = {
          "url" = "https://argocd.${local.domain}"
        }
      }
      
      configs = {
        secret = {
          argocdServerAdminPassword = var.argocd_admin_password_bcrypt
        }
      }
      
      repoServer = {
        replicas = 2
      }
    })
  ]
}

# Prometheus + Grafana stack
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "54.0.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  
  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          retention = "30d"
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "fast-ssd"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "50Gi"
                  }
                }
              }
            }
          }
          
          resources = {
            requests = {
              cpu    = "500m"
              memory = "2Gi"
            }
            limits = {
              cpu    = "2000m"
              memory = "4Gi"
            }
          }
        }
      }
      
      grafana = {
        enabled = true
        adminPassword = var.grafana_admin_password
        
        ingress = {
          enabled = true
          ingressClassName = "nginx"
          annotations = {
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
          }
          hosts = ["grafana.${local.domain}"]
          tls = [{
            secretName = "grafana-tls"
            hosts      = ["grafana.${local.domain}"]
          }]
        }
        
        persistence = {
          enabled = true
          storageClassName = "fast-ssd"
          size = "10Gi"
        }
      }
      
      alertmanager = {
        enabled = true
        alertmanagerSpec = {
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "fast-ssd"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "10Gi"
                  }
                }
              }
            }
          }
        }
      }
    })
  ]
}

# External Secrets Operator (for secrets management)
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.11"
  namespace  = "external-secrets"
  
  create_namespace = true
  
  set {
    name  = "installCRDs"
    value = "true"
  }
}

# ============================================================================
# OUTPUTS
# ============================================================================

# These outputs can be used by other Terraform modules or for reference
output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = local.cluster_name
}

output "namespaces" {
  description = "Created namespaces"
  value = {
    production = kubernetes_namespace.production.metadata[0].name
    staging    = kubernetes_namespace.staging.metadata[0].name
    argocd     = kubernetes_namespace.argocd.metadata[0].name
    monitoring = kubernetes_namespace.monitoring.metadata[0].name
    ingress    = kubernetes_namespace.ingress.metadata[0].name
  }
}

output "ingress_ip" {
  description = "LoadBalancer IP for ingress controller"
  value       = try(data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip, "Not yet available")
}

output "argocd_url" {
  description = "ArgoCD web UI URL"
  value       = "https://argocd.${local.domain}"
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "https://grafana.${local.domain}"
}
