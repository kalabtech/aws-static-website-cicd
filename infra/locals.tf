# locals.tf
locals {
  common_tags = {
    Project     = "StaticWebsiteInfra"
    Environment = "Dev"
    ManagedBy   = "Terraform"
    CostCenter  = "Portfolio"
  }
}
