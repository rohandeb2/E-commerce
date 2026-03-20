variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "project_name" {
  type        = string
  description = "Project name for tagging"
}
variable "domain_name" {
  description = "The top-level domain for the project (e.g., rohandevops.co.in)"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "The regional domain name of the S3 bucket for assets"
  type        = string
}