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

resource "aws_s3_bucket_object" "index" {
  for_each = fileset(var.website_files_path, "*")

  bucket = var.bucket_name
  key    = each.value
  source = "${var.website_files_path}${each.value}"
  etag   = filemd5("${var.website_files_path}${each.value}")
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "images" {
  for_each = fileset(var.website_files_path_images, "*")

  bucket = var.bucket_name
  key    = "img/${each.value}"
  source = "${var.website_files_path_images}${each.value}"
  etag   = filemd5("${var.website_files_path_images}${each.value}")
  content_type = "image/png"
}

module "s3_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "2.14.1"
  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json
  bucket        = var.bucket_name
  acl           = "private"
  website = {
    index_document = "index.html"
    error_document = "error.html"
    routing_rules = jsonencode([{
      Condition : {
        KeyPrefixEquals : "docs/"
      },
      Redirect : {
        ReplaceKeyPrefixWith : "documents/"
      }
    }])
  }

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

