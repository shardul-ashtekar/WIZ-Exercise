output "eks_role_arn" { 
    value = aws_iam_role.eks_role.arn 
}
output "node_role_arn" { 
    value = aws_iam_role.node_role.arn 
}
output "ec2_profile_name" { 
    value = aws_iam_instance_profile.ec2_instance_profile.name 
}
