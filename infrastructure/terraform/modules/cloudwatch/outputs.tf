output "cloudwatch_observability_role_arn" {
  description = "IAM role ARN used by the CloudWatch Observability EKS add-on"
  value       = aws_iam_role.cloudwatch_observability.arn
}
output "cloudwatch_alarm_topic_arn" {
  description = "SNS topic ARN used for CloudWatch alarm notifications"
  value       = aws_sns_topic.cloudwatch_alarms.arn
}