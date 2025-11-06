module "ec2" {
  depends_on = [ module.vpc, module.iam ]
  source               = "./modules/ec2"
  vpc_id               = module.vpc.vpc_id
  public_subnet_id     = module.vpc.public_subnets[0]
  key_name             = var.key_name
  kube_cidr            = var.vpc_cidr
  iam_instance_profile = module.iam.ec2_profile_name
  ami_id               = var.outdated_ami_id
  instance_type        = var.default_instance_type
  tags                 = var.common_tags
  backup_bucket        = var.db_backup_bucket
}