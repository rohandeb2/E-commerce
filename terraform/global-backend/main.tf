provider "aws" {
  region = var.aws_region
}

# 1. S3 Bucket for Remote State
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name
  
  # 12 LPA Best Practice: Prevent accidental deletion of the state
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = var.state_bucket_name
    Project     = var.project_name
    Environment = "global"
  }
}

# Enable Versioning (Crucial for state recovery)
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enforce Encryption (Security Requirement)
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 2. DynamoDB for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.dynamodb_table_name
    Project     = var.project_name
    Environment = "global"
  }
}