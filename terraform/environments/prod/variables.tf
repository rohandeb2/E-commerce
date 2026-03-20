variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "easyshop"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# 12 LPA Secret: Sensitive variables don't show up in logs
variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

# Add this to variables.tf if not already there
variable "domain_name" {
  type        = string
  description = "The domain name for the e-commerce platform"
}