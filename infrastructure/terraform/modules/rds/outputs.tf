output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "RDS database name"
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "RDS database username"
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "db_resource_id" {
  description = "RDS resource ID used for IAM database authentication"
  value       = aws_db_instance.this.resource_id
}

output "db_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}