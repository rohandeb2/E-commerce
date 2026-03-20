terraform {
  backend "s3" {
    bucket         = "rohan-easyshop-tf-state-2026" # Replace with your unique bucket name
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "easyshop-terraform-lock-prod-2026"
  }
}