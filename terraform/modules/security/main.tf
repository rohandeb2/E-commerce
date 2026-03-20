# 1. AWS Secrets Manager - DocumentDB Credentials
resource "aws_secretsmanager_secret" "db_creds" {
  name        = "easyshop/production/docdb" # Fixed path to match Helm values
  description = "DocumentDB connection details for EasyShop"
  recovery_window_in_days = 7 
}

resource "aws_secretsmanager_secret_version" "db_creds_val" {
  secret_id     = aws_secretsmanager_secret.db_creds.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = var.db_endpoint # Ensure this is the cluster endpoint
    dbname   = "easyshop"
  })
}

# 2. AWS Secrets Manager - Application Auth Secrets
resource "aws_secretsmanager_secret" "auth_secrets" {
  name        = "easyshop/production/auth" # Fixed path to match Helm values
  description = "NextAuth and JWT security keys"
  recovery_window_in_days = 7 
}

resource "aws_secretsmanager_secret_version" "auth_creds_val" {
  secret_id     = aws_secretsmanager_secret.auth_secrets.id
  secret_string = jsonencode({
    nextauth_secret = "HmaFjYZ2jbUK7Ef+wZrBiJei4ZNGBAJ5IdiOGAyQegw="
    jwt_secret      = "e5e425764a34a2117ec2028bd53d6f1388e7b90aeae9fa7735f2469ea3a6cc8c"
  })
}

# 3. IAM Policy for IRSA (The Bridge)
# This allows your EKS pods to fetch the values we just created
resource "aws_iam_policy" "eks_secrets_policy" {
  name        = "${var.project_name}-secrets-policy"
  description = "Allows EKS pods to read EasyShop secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = [
          aws_secretsmanager_secret.db_creds.arn,
          aws_secretsmanager_secret.auth_secrets.arn
        ]
      }
    ]
  })
}

# 4. Web Application Firewall (WAF) - Unchanged but linked
resource "aws_wafv2_web_acl" "main" {
  name        = "${var.project_name}-waf"
  description = "Protects E-commerce from SQLi and Bots"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "MainWAF"
    sampled_requests_enabled   = true
  }
}