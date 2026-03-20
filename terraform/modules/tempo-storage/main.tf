# 1. Create the Dedicated S3 Bucket for Traces
resource "aws_s3_bucket" "tempo_storage" {
  bucket = "easyshop-tempo-traces-prod" # Change this to your unique bucket name

  tags = {
    Project     = "easyshop"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# 2. Add a Lifecycle Rule (Crucial for Cost Control)
# Senior Move: Automatically delete traces after 14 days so your bill doesn't explode
resource "aws_s3_bucket_lifecycle_configuration" "tempo_lifecycle" {
  bucket = aws_s3_bucket.tempo_storage.id

  rule {
    id     = "expire-old-traces"
    status = "Enabled"

    expiration {
      days = 14
    }
  }
}

# 3. Create IAM Policy for Tempo to access the Bucket
resource "aws_iam_policy" "tempo_s3_access" {
  name        = "TempoS3AccessPolicy"
  description = "Allows Tempo pods to manage traces in S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.tempo_storage.arn}",
          "${aws_s3_bucket.tempo_storage.arn}/*"
        ]
      }
    ]
  })
}

# 4. Create the IAM Role for the Service Account (IRSA)
# This uses the OIDC provider from your EKS cluster
module "tempo_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "tempo-s3-irsa-role"

  oidc_providers = {
    main = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["tracing:tempo-sa"] # Namespace:ServiceAccount
    }
  }

  role_policy_arns = {
    policy = aws_iam_policy.tempo_s3_access.arn
  }
}

