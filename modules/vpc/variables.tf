### clone\modules\vpc\variables.tf ###

variable "folder_id" {
  description = "Yandex Cloud folder ID where the network will be created"
  type        = string
}

variable "project" {
  description = "Project slug used in resource names"
  type        = string
  default     = "chistologic"
}

variable "environment" {
  description = "Environment name (dev, stage, prod, etc.)"
  type        = string
  default     = "prod"
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets (one per availability zone)"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for private subnets (one per availability zone)"
  type        = list(string)
}

variable "db_subnets_cidr" {
  description = "List of CIDR blocks for dedicated DB subnets (one per availability zone)"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Create centralized NAT gateway for outbound Internet in private subnets"
  type        = bool
  default     = true
}

variable "enable_dns_zone" {
  description = "Create public DNS zone in Yandex Cloud DNS for the provided domain name"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Root domain name (e.g. chistologic.ru) — required if enable_dns_zone = true"
  type        = string
  default     = ""
}

###############################################################################
# locals                                                                      #
###############################################################################

locals {
  # Derive unique name prefix once
  name_prefix = "${var.project}-${var.environment}"

  # Zip subnets cidr list with zones; assume RU central1-{a,b,c} ordering
  # If length of CIDRs < 3 we just slice
  zones = ["ru-central1-a", "ru-central1-b", "ru-central1-c"]

  public_pairs  = zipmap(local.zones, slice(var.public_subnets_cidr, 0, length(local.zones)))
  private_pairs = zipmap(local.zones, slice(var.private_subnets_cidr, 0, length(local.zones)))
  db_pairs      = zipmap(local.zones, slice(var.db_subnets_cidr, 0, length(local.zones)))
}
