terraform {
  required_version = "~> 1.7" # Ensures compatibility

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# AWS Provider configuration
provider "aws" {
  region = var.aws_region
}

provider "github" {
  owner = "kalabtech-cloud-engineering"
}
