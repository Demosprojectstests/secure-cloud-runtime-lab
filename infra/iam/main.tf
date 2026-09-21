data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "permission_boundary" {
  name        = "${var.project}-boundary"
  description = "Caps every lab role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyPrivilegeEscalation"
        Effect   = "Deny"
        Action   = [
          "iam:CreatePolicyVersion",
          "iam:SetDefaultPolicyVersion",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:CreateRole",
          "iam:PassRole"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:PrincipalArn" = [
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project}-gha"
            ]
          }
        }
      },
      {
        Sid      = "AllowNonAdmin"
        Effect   = "Allow"
        NotAction = [
          "account:*",
          "organizations:*"
        ]
        Resource = "*"
      }
    ]
  })
}

data "aws_iam_policy_document" "eks_cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name                 = "${var.project}-eks-cluster"
  assume_role_policy   = data.aws_iam_policy_document.eks_cluster_assume.json
  permissions_boundary = aws_iam_policy.permission_boundary.arn
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "eks_node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name                 = "${var.project}-eks-node"
  assume_role_policy   = data.aws_iam_policy_document.eks_node_assume.json
  permissions_boundary = aws_iam_policy.permission_boundary.arn
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_actions" {
  name                 = "${var.project}-gha"
  permissions_boundary = aws_iam_policy.permission_boundary.arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "github_actions" {
  name = "plan-limited"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadForPlan"
        Effect   = "Allow"
        Action   = [
          "ec2:Describe*",
          "eks:Describe*",
          "eks:List*",
          "iam:Get*",
          "iam:List*",
          "logs:Describe*",
          "logs:ListTagsLogGroup"
        ]
        Resource = "*"
      }
    ]
  })
}
