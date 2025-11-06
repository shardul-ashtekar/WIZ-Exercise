aws_region = "us-east-1"
name_prefix = "shar-wiz"
availability_zones = ["us-east-1a", "us-east-1b"]
vpc_cidr = "10.30.0.0/22"
public_subnets = ["10.30.0.0/24", "10.30.1.0/24"]
private_subnets = ["10.30.2.0/24", "10.30.3.0/24"]
ec2_ami_id = "ami-0157af9aea2eef346"
ec2_instance_type = "t3.medium"
cluster_name = "shar-wizapp-eks"
eks_cluster_version = "1.32"
node_group_config = {
  desired_size = 1
  max_size     = 2
  min_size     = 1
  instance_type= "t3.medium"
}
key_name = "Shar-WIZ-KP"
db_backup_bucket = "shar-wiz-mongodb-backup"
common_tags = {
  Environment = "dev"
  Project     = "shar-wiz-app"
}
