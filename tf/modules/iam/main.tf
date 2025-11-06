
########### IAM roles/policies for EKS cluster and node group ##########

data "aws_iam_policy_document" "eks_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_role" {
  name               = "${var.tags.Project}-eks-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume.json
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_attach" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Node group role
data "aws_iam_policy_document" "node_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "node_role" {
  name               = "${var.tags.Project}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_attach_ec2" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_attach_cni" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_attach_ecr" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.tags.Project}-ec2-profile"
  role = aws_iam_role.node_role.name
}


########## EC2 instance profile for mongo VM ##########

resource "aws_iam_role" "ec2_role" {
  name = "${var.tags.Project}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
  tags = var.tags
}

resource "aws_iam_role_policy" "ec2_full" {
  name = "${var.tags.Project}-ec2-full-policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "*"
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.tags.Project}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}


########### GitHub Actions OIDC Trust Policy ##########

data "aws_iam_policy_document" "github_oidc_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::337909747602:oidc-provider/token.actions.githubusercontent.com"]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:odl_user_1942432/shar-wiz-app:ref:refs/heads/main"]
    }
  }
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name               = "${var.tags.Project}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume_role.json
  tags               = var.tags
}

# Attach ECR and EKS policies
resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "github_actions_eks" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}