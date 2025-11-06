module "eks" {
  depends_on = [ module.vpc, module.iam ]
  source          = "./modules/eks"
  cluster_name    = var.cluster_name
  eks_cluster_version = var.eks_cluster_version
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  key_name        = var.key_name
  mongo_sg_id     = module.ec2.mongo_sg_id
  eks_role_arn    = module.iam.eks_role_arn
  node_role_arn = module.iam.node_role_arn
  node_group_config = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
    instance_type= "t3a.medium"
  }
  tags            = var.common_tags
}