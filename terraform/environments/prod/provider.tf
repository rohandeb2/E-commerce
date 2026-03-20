terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Pins to version 5.x, allowing only minor updates
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Industry Best Practice: Every resource gets these tags automatically
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "production"
      Owner       = "Rohan-DevOps"
      ManagedBy   = "Terraform"
    }
  }
}

# Required to talk to the EKS cluster after it's created
provider "kubernetes" {
  host                   = module.compute.cluster_endpoint
  cluster_ca_certificate = base64decode(module.compute.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.compute.cluster_name]
    command     = "aws"
  }
}