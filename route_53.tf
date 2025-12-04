module "zones" {
  source  = "terraform-aws-modules/route53/aws"
  version = "~> 6.0"
  name    = var.r53_zone_name
  comment = (var.r53_zone_name)
  # keep records empty here to avoid a circular dependency with CloudFront
  records = {}
  tags = {
    ManagedBy = "Terraform"
  }
}

# Create the CloudFront apex alias record separately so it depends on
# the already-created certificate/module and the CloudFront distribution
# without causing a dependency cycle between modules.
resource "aws_route53_record" "cloudfront_alias" {
  zone_id = module.zones.id
  name    = "" # apex record for the zone
  type    = "A"

  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }

  depends_on = [module.cloudfront]
}


