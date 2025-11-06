
############### AWS Variables ##################

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}


############### VPC Variables ##################

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}
variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}
variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}
variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}


############### EC2 Variables ##################

variable "ec2_ami_id" {
  description = "The AMI ID to use for the EC2 instances"
  type        = string
}
variable "key_name" {
  description = "The name of the key pair to use for EC2 instances"
  type        = string
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}
variable "ec2_instance_type" {
  description = "The default instance type for EC2 instances"
  type        = string
}
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
variable "db_backup_bucket" {
  description = "The S3 bucket name for database backups"
  type        = string
}


############### EKS Variables ##################

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}
variable "eks_cluster_version" {
  description = "The version of EKS to use"
  type        = string
}
variable "eks_node_ami" {
  description = "The AMI ID for the EKS worker nodes"
  type        = string
}
variable "node_group_config" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
    instance_type= string
  })
}