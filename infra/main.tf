## S3 - bucket
resource "aws_s3_bucket" "static-s3" {
  bucket = "kalabtech-static-website"

  tags = {
    Name        = "static-website"
    Environment = "Dev"
  }
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

# NOTE: Next Commit
# resource "aws_s3_bucket_policy" "static-policy" {
#   bucket = aws_s3_bucket.static-s3.id
# }

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