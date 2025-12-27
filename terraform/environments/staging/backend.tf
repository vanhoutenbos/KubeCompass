# Staging Environment - Backend Configuration

terraform {
  backend "s3" {
    endpoint = "https://ams3.digitaloceanspaces.com"
    region   = "us-east-1"
    
    bucket = "webshop-terraform-state"
    key    = "staging/terraform.tfstate"
    
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    
    encrypt = true
  }
}
