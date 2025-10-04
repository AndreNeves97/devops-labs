# Configure the values and rename to variables.tf

variable "auth" {
  type = object({
    region          = string
    assume_role_arn = string
  })

  default = {
    region          = "us-east-1"
    assume_role_arn = "arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>" # Replace with your own IAM role ARN which terraform will use
  }
}

variable "github_oidc_auth" {
  type = object({
    sub = string
  })

  default = {
    sub = "repo:<GITHUB_USERNAME>/<REPO_NAME>:*" # Replace with your own GitHub repository name and username.
    # Pipelines in this repository will be authorized to access the ECR repositories.
  }
}

variable "tags" {
  type = map(string)
  default = {
    Project     = "<PROJECT_NAME>" # Replace with your own project name
    Environment = "dev"
  }
}

variable "remote_backend" {
  type = object({
    bucket_name = string
  })

  default = {
    bucket_name = "terraform-remote-backend-bucket-<ACCOUNT_ID>" # Replace with your own S3 bucket name
  }
}

variable "vpc" {
  type = object({
    cidr_block            = string
    subnets_cidr_block    = string
    name                  = string
    internet_gateway_name = string
    nat_gateway_name      = string
    public_subnets = list(object({
      cidr_block        = string
      availability_zone = string
    }))

    private_subnets = list(object({
      cidr_block        = string
      availability_zone = string
    }))
  })

  default = {
    cidr_block            = "10.0.0.0/24"
    subnets_cidr_block    = "10.0.0.0/26"
    name                  = "main-vpc"
    internet_gateway_name = "main-vpc-igw"
    nat_gateway_name      = "main-vpc-nat-gw"
    public_subnets = [
      {
        cidr_block        = "10.0.0.0/26"
        availability_zone = "us-east-1a"
      },
      {
        cidr_block        = "10.0.0.64/26"
        availability_zone = "us-east-1b"
      }
    ]
    private_subnets = [
      {
        cidr_block        = "10.0.0.128/26"
        availability_zone = "us-east-1a"
      },
      {
        cidr_block        = "10.0.0.192/26"
        availability_zone = "us-east-1b"
      },
    ]
  }
}


variable "eks_cluster" {
  type = object({
    name = string
    node_group_name = string
    version = string
    enabled_cluster_log_types = list(string)
    authentication_mode = string
    instance_types = list(string)
    capacity_type = string
    desired_size = number
    max_size = number
    min_size = number
  })

  default = {
    name = "eks-cluster"
    node_group_name = "eks-cluster-node-group"
    version = "1.31"
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    authentication_mode = "API_AND_CONFIG_MAP"
    instance_types = ["t3.medium"]
    capacity_type = "ON_DEMAND"
    desired_size = 2
    max_size = 2
    min_size = 2
  }
}

variable "ecr_repositories" {
  type = list(object({
    name = string
  }))

  default = [
    {
      name = "application/frontend"
    },
    {
      name = "application/backend"
    }
  ]
}