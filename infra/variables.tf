variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "secure-cloud-runtime-lab"
}

variable "environment" {
  type    = string
  default = "lab"
}

variable "vpc_cidr" {
  type    = string
  default = "10.42.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Pinned AZs so the set cannot silently grow"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "github_org" {
  type        = string
  description = "GitHub org or user for OIDC trust"
  default     = "Demosprojectstests"
}

variable "github_repo" {
  type    = string
  default = "secure-cloud-runtime-lab"
}
