variable "domain_name" {
  type = string
}

variable "zone_id" {
  type        = string
  description = "Route 53 zone that holds the validation records."
}
