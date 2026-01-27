terraform {
  required_version = "~> 1.7" # Ensures compatibility
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider configuration
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
