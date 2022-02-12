module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = {
    (var.r53_zone_name) = {
      comment = (var.r53_zone_name)
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}