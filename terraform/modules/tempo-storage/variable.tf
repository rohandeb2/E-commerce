variable "bucket_name" {
  description = "The name of the S3 bucket for Tempo traces"
  type        = string
  default     = "easyshop-tempo-traces-prod"
}

variable "eks_oidc_provider_arn" {
  description = "The ARN of the EKS OIDC provider for IRSA"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. prod, staging)"
  type        = string
  default     = "production"
}