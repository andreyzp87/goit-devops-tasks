output "endpoint" {
  description = "Database endpoint"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].endpoint
}

output "port" {
  description = "Database port"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].port : aws_db_instance.standard[0].port
}

output "database_name" {
  description = "Database name"
  value       = var.db_name
}

output "username" {
  description = "Database username"
  value       = var.username
  sensitive   = true
}
