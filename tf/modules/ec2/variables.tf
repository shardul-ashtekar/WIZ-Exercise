variable "vpc_id" {
  type = string
}
variable "public_subnet_id" {
  type = string
}
variable "key_name" {
  type = string
}
variable "iam_instance_profile" {
  type = string
}
variable "ami_id" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "backup_bucket" {
  type = string
}
variable "kube_cidr" {
  description = "CIDR from which k8s cluster will access the DB (simplified)"
}
variable "tags" { 
  type = map(string) 
  default = {} 
}
