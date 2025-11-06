resource "aws_eks_cluster" "wiz-eks" {
  name     = var.cluster_name
  role_arn = var.eks_role_arn
  version = var.eks_cluster_version

  vpc_config {
    subnet_ids = var.private_subnets
  }
}

resource "aws_security_group" "shar-eks-nodes-sg" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow EKS access"
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
    description = "Allow SSH access from Bastion/Admin EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [var.mongo_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-eks-nodes-sg"
  })
}

resource "aws_launch_template" "shar-eks-lt" {
  name_prefix   = "${var.cluster_name}-lt-"
  image_id      = var.eks_node_ami
  instance_type = var.node_group_config.instance_type
  key_name = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups  = [aws_security_group.shar-eks-nodes-sg.id]
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

resource "aws_eks_node_group" "wiz-eks-ng" {
  depends_on = [ aws_launch_template.shar-eks-lt ]
  cluster_name    = aws_eks_cluster.wiz-eks.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnets

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

