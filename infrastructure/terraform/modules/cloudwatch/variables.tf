variable "project_name" {
  description = "Project name used for CloudWatch IAM role naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
variable "cluster_name" {
  description = "EKS cluster name used for the CloudWatch Observability Pod Identity association"
  type        = string
}
variable "alarm_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
}