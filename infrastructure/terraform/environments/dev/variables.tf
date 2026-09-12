variable "aws_region" {
  description = "AWS region where infrastructure will be deployed"
  type        = string
  default     = "ap-south-1"
}
variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}