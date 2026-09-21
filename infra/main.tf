module "vpc" {
  source      = "./vpc"
  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  azs         = var.azs
}

module "iam" {
  source      = "./iam"
  project     = var.project
  environment = var.environment
  github_org  = var.github_org
  github_repo = var.github_repo
}

module "eks" {
  source             = "./eks"
  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_role_arn   = module.iam.eks_cluster_role_arn
  node_role_arn      = module.iam.eks_node_role_arn
}
