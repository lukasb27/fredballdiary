terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "eu-west-2"
  profile = "fredball"
}

provider "aws" {
  alias   = "aws_us-east-1"
  region  = "us-east-1"
  profile = "fredball"
}