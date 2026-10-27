# Origin access control (OAC): makes CloudFront sign its requests to S3.
# Exists so the bucket policy can tell CloudFront apart from an anonymous caller.
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = var.name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Looks up the AWS-managed cache policy that turns caching off.
# Exists so every request goes to S3 and a new upload shows up right away, without an invalidation.
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

# Adds Cache-Control: no-store to every response.
# Exists so browsers do not cache the files either; S3 sends no Cache-Control of its own.
resource "aws_cloudfront_response_headers_policy" "no_cache" {
  name = "${var.name}-no-cache"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      value    = "no-store"
      override = true
    }
  }
}

# The CDN in front of the bucket.
# Exists to serve the site over HTTPS, cache it at edge locations and show error.html for missing pages.
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  aliases             = [var.domain_name]

  origin {
    origin_id                = "s3"
    domain_name              = var.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    target_origin_id           = "s3"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.no_cache.id
  }

  # S3 returns 403, not 404, for a missing key when CloudFront may not list the bucket.
  # error_caching_min_ttl is 10 seconds by default, so a 404 would stick even after the file is uploaded.
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/error.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/error.html"
    error_caching_min_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# Points the custom domain at the distribution, for IPv4 (A) and IPv6 (AAAA).
# Exists so browsers can find CloudFront by our own name.
resource "aws_route53_record" "site" {
  for_each = toset(["A", "AAAA"])

  zone_id = var.zone_id
  name    = var.domain_name
  type    = each.value

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

# Lets only this distribution read objects from the bucket.
# Exists because the bucket is private: without it, CloudFront gets 403 on every file.
resource "aws_s3_bucket_policy" "cloudfront_read" {
  bucket = var.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "CloudFrontReadGetObject"
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${var.bucket_arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
        }
      }
    }]
  })
}
