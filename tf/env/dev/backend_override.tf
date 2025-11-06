terraform {
  backend "s3" {
    bucket = "shar-wiz-tfstate"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}
