output "karpenter_controller_role_arn" {
  description = "The ARN of the IAM role for the Karpenter controller (Pod)"
  value       = module.karpenter_controller_role.iam_role_arn
}

output "karpenter_node_role_name" {
  description = "The NAME of the IAM role for the nodes launched by Karpenter"
  value       = module.karpenter_node_role.iam_role_name
}

output "interruption_queue_name" {
  description = "The name of the SQS queue for Spot interruptions"
  value       = aws_sqs_queue.karpenter_interruption.name
}