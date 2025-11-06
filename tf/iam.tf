module "iam" {
  source = "./modules/iam"
  tags   = var.common_tags
}