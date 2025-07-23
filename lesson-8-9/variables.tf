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
