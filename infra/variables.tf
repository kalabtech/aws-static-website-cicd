variable "aws_region" {
  description = "AWS Region for privider"
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  type        = string
}
