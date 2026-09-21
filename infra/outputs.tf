output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "github_actions_role_arn" {
  value = module.iam.github_actions_role_arn
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}
