terraform {
  backend "s3" {
    bucket  = "fred-ball-tf-state"
    key     = "website-infra.tfstate"
    region  = "eu-west-2"
  }
}