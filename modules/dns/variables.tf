variable "project" {
  description = "Project prefix for naming"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment tag (e.g. dev, prod)"
  type        = string
}

variable "domain" {
  description = "Root DNS zone, e.g. example.com"
  type        = string
}
