output "tempo_s3_bucket_id" {
  description = "The name/ID of the S3 bucket"
  value       = aws_s3_bucket.tempo_storage.id
}

output "tempo_iam_role_arn" {
  description = "The ARN of the IAM role for the Tempo ServiceAccount"
  value       = module.tempo_role.iam_role_arn
}