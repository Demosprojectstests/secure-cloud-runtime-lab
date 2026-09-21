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

variable "github_org" {
  type        = string
  description = "GitHub org or user for OIDC trust"
  default     = "YOUR_GITHUB_USER"
}

variable "github_repo" {
  type    = string
  default = "secure-cloud-runtime-lab"
}
