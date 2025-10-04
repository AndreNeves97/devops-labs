terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }

  backend "s3" {
    # Backend configuration is loaded from terraform.tfbackend file
    # Copy terraform.tfbackend.example to terraform.tfbackend and configure your values
    # This file is gitignored to prevent committing sensitive information
  }
}

provider "aws" {
  region = var.auth.region

  max_retries = 3
  retry_mode  = "adaptive"

  assume_role {
    role_arn     = var.auth.assume_role_arn
  }

  default_tags {
    tags = var.tags
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.id, "--role-arn", var.auth.assume_role_arn]
      command     = "aws"
    }
  }
}
