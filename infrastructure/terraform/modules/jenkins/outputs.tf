output "jenkins_agent_role_arn" {
  description = "ARN of the Jenkins agent IAM role"
  value       = aws_iam_role.jenkins_agent.arn
}