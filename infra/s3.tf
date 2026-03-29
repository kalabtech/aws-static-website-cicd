module "s3" {
  source      = "github.com/kalabtech/aws-terraform-modules//modules/s3?ref=s3-v1"
  bucket_name = var.bucket_name

  enable_versioning                  = true
  noncurrent_version_expiration_days = 7
}
