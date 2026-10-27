variable "name" {
  type        = string
  description = "Name of the origin access control."
}

variable "domain_name" {
  type = string
}

variable "zone_id" {
  type        = string
  description = "Route 53 zone that holds the A and AAAA records."
}

variable "certificate_arn" {
  type        = string
  description = "Validated ACM certificate in us-east-1."
}

variable "bucket_id" {
  type = string
}

variable "bucket_arn" {
  type = string
}

variable "bucket_regional_domain_name" {
  type = string
}
