output "oidc_provider_arn" {
  description = "ARN of the EKS IAM OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "trade_service_role_arn" {
  description = "IAM role ARN used by the Trade Service Kubernetes service account"
  value       = aws_iam_role.trade_service.arn
}

output "trade_service_role_name" {
  description = "IAM role name used by the Trade Service"
  value       = aws_iam_role.trade_service.name
}