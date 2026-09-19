resource "aws_iam_role" "cloudwatch_observability" {
  name = "${var.project_name}-${var.environment}-cloudwatch-observability-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-cloudwatch-observability-role"
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role = aws_iam_role.cloudwatch_observability.name

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_eks_pod_identity_association" "cloudwatch_observability" {
  cluster_name    = var.cluster_name
  namespace       = "amazon-cloudwatch"
  service_account = "cloudwatch-agent"
  role_arn        = aws_iam_role.cloudwatch_observability.arn
}
resource "aws_sns_topic" "cloudwatch_alarms" {
  name = "${var.project_name}-${var.environment}-cloudwatch-alarms"

  tags = {
    Name        = "${var.project_name}-${var.environment}-cloudwatch-alarms"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_sns_topic_subscription" "alarm_email" {
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}
resource "aws_cloudwatch_metric_alarm" "trade_service_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-trade-service-cpu-high"
  alarm_description   = "Alarm when trade-service pod CPU utilization exceeds 70% for 10 minutes"
  namespace           = "ContainerInsights"
  metric_name         = "pod_cpu_utilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 70
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    ClusterName = var.cluster_name
    Namespace   = "etrm"
    PodName     = "trade-service"
  }

  alarm_actions = [
    aws_sns_topic.cloudwatch_alarms.arn
  ]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "${var.project_name}-${var.environment}-trade-service-cpu-high"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
resource "aws_cloudwatch_metric_alarm" "trade_service_memory_high" {
  alarm_name          = "${var.project_name}-${var.environment}-trade-service-memory-high"
  alarm_description   = "Alarm when trade-service pod memory utilization exceeds 80% for 10 minutes"
  namespace           = "ContainerInsights"
  metric_name         = "pod_memory_utilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    ClusterName = var.cluster_name
    Namespace   = "etrm"
    PodName     = "trade-service"
  }

  alarm_actions = [
    aws_sns_topic.cloudwatch_alarms.arn
  ]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "${var.project_name}-${var.environment}-trade-service-memory-high"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
resource "aws_cloudwatch_metric_alarm" "trade_service_alb_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-trade-service-alb-5xx"
  alarm_description   = "Alarm when the trade-service ALB records 5 or more ELB-generated 5xx responses within 5 minutes"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    LoadBalancer = "app/k8s-etrm-tradeser-caff546086/ac3d8ee77758832e"
  }

  alarm_actions = [
    aws_sns_topic.cloudwatch_alarms.arn
  ]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "${var.project_name}-${var.environment}-trade-service-alb-5xx"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
resource "aws_cloudwatch_metric_alarm" "trade_service_target_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-trade-service-target-5xx"
  alarm_description   = "Alarm when the trade-service ALB receives 5 or more HTTP 5xx responses from application targets within 5 minutes"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    LoadBalancer = "app/k8s-etrm-tradeser-caff546086/ac3d8ee77758832e"
  }

  alarm_actions = [
    aws_sns_topic.cloudwatch_alarms.arn
  ]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "${var.project_name}-${var.environment}-trade-service-target-5xx"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
resource "aws_cloudwatch_metric_alarm" "trade_service_latency_high" {
  alarm_name          = "${var.project_name}-${var.environment}-trade-service-latency-high"
  alarm_description   = "Alarm when the trade-service ALB target response time exceeds 2 seconds for 10 minutes"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 2
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    LoadBalancer = "app/k8s-etrm-tradeser-caff546086/ac3d8ee77758832e"
  }

  alarm_actions = [
    aws_sns_topic.cloudwatch_alarms.arn
  ]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "${var.project_name}-${var.environment}-trade-service-latency-high"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}