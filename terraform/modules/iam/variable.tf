variable "project_name" {
  type = string
}

variable "oidc_url" {
  type = string
}

variable "oidc_thumbprint" {
  type    = string
  default = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280" # Standard AWS Thumbprint
}

variable "namespace" {
  type    = string
  default = "production"
}

variable "service_account_name" {
  type    = string
  default = "easyshop-sa"
}

variable "s3_bucket_arn" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}