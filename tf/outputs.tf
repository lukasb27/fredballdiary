output "s3_bucket_website_domain" {
  value       = module.s3_bucket.s3_bucket_website_domain
  description = "Website domain for the s3 bucket website"
  depends_on  = [module.s3_bucket]
}

output "s3_bucket_website_endpoint" {
  value       = module.s3_bucket.s3_bucket_website_endpoint
  description = "Website endpoint for the s3 bucket website"
  depends_on  = [module.s3_bucket]
}

output "route53_zone_id" {
  value       = lookup(module.zones.route53_zone_zone_id, "fredball.co.uk")
  description = "Route53 Zone ID"
  depends_on  = [module.zones]
}