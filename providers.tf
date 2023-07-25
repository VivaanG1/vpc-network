terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
  }
}