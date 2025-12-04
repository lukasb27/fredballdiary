

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 6.0"
  providers = {
    aws = aws.aws_us-east-1
  }

  domain_name = var.r53_zone_name
  zone_id     = module.zones.id
}

module "api_acm" {
  source  = "terraform-aws-modules/acm/aws"
 
  domain_name = "api.fredball.co.uk"
  zone_id     = module.zones.id
}

module "api_acm_us_east_1" {
  source  = "terraform-aws-modules/acm/aws"
  providers = {
    aws = aws.aws_us-east-1
  }
  domain_name = "api.fredball.co.uk"
  zone_id     = module.zones.id
  validation_method = "DNS"
}
module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  aliases = ["fredball.co.uk"]

  comment             = "fredball.co.uk"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = false

  # When you enable additional metrics for a distribution, CloudFront sends up to 8 metrics to CloudWatch in the US East (N. Virginia) Region.
  # This rate is charged only once per month, per metric (up to 8 metrics per distribution).
  create_monitoring_subscription = false

  # create_origin_access_identity = false
  #   origin_access_identities = {
  #     (var.bucket_name) = "My awesome CloudFront can access"
  #   }
  default_root_object = "index.html"
  origin = {
    fredball = {
      domain_name = "fred-ball-website.s3.eu-west-2.amazonaws.com"
      origin_id   = "fredballS3Origin"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }

      custom_header = {
        "X-Forwarded-Scheme" = "https"
        "X-Frame-Options"     = "SAMEORIGIN"
      }
    }

    s3_one = {
      domain_name = "fred-ball-website.s3.eu-west-2.amazonaws.com"
    }
  }
  default_cache_behavior = {
    target_origin_id       = "fredballS3Origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }
  origin_group = {
    fredballS3OriginGroup = {
      failover_criteria = {
        status_codes = [403, 404, 500, 502]
      }
      member = [
        { origin_id = "fredballS3Origin" },
        { origin_id = "s3_one" }
      ]
    }
  }
  viewer_certificate = {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  #   geo_restriction = {
  #     restriction_type = "whitelist"
  #     locations        = ["NO", "UA", "US", "GB"]
  #   }

}
