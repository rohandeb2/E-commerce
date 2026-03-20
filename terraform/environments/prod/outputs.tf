output "vpc_id" {
  value = module.networking.vpc_id
}

output "eks_cluster_name" {
  value = module.compute.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.compute.cluster_endpoint
}

output "ecr_repository_url" {
  value = module.compute.ecr_repository_url
}

output "docdb_endpoint" {
  value = module.data.docdb_endpoint
}

output "s3_bucket_name" {
  value = module.data.s3_bucket_name
}

output "waf_acl_arn" {
  value = module.security.waf_acl_arn
}
output "tempo_sa_role_to_copy" {
  value = module.tempo_storage.tempo_iam_role_arn
}

output "FINAL_KARPENTER_IRSA_ARN" {
  value = module.karpenter_infrastructure.karpenter_controller_role_arn
}