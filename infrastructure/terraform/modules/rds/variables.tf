variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "etrm"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "etrmuser"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}
variable "eks_security_group_id" {
  description = "Security group allowed to connect to RDS PostgreSQL"
  type        = string
}