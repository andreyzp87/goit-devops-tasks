output "prometheus_service" {
  description = "Prometheus service name"
  value       = "prometheus-kube-prometheus-prometheus"
}

output "grafana_service" {
  description = "Grafana service name"
  value       = var.install_separate_grafana ? "grafana" : "prometheus-grafana"
}

output "namespace" {
  description = "Monitoring namespace"
  value       = var.namespace
}

output "prometheus_url" {
  description = "Prometheus internal URL"
  value       = "http://prometheus-kube-prometheus-prometheus.${var.namespace}.svc.cluster.local:9090"
}

output "grafana_url" {
  description = "Grafana internal URL"
  value       = "http://prometheus-grafana.${var.namespace}.svc.cluster.local"
}

output "grafana_admin_password" {
  description = "Grafana admin password retrieval command"
  value       = "kubectl get secret --namespace ${var.namespace} prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 --decode"
  sensitive   = true
}
