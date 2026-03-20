output "docdb_endpoint" {
  value = aws_docdb_cluster.this.endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.assets.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.assets.arn
}

output "kms_key_arn" {
  value = aws_kms_key.data.arn
}