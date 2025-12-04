data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}/*",
    ]
  }
}


module "s3_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json
  bucket        = var.bucket_name
  acl           = "private"
  website = {
    index_document = "index.html"
    error_document = "error.html"
    routing_rules = [
      {
        condition = {
          key_prefix_equals = "docs/"
        }
        redirect = {
          replace_key_prefix_with = "documents/"
        }
      }
    ]
  }

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

