variable "project_name" {
  type = string
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging or prod."
  }
  default = "prod"
}

variable "aws_region" {
  description = "AWS Region for provider"
  type        = string
}

variable "bucket_name" {
  description = "Static website s3 bucket name"
  type        = string
}

variable "price_class" {
  type        = string
  description = "Cloudfront distribution price class"
  default     = "PriceClass_100"
}
