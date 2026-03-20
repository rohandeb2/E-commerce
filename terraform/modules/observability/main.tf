# 1. CloudWatch Log Group for Application Logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/eks/${var.project_name}/applications"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-app-logs"
  }
}

# 2. AWS X-Ray Sampling Rule (The 12 LPA Debugging Touch)
# This tells AWS how much traffic to trace. 
resource "aws_xray_sampling_rule" "main" {
  rule_name      = "${var.project_name}-sampling-rule"
  priority       = 1000
  version        = 1
  reservoir_size = 1
  fixed_rate     = 0.05 # Trace 5% of all requests to save cost
  host           = "*"
  http_method    = "*"
  url_path       = "*"
  resource_arn   = "*"
  service_name   = "*"
  service_type   = "*"

  attributes = {
    Environment = var.environment
  }
}

# 3. CloudWatch Dashboard (Business Value for the Interview)
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/DocDB", "CPUUtilization", "DBClusterIdentifier", "${var.db_cluster_id}" ]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "DocumentDB CPU Utilization"
        }
      }
    ]
  })
}