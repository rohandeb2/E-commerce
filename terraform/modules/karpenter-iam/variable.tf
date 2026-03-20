variable "eks_oidc_provider_arn" {
  description = "The ARN of the EKS OIDC provider for IRSA"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "easyshop-eks-prod"
}

variable "environment" {
  description = "Deployment environment (e.g., prod, staging)"
  type        = string
  default     = "prod"
}