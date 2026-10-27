# Looks up the existing public zone for the custom domain.
# Exists so the certificate validation and alias records know which zone to go in.
data "aws_route53_zone" "this" {
  name = var.hosted_zone_name
}

module "bucket" {
  source = "./modules/bucket"

  bucket_name = var.bucket_name
}

module "certificate" {
  source = "./modules/certificate"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.this.zone_id
}

module "cdn" {
  source = "./modules/cdn"

  name                        = var.bucket_name
  domain_name                 = var.domain_name
  zone_id                     = data.aws_route53_zone.this.zone_id
  certificate_arn             = module.certificate.certificate_arn
  bucket_id                   = module.bucket.id
  bucket_arn                  = module.bucket.arn
  bucket_regional_domain_name = module.bucket.bucket_regional_domain_name
}
