output "iam_role_arn" {
  value       = aws_iam_role.app_irsa_role.arn
  description = "The ARN of the IAM role to be used in the K8s ServiceAccount annotation"
}