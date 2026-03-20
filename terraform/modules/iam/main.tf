# 1. Get the TLS Certificate for the EKS OIDC Issuer
data "aws_partition" "current" {}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.oidc_thumbprint]
  url             = var.oidc_url
}

# 2. IAM Role for the Application Pods (The "Identity")
resource "aws_iam_role" "app_irsa_role" {
  name = "${var.project_name}-app-irsa-role"

  # Trust Policy: Only allows the specific K8s Service Account to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_url, "https://", "")}:sub": "system:serviceaccount:${var.namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })
}

# 3. IAM Policy (The "Permissions")
resource "aws_iam_policy" "app_policy" {
  name        = "${var.project_name}-app-permissions"
  description = "Permissions for EasyShop App to access S3 and SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
        Resource = [var.s3_bucket_arn, "${var.s3_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = var.sns_topic_arn
      }
    ]
  })
}

# 4. Attach Policy to Role
resource "aws_iam_role_policy_attachment" "app_attach" {
  role       = aws_iam_role.app_irsa_role.name
  policy_arn = aws_iam_policy.app_policy.arn
}