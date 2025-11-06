output "cluster_name" { 
    value = aws_eks_cluster.wiz-eks.name
}
output "cluster_endpoint" { 
    value = aws_eks_cluster.wiz-eks.endpoint
}
