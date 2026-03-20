# 1. KMS Key for Data Encryption (The 12 LPA Security Touch)
resource "aws_kms_key" "data" {
  description             = "KMS key for DocumentDB and S3 encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true # Best practice for compliance

  tags = { Name = "${var.project_name}-data-kms" }
}

# 2. S3 Bucket for Product Assets
resource "aws_s3_bucket" "assets" {
  bucket        = "${var.project_name}-assets-${var.environment}"
  force_destroy = var.environment == "prod" ? false : true

  tags = { Name = "${var.project_name}-assets" }
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.data.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# 3. DocumentDB Subnet Group
resource "aws_docdb_subnet_group" "this" {
  name       = "${var.project_name}-docdb-subnet-group"
  subnet_ids = var.db_subnet_ids
}

# 4. DocumentDB Cluster (MongoDB Compatible)
resource "aws_docdb_cluster" "this" {
  cluster_identifier      = "${var.project_name}-cluster"
  engine                  = "docdb"
  master_username         = var.db_username
  master_password         = var.db_password # Provided via Secrets Manager/tfvars
  db_subnet_group_name    = aws_docdb_subnet_group.this.name
  vpc_security_group_ids  = [var.db_security_group_id]
  
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.data.arn
  
  backup_retention_period = 7
  preferred_backup_window = "02:00-04:00"
  skip_final_snapshot     = var.environment == "prod" ? false : true
  deletion_protection     = var.environment == "prod" ? true : false

  enabled_cloudwatch_logs_exports = ["audit", "profiler"]
}

# 5. DocumentDB Cluster Instance
resource "aws_docdb_cluster_instance" "this" {
  count              = var.environment == "prod" ? 2 : 1 # High Availability in Prod
  identifier         = "${var.project_name}-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.db_instance_class
}

# S3 Lifecycle Configuration for Cost Optimization
resource "aws_s3_bucket_lifecycle_configuration" "assets_lifecycle" {
  bucket = aws_s3_bucket.assets.id

  rule {
    id     = "archive-and-cleanup"
    status = "Enabled"

    # 1. Transition to Infrequent Access after 30 days
    # (30% cheaper for data that isn't accessed daily)
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # 2. Archive to Glacier after 90 days
    # (80% cheaper for long-term audit/compliance data)
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # 3. Clean up old versions of files to save space
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}