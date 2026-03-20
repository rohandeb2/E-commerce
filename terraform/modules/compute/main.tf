# 1. Private ECR Repository (Where your Next.js images live)
resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # 12 LPA Best Practice: Security Scanning
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project_name}-ecr"
  }
}

# 2. ECR Lifecycle Policy (Cost Optimization: Keep only last 10 images)
resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# 3. EKS Cluster (Using the official module for production stability)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = "1.31"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # 12 LPA Secret: IRSA (IAM Roles for Service Accounts)
  enable_irsa = true

  # Cluster Endpoint Access
  cluster_endpoint_public_access = true # Allows you to run kubectl from home

  # Managed Node Groups (The Workers)
  eks_managed_node_groups = {
    general = {
      name = "worker-nodes"

      instance_types = ["t3.medium"]
      capacity_type  = var.environment == "prod" ? "ON_DEMAND" : "SPOT"

      min_size     = 2
      max_size     = 5
      desired_size = 2
      labels = {
        intent = "control-plane"
      }
      # Required for Cluster Autoscaler
      tags = {
        "k8s.io/cluster-autoscaler/enabled"               = "true"
        "k8s.io/cluster-autoscaler/${var.project_name}" = "owned"
        "karpenter.sh/discovery" = "${var.project_name}-eks"
      }
    }
  }

  # Essential Add-ons
  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
    aws-ebs-csi-driver = { most_recent = true }
  }
}