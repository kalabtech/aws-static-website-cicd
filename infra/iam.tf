# OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

# Assume Role Policy
data "aws_iam_policy_document" "oidc_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:kalabtech/aws-static-website-cicd:*"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# IAM Role
resource "aws_iam_role" "github_actions" {
  name               = "github-actions-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role.json
}

# Permissions Policy
data "aws_iam_policy_document" "github_actions_permissions" {
  statement {
    sid    = "S3ObjectPermissions"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.static-s3.arn}/*"
    ]
  }

  statement {
    sid    = "S3ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.static-s3.arn
    ]
  }

  statement {
    sid    = "CloudFrontInvalidation"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = [
      aws_cloudfront_distribution.static-distribution.arn
    ]
  }
}

# Attach Policy to Role
resource "aws_iam_role_policy" "github_actions" {
  name   = "github-actions-deploy-role"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_permissions.json
}
