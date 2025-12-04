variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
}

variable "website_files_path" {
  type        = string
  description = "the path for folder that the website files are stored in"
}

variable "r53_zone_name" {
  type        = string
  description = "the zone name for public route53 zone"
}

variable "website_files_path_images" {
  type        = string
  description = "the path for folder that the website images are stored in"
}