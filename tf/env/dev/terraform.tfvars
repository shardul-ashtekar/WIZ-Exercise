aws_region = "us-east-1"
name_prefix = "shar-wiz"
vpc_cidr = "10.20.0.0/22"
public_subnets = ["10.20.1.0/27" , "10.20.1.32/27"]
private_subnets = ["10.20.2.0/27", "10.20.2.32/27"]
ec2_ami_id = "ami-0157af9aea2eef346"
default_instance_type = "t3a.medium"
cluster_name = "shar-wiz-eks"
eks_cluster_version = "1.32"
eks_node_ami = "ami-030f844a2277b4019"
node_group_config = {
  desired_size = 1
  max_size     = 2
  min_size     = 1
  instance_type= "t3a.medium"
}
key_name = "Shar-WIZ-KP"
db_backup_bucket = "shar-wiz-mongodb-backup"
common_tags = {
  Environment = "dev"
  Project     = "shar-wiz-app"
}
