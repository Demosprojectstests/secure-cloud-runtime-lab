output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node.arn
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "permission_boundary_arn" {
  value = aws_iam_policy.permission_boundary.arn
}
