### clone\modules\vpc\main.tf ###

terraform {
  required_version = ">= 1.5"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.90"
    }
  }
}

###############################################################################
# Network                                                                     #
###############################################################################

resource "yandex_vpc_network" "this" {
  name = "${local.name_prefix}-vpc"

  lifecycle {
    prevent_destroy = true
  }
}

###############################################################################
# Subnets                                                                     #
###############################################################################

resource "yandex_vpc_subnet" "public" {
  for_each          = local.public_pairs
  name              = "${local.name_prefix}-public-${each.key}"
  zone              = each.key
  network_id        = yandex_vpc_network.this.id
  v4_cidr_blocks    = [each.value]
  route_table_id    = null   # direct Internet access via public IP
  folder_id         = var.folder_id
  dhcp_options {
    domain_name_servers = ["8.8.8.8", "1.1.1.1"]
  }
}

resource "yandex_vpc_subnet" "private" {
  for_each          = local.private_pairs
  name              = "${local.name_prefix}-private-${each.key}"
  zone              = each.key
  network_id        = yandex_vpc_network.this.id
  v4_cidr_blocks    = [each.value]
  route_table_id    = var.enable_nat_gateway ? yandex_vpc_route_table.private[0].id : null
  folder_id         = var.folder_id
}

resource "yandex_vpc_subnet" "db" {
  for_each       = local.db_pairs
  name           = "${local.name_prefix}-db-${each.key}"
  zone           = each.key
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [each.value]
  route_table_id = var.enable_nat_gateway ? yandex_vpc_route_table.private[0].id : null
  folder_id      = var.folder_id
}

###############################################################################
# NAT Gateway & Route table                                                   #
###############################################################################

resource "yandex_vpc_gateway" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  name = "${local.name_prefix}-nat"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  count      = var.enable_nat_gateway ? 1 : 0
  network_id = yandex_vpc_network.this.id
  name       = "${local.name_prefix}-rt-private"

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat[0].id
  }
}

###############################################################################
# DNS Zone (optional)                                                         #
###############################################################################

resource "yandex_dns_zone" "public" {
  count = var.enable_dns_zone ? 1 : 0

  name        = var.domain_name
  zone        = "${var.domain_name}."
  public      = true
  description = "Public DNS zone for ${var.project}"
  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }
}
