terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # CloudFront only accepts ACM certificates from us-east-1.
      configuration_aliases = [aws.us_east_1]
    }
  }
}
