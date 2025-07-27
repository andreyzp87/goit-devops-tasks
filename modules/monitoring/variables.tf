variable "namespace" {
  description = "Kubernetes namespace for monitoring components"
  type        = string
  default     = "monitoring"
}

variable "prometheus_chart_version" {
  description = "Prometheus chart version"
  type        = string
  default     = "55.5.0"
}

variable "grafana_chart_version" {
  description = "Grafana chart version"
  type        = string
  default     = "7.0.0"
}

variable "prometheus_storage_size" {
  description = "Prometheus storage size"
  type        = string
  default     = "50Gi"
}

variable "grafana_storage_size" {
  description = "Grafana storage size"
  type        = string
  default     = "10Gi"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "enable_persistence" {
  description = "Enable persistent storage for monitoring components"
  type        = bool
  default     = true
}

variable "install_separate_grafana" {
  description = "Install Grafana separately (if false, uses kube-prometheus-stack Grafana)"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "EKS cluster name for monitoring"
  type        = string
}
