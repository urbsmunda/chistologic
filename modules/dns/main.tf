### main.tf ###

terraform {
  required_version = ">= 1.5"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.90"
    }
  }
}

locals {
  zone_name   = lower(var.domain)
  description = "${var.project != null ? var.project : "project"}-${var.environment}-dns"
}

resource "yandex_dns_zone" "this" {
  folder_id   = var.folder_id
  name        = replace(local.zone_name, "\\.", "-")
  zone        = "${local.zone_name}."
  description = local.description
  public      = var.vpc_id == ""

  dynamic "vpc" {
    for_each = var.vpc_id != "" ? [var.vpc_id] : []
    content {
      network_id = vpc.value
    }
  }

  labels = {
    environment = var.environment
  }

  lifecycle {
    prevent_destroy = true
  }
}
