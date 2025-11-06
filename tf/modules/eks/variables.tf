variable "cluster_name" { 
  type = string 
}
variable "eks_cluster_version" {
  description = "EKS Cluster version"
  type        = string
}
variable "vpc_id" {
  type = string
}
variable "private_subnets" { 
  type = list(string) 
}
variable "eks_role_arn" { 
  type = string 
}
variable "node_role_arn" { 
  type = string 
}
variable "eks_node_ami" {
  description = "AMI ID for EKS worker nodes"
  type        = string
}
variable "key_name" {
  description = "EC2 Key pair for SSH"
  type        = string
}
variable "mongo_sg_id" {
  description = "Security Group ID for MongoDB access"
  type        = string
}
variable "node_group_config" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
    instance_type= string
  })
  default = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
    instance_type= "t3.small"
  }
}
variable "tags" { 
  type = map(string) 
  default = {} 
}
