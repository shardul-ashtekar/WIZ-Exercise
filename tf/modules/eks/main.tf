########################################
# EKS Cluster

resource "aws_eks_cluster" "wiz-eks" {
  name     = var.cluster_name
  role_arn = var.eks_role_arn
  version  = var.eks_cluster_version

  vpc_config {
    subnet_ids             = var.private_subnets
    endpoint_public_access = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-eks-cluster"
  })
}

########################################
# Security Group for Nodes

resource "aws_security_group" "shar-eks-node-sg" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow EKS API access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow worker nodes to communicate with each other (UDP)"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "Allow worker nodes to communicate with each other (TCP)"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description      = "Allow SSH access from Bastion/Admin EC2"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [var.mongo_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-eks-node-sg"
  })
}

########################################
# Allow Node SG to talk to Cluster SG

resource "aws_security_group_rule" "node_to_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.shar-eks-node-sg.id
  security_group_id        = aws_eks_cluster.wiz-eks.vpc_config[0].cluster_security_group_id
  depends_on               = [aws_eks_cluster.wiz-eks]
}

########################################
# Whitelist EC2 Instance IP to EKS Cluster SG

resource "aws_security_group_rule" "whitelist_ec2_to_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = [var.ec2_instance_cidr]
  security_group_id        = aws_eks_cluster.wiz-eks.vpc_config[0].cluster_security_group_id
  depends_on               = [aws_eks_cluster.wiz-eks]
}

########################################
# Fetch EKS Optimized AMI

data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${var.eks_cluster_version}/amazon-linux-2/recommended/image_id"
}

########################################
# Launch Template for Node Group

resource "aws_launch_template" "shar-eks-lt" {
  name_prefix   = "${var.cluster_name}-lt-"
  image_id      = data.aws_ssm_parameter.eks_ami.value
  instance_type = var.node_group_config.instance_type
  key_name      = var.key_name

  user_data = base64encode(<<-EOT
   #!/bin/bash
   /etc/eks/bootstrap.sh ${aws_eks_cluster.wiz-eks.name}
  EOT
  )

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.shar-eks-node-sg.id]
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = "${var.cluster_name}-eks-node"
    })
  }

}

########################################
# EKS Node Group

resource "aws_eks_node_group" "wiz-eks-ng" {
  depends_on       = [aws_launch_template.shar-eks-lt]
  cluster_name     = aws_eks_cluster.wiz-eks.name
  node_group_name  = "${var.cluster_name}-ng"
  node_role_arn    = var.node_role_arn
  subnet_ids       = var.private_subnets

  scaling_config {
    desired_size = var.node_group_config.desired_size
    max_size     = var.node_group_config.max_size
    min_size     = var.node_group_config.min_size
  }

  launch_template {
    id      = aws_launch_template.shar-eks-lt.id
    version = "$Latest"
  }

  capacity_type = "ON_DEMAND"

  tags = merge(var.tags, {
    Name = "${var.tags.Project}-eks-ng"
  })

}


########################################
# EKS ADD-ONS

resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = aws_eks_cluster.wiz-eks.name
  addon_name        = "vpc-cni"
  addon_version     = "v1.17.1-eksbuild.1"
  
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-vpc-cni-addon"
  })
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.wiz-eks.name
  addon_name        = "coredns"
  addon_version     = "v1.11.4-eksbuild.2"

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-coredns-addon"
  })
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.wiz-eks.name
  addon_name        = "kube-proxy"
  addon_version     = "v1.32.6-eksbuild.12"

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-kube-proxy-addon"
  })
}
