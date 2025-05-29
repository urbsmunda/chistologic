### variables.tf ###

variable "folder_id" {
  description = "Yandex Cloud Folder ID where the DNS zone will be created"
  type        = string
}

variable "domain" {
  description = "Root domain name to manage (e.g. example.com)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC network (for private DNS zone); if empty, the zone will be public"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Deployment environment tag (dev, stage, prod, …) used in resource names"
  type        = string
  default     = "prod"
}

variable "ttl" {
  description = "Default TTL for DNS records (seconds)"
  type        = number
  default     = 300
}
