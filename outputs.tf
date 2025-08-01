output "s3_bucket_name" {
  description = "S3 bucket with Terraform state"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table with Terraform state lock"
  value       = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnets"
  value       = module.vpc.private_subnet_ids
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = module.eks.node_role_arn
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider_url
}

output "jenkins_release" {
  value = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  value = module.jenkins.jenkins_namespace
}

output "postgres_endpoint" {
  description = "PostgreSQL endpoint"
  value       = module.rds.endpoint
  sensitive   = true
}

output "postgres_database" {
  description = "PostgreSQL database name"
  value       = var.postgres_db
}

output "postgres_username" {
  description = "PostgreSQL username"
  value       = var.postgres_user
  sensitive   = true
}

output "prometheus_service" {
  description = "Prometheus service"
  value       = module.monitoring.prometheus_service
}

output "grafana_service" {
  description = "Grafana service"
  value       = module.monitoring.grafana_service
}

output "monitoring_namespace" {
  description = "Monitoring namespace"
  value       = module.monitoring.namespace
}

output "grafana_admin_password_command" {
  description = "Command to get Grafana admin password"
  value       = module.monitoring.grafana_admin_password
  sensitive   = true
}
