
############## VPC Module Outputs ##############

output "vpc_id"            { 
    value = module.vpc.vpc_id 
}
output "public_subnets"   { 
    value = module.vpc.public_subnets 
}
output "private_subnets"  { 
    value = module.vpc.private_subnets
}
output "igw_id"           { 
    value = module.vpc.igw_id
}

############## IAM Module Outputs ##############

output "eks_role_arn"     { 
    value = module.iam.eks_role_arn
}
output "node_role_arn"    { 
    value = module.iam.node_role_arn
}

############## EC2 Module Outputs ##############

output "ec2_public_ip"     { 
    value = module.ec2.public_ip 
}
output "ec2_instance_id"   { 
    value = module.ec2.instance_id 
}
output "mongo_sg_id"      { 
    value = module.ec2.mongo_sg_id 
}


############## EKS Module Outputs ##############

output "eks_cluster_name"  { 
    value = module.eks.cluster_name 
}
output "eks_cluster_endpoint"  { 
    value = module.eks.cluster_endpoint 
}


############## S3 Module Outputs ##############

output "s3_bucket_name"    { 
    value = module.s3.bucket_name 
}

