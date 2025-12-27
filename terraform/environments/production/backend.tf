# Production Environment - Backend Configuration

# Remote state backend configuration
# Using S3-compatible backend (DigitalOcean Spaces, AWS S3, MinIO, etc.)

terraform {
  backend "s3" {
    # S3-compatible backend configuration
    endpoint = "https://ams3.digitaloceanspaces.com"  # Change to your provider
    region   = "us-east-1"  # Required but not used for DO Spaces
    
    # State file location
    bucket = "webshop-terraform-state"
    key    = "production/terraform.tfstate"
    
    # State locking (DynamoDB for AWS, or provider-specific)
    # dynamodb_table = "terraform-state-lock"
    
    # Disable AWS-specific features for DO Spaces
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    
    # Encryption
    encrypt = true
    
    # Access credentials (set via environment variables)
    # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
  }
}

# Alternative: Azure Blob Storage
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraform-state"
#     storage_account_name = "webshopterraformstate"
#     container_name       = "tfstate"
#     key                  = "production.terraform.tfstate"
#   }
# }

# Alternative: Google Cloud Storage
# terraform {
#   backend "gcs" {
#     bucket = "webshop-terraform-state"
#     prefix = "production"
#   }
# }
