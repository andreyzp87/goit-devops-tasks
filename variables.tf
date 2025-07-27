variable "github_username" {
  description = "GitHub username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "postgres_host" {
  description = "PostgreSQL host"
  type        = string
  default     = "localhost"
}

variable "postgres_port" {
  description = "PostgreSQL port"
  type        = string
  default     = "5432"
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "myapp"
}

variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "enable_monitoring_persistence" {
  description = "Enable persistent storage for monitoring"
  type        = bool
  default     = false
}
