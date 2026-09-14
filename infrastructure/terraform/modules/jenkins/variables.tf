variable "project_name" {
  description = "Project name used for Jenkins resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Jenkins will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Jenkins Controller and Agent"
  type        = list(string)
}

variable "controller_instance_type" {
  description = "EC2 instance type for Jenkins Controller"
  type        = string
  default     = "t3.medium"
}

variable "agent_instance_type" {
  description = "EC2 instance type for Jenkins Agent"
  type        = string
  default     = "t3.medium"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository Jenkins Agent is allowed to access"
  type        = string
}
variable "jenkins_ami_id" {
  description = "Pinned Amazon Linux 2023 AMI ID for Jenkins Controller and Agent"
  type        = string
}