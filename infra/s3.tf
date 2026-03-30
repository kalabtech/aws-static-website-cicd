module "s3" {
  source      = "github.com/kalabtech/aws-terraform-modules//modules/s3?ref=s3-v1"
  bucket_name = var.bucket_name

  enable_versioning                  = true
  enforce_ssl                        = false
  noncurrent_version_expiration_days = 7
}

# NOTE: Cloudfront bucket Policy
data "aws_iam_policy_document" "this" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      module.s3.bucket.arn,
      "${module.s3.bucket.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

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
