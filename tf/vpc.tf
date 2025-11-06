module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  azs = var.availability_zones
  private_subnets = var.private_subnets
  tags            = var.common_tags
  name_prefix     = var.name_prefix
}