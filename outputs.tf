output "bucket_name" {
  value = module.bucket.id
}

output "distribution_id" {
  value = module.cdn.distribution_id
}

output "website_url" {
  value = "https://${var.domain_name}"
}
