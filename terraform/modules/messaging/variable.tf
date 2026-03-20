variable "project_name" {
  type        = string
  description = "Project name for resource tagging"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN for encrypting messages"
}