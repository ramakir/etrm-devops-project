variable "project_name" {
  description = "Project name used for ECR repository naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "repository_name" {
  description = "Existing ECR repository name used by the Trade Service"
  type        = string
}
