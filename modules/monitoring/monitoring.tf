terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

# Create monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

# Install Prometheus
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_chart_version

  values = [
    templatefile("${path.module}/values.yaml", {
      prometheus_storage_size = var.prometheus_storage_size
      admin_password          = var.grafana_admin_password
      grafana_admin_password  = var.grafana_admin_password
      enable_persistence      = var.enable_persistence
    })
  ]

  create_namespace = false
  depends_on       = [kubernetes_namespace.monitoring]
}

# Optional: Install standalone Grafana if you prefer separate installation
# resource "helm_release" "grafana" {
#   count      = var.install_separate_grafana ? 1 : 0
#   name       = "grafana"
#   namespace  = var.namespace
#   repository = "https://grafana.github.io/helm-charts"
#   chart      = "grafana"
#   version    = var.grafana_chart_version

#   values = [
#     templatefile("${path.module}/grafana-values.yaml", {
#       admin_password     = var.grafana_admin_password
#       enable_persistence = var.enable_persistence
#       storage_size       = var.grafana_storage_size
#     })
#   ]

#   create_namespace = false
#   depends_on       = [kubernetes_namespace.monitoring]
# }
