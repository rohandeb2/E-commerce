variable "aws_region" {
  description = "The AWS region to deploy the backend resources"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "The name of the S3 bucket (MUST be globally unique)"
  type        = string
  default     = "rohan-easyshop-tf-state-2026" # Change this to a unique name
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for state locking"
  type        = string
  default     = "easyshop-terraform-lock-prod-2026"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "easyshop"
}