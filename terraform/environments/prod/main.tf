# 1. Networking & Content Delivery
module "networking" {
  source                = "../../modules/networking"
  vpc_cidr              = var.vpc_cidr
  project_name          = var.project_name
  domain_name           = var.domain_name
  s3_bucket_domain_name = module.data.s3_bucket_domain_name
}

# 2. Security (WAF & Secrets)
module "security" {
  source       = "../../modules/security"
  vpc_id       = module.networking.vpc_id
  project_name = var.project_name
  environment  = "prod"
  db_username  = var.db_username
  db_password  = var.db_password
  db_endpoint  = module.data.docdb_endpoint
}

# 3. Compute (EKS & ECR)
module "compute" {
  source             = "../../modules/compute"
  project_name       = var.project_name
  environment        = "prod"
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
}

# 4. Data Layer (DocDB, S3 & Glacier)
module "data" {
  source               = "../../modules/data"
  project_name         = var.project_name
  environment          = "prod"
  db_subnet_ids        = module.networking.db_subnet_ids
  db_security_group_id = module.security.db_sg_id
  db_username          = var.db_username
  db_password          = var.db_password
}

# 5. Messaging (SNS & SQS)
module "messaging" {
  source       = "../../modules/messaging"
  project_name = var.project_name
  kms_key_arn  = module.data.kms_key_arn # Encrypting messages
}

# 6. IAM (IRSA)
module "iam" {
  source            = "../../modules/iam"
  project_name      = var.project_name
  oidc_provider_arn = module.compute.oidc_provider_arn
  oidc_provider_url = module.compute.cluster_endpoint
  s3_bucket_arn     = module.data.s3_bucket_arn
  namespace         = "production"
}

# 7. Observability
module "observability" {
  source        = "../../modules/observability"
  project_name  = var.project_name
  environment   = "prod"
  aws_region    = var.aws_region
  db_cluster_id = module.data.docdb_cluster_id
}

# 8. Tempo Storage (S3 Bucket + IAM Policy for Tempo)
module "tempo_storage" {
  source              = "../../modules/tempo-storage"
  bucket_name         = var.tempo_bucket_name
  # eks_oidc_provider_arn = module.iam.oidc_provider_arn
  # eks_oidc_provider_arn = module.eks.oidc_provider_arn
  eks.oidc_provider_url = module.compute.cluster_endpoint
  environment         = "prod"
}


module "karpenter_infrastructure" {
  source                = "./modules/karpenter-iam"
  
  # Link to your EKS module output
  eks_oidc_provider_arn = module.compute.oidc_provider_arn
  cluster_name          = var.project_name
  environment           = "prod"
  vpc_id       = module.networking.vpc_id
  subnet_ids   = module.networking.private_subnet_ids
}