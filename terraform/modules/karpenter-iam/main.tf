# 1. The Interruption Queue (SQS)
# This allows Karpenter to handle Spot interruptions, Rebalance recommendations, and Health events.
resource "aws_sqs_queue" "karpenter_interruption" {
  name                      = "KarpenterInterruptionQueue"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true # Production Standard: Encryption at rest
}

# 2. IAM Role for the Nodes (EC2 Instances)
# These are the "Worker" roles that Karpenter-launched nodes will assume.
module "karpenter_node_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  create_role           = true
  role_name             = "KarpenterNodeRole"
  role_requires_mfa     = false
  trusted_role_services = ["ec2.amazonaws.com"]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" # Essential for debugging nodes
  ]
}

# 3. IAM Role for the Controller (The Pod)
# This uses IRSA (IAM Roles for Service Accounts) to allow the Karpenter pod to talk to EC2.
module "karpenter_controller_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "KarpenterControllerRole"

  oidc_providers = {
    main = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"] # Restricted to the Karpenter namespace
    }
  }

  role_policy_arns = {
    # We define a custom policy below with minimum required permissions
    policy = aws_iam_policy.karpenter_controller.arn
  }
}

# 4. Scoped Policy for the Controller (Least Privilege)
resource "aws_iam_policy" "karpenter_controller" {
  name        = "KarpenterControllerPolicy"
  description = "Minimum permissions for Karpenter to manage EC2 fleet"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateRemoteAccessSession",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "ec2:TerminateInstances"
        Effect   = "Allow"
        Resource = "*" # Senior Tip: You can further scope this with tags if needed
      },
      {
        Action   = "iam:PassRole"
        Effect   = "Allow"
        Resource = module.karpenter_node_role.iam_role_arn
      },
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.karpenter_interruption.arn
      }
    ]
  })
}