variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "db_cluster_id" {
  type = string
}

variable "log_retention_days" {
  type    = number
  default = 30
}