# Default backend - usually overridden per environment via env/<env>/backend_override.tf
terraform {
  backend "s3" {
    bucket         = "shar-wiz-tfstate"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
