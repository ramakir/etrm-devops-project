variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "oidc_issuer_url" {
  description = "EKS OIDC issuer URL"
  type        = string
}

variable "rds_resource_id" {
  description = "RDS resource ID used for IAM database authentication"
  type        = string
}

variable "db_username" {
  description = "Database username allowed to connect using IAM authentication"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}