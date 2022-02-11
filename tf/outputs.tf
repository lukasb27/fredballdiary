output s3_bucket_website_domain {
  value       = module.s3_bucket
  description = "Website domain for the s3 bucket website"
  depends_on  = [module.s3_bucket]
}

output s3_bucket_website_endpoint {
  value       = module.s3_bucket
  description = "Website endpoint for the s3 bucket website"
  depends_on  = [module.s3_bucket]
}