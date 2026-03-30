module "s3" {
  source      = "github.com/kalabtech/aws-terraform-modules//modules/s3?ref=s3-v1"
  bucket_name = var.bucket_name

  enable_versioning                  = true
  noncurrent_version_expiration_days = 7
}

# NOTE: Cloudfront bucket Policy
data "aws_iam_policy_document" "this" {
  version = "2012-10-17"
  statement {
    sid    = "AllowCloudfrontServicePrincipal"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${module.s3.bucket.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = module.s3.bucket.id
  policy = data.aws_iam_policy_document.this.json
}
