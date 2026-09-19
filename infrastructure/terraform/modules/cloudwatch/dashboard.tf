resource "aws_cloudwatch_dashboard" "etrm" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "ALB Request Count"
          region = "ap-south-1"
          view   = "timeSeries"
          stat   = "Sum"
          period = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              "app/k8s-etrm-tradeser-caff546086/ac3d8ee77758832e"
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "ALB 5xx vs Target 5xx"
          region = "ap-south-1"
          view   = "timeSeries"
          stat   = "Sum"
          period = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_ELB_5XX_Count",
              "LoadBalancer",
              "app/k8s-etrm-tradeser-caff546086/ac3d8ee77758832e",
              {
                label = "ALB 5xx"
              }
            ],
            [
              ".",
              "HTTPCode_Target_5XX_Count",
              ".",
              ".",
              {
                label = "Target 5xx"
              }
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "Target 4xx Responses"
          region = "ap-south-1"
          view   = "timeSeries"
          stat   = "Sum"
          period = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_Target_4XX_Count",
              "LoadBalancer",
              "app/k8s-etrm-tradeser-caff546086/ac3d8ee77758832e"
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "Target Response Time"
          region = "ap-south-1"
          view   = "timeSeries"
          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              "app/k8s-etrm-tradeser-caff546086/ac3d8ee77758832e"
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          title  = "Trade Service CPU Utilization"
          region = "ap-south-1"
          view   = "timeSeries"
          stat   = "Average"
          period = 300

          metrics = [
            [
              "ContainerInsights",
              "pod_cpu_utilization",
              "ClusterName",
              "etrm-dev-eks",
              "Namespace",
              "etrm",
              "PodName",
              "trade-service"
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          title  = "Trade Service Memory Utilization"
          region = "ap-south-1"
          view   = "timeSeries"
          stat   = "Average"
          period = 300

          metrics = [
            [
              "ContainerInsights",
              "pod_memory_utilization",
              "ClusterName",
              "etrm-dev-eks",
              "Namespace",
              "etrm",
              "PodName",
              "trade-service"
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 24
        height = 6

        properties = {
          title  = "ETRM CloudWatch Alarms"
          region = "ap-south-1"
          view   = "timeSeries"
          period = 300

          metrics = [
            [
              "AWS/CloudWatch",
              "AlarmState",
              "AlarmName",
              "${var.project_name}-${var.environment}-trade-service-cpu-high"
            ],
            [
              ".",
              ".",
              ".",
              "${var.project_name}-${var.environment}-trade-service-memory-high"
            ],
            [
              ".",
              ".",
              ".",
              "${var.project_name}-${var.environment}-trade-service-alb-5xx"
            ],
            [
              ".",
              ".",
              ".",
              "${var.project_name}-${var.environment}-trade-service-target-5xx"
            ],
            [
              ".",
              ".",
              ".",
              "${var.project_name}-${var.environment}-trade-service-latency-high"
            ]
          ]
        }
      }
    ]
  })
}