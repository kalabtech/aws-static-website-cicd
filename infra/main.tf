## Policy Data
data "aws_iam_policy_document" "static-policy" {
  version = "2012-10-17"

  statement {
    sid    = "StaticWebsiteSecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.static-s3.arn,
      "${aws_s3_bucket.static-s3.arn}/*",
    ]
    condition {
      variable = "aws:SecureTransport"
      test     = "Bool"
      values   = ["false"]
    }
  }
}

## S3 - bucket
resource "aws_s3_bucket" "static-s3" {
  bucket = "kalabtech-static-website"

  tags = merge(
    local.common_tags,
    {
      Name = "static-website"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "static-block" {
  bucket = aws_s3_bucket.static-s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "static-versioning" {
  bucket = aws_s3_bucket.static-s3.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "static-policy" {
  bucket = aws_s3_bucket.static-s3.id
  policy = data.aws_iam_policy_document.static-policy.json
}

resource "aws_s3_bucket_ownership_controls" "static-ownership" {
  bucket = aws_s3_bucket.static-s3.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static-encrypt" {
  bucket = aws_s3_bucket.static-s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
