# Backend Configuration for Production TransIP Environment
# Remote state storage for team collaboration and disaster recovery

terraform {
  backend "s3" {
    # S3-compatible backend configuration
    # Can use: AWS S3, DigitalOcean Spaces, MinIO, or any S3-compatible storage
    
    bucket = "kubecompass-terraform-state"
    key    = "transip/production/terraform.tfstate"
    region = "eu-west-1"
    
    # For DigitalOcean Spaces (recommended for EU data residency):
    # endpoint = "https://ams3.digitaloceanspaces.com"
    # skip_credentials_validation = true
    # skip_metadata_api_check = true
    
    # State locking (prevent concurrent modifications)
    dynamodb_table = "terraform-state-lock"
    
    # Encryption at rest
    encrypt = true
    
    # Access control
    # Ensure IAM/API keys have minimal permissions:
    # - s3:GetObject
    # - s3:PutObject
    # - s3:DeleteObject (for state deletion - use carefully)
    # - dynamodb:PutItem
    # - dynamodb:GetItem
    # - dynamodb:DeleteItem
  }
}

# Alternative: Local backend for testing (NOT recommended for production)
# terraform {
#   backend "local" {
#     path = "terraform.tfstate"
#   }
# }

# Note: Backend configuration cannot use variables
# Set values via:
# 1. Backend config file: terraform init -backend-config=backend.hcl
# 2. Environment variables: TF_CLI_BACKEND_CONFIG_bucket=...
# 3. Interactive prompt during terraform init
