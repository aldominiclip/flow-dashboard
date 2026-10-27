locals {
  default_tags = {
    ManagedBy = "terraform-MNLOSMFlowDashboard"
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "MNL-SHARED"

  default_tags {
    tags = local.default_tags
  }
}

# CloudFront only accepts ACM certificates from us-east-1.
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = "MNL-SHARED"

  default_tags {
    tags = local.default_tags
  }
}
