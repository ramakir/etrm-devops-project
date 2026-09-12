output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}

output "eks_cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  value       = module.iam.eks_cluster_role_arn
}

output "eks_cluster_role_name" {
  description = "EKS cluster IAM role name"
  value       = module.iam.eks_cluster_role_name
}

output "eks_node_role_arn" {
  description = "EKS node IAM role ARN"
  value       = module.iam.eks_node_role_arn
}

output "eks_node_role_name" {
  description = "EKS node IAM role name"
  value       = module.iam.eks_node_role_name
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.db_endpoint
}

output "db_port" {
  description = "RDS PostgreSQL port"
  value       = module.rds.db_port
}

output "db_name" {
  description = "RDS database name"
  value       = module.rds.db_name
}

output "db_security_group_id" {
  description = "RDS security group ID"
  value       = module.rds.db_security_group_id
}
output "db_resource_id" {
  description = "RDS resource ID used for IAM database authentication"
  value       = module.rds.db_resource_id
}
output "eks_cluster_oidc_issuer_url" {
  description = "EKS OIDC issuer URL used for IRSA"
  value       = module.eks.cluster_oidc_issuer_url
}