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

###############################################################################
# KMS key
###############################################################################

resource "yandex_kms_symmetric_key" "default" {
  name        = "${var.project}-${var.environment}-kms-key"
  description = "Root KMS key for disk, S3 and Lockbox encryption"
  rotation_period = "720h"   # 30 days
  folder_id   = var.folder_id
}

###############################################################################
# Security Groups (created only when vpc_id is supplied)
###############################################################################

resource "yandex_vpc_security_group" "public_lb" {
  count       = var.vpc_id == null ? 0 : 1
  name        = "${var.project}-${var.environment}-sg-public-lb"
  description = "Allow 80/443 from the Internet to ALB"
  network_id  = var.vpc_id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_nodes" {
  count       = var.vpc_id == null ? 0 : 1
  name        = "${var.project}-${var.environment}-sg-k8s"
  description = "Kubernetes nodes — allow internal traffic and outbound Internet"
  network_id  = var.vpc_id

  dynamic "ingress" {
    for_each = var.private_subnet_ids
    content {
      protocol       = "ANY"
      from_port      = 0
      to_port        = 65535
      subnet_id      = ingress.value
    }
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "postgresql" {
  count      = var.vpc_id == null ? 0 : 1
  name       = "${var.project}-${var.environment}-sg-postgres"
  description = "Allow Postgres traffic (5432) only from K8s private subnets"
  network_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.private_subnet_ids
    content {
      protocol       = "TCP"
      port           = 5432
      subnet_id      = ingress.value
    }
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

###############################################################################
# Optional WAF configuration (ALB HTTP router + virtual host)
###############################################################################

resource "yandex_alb_http_router" "main" {
  count      = var.enable_waf ? 1 : 0
  name       = "${var.project}-${var.environment}-http-router"
  folder_id  = var.folder_id
}

resource "yandex_alb_virtual_host" "waf" {
  count        = var.enable_waf ? 1 : 0
  name         = "vhost-waf"
  http_router_id = yandex_alb_http_router.main[0].id
  route {
    name = "default"
    http_route {
      http_match {
        path {
          exact = "/"
        }
      }
      http_route_action {
        redirect_action {
          replace_scheme = "https"
          replace_port   = 443
          replace_path   = "/"
        }
      }
    }
  }
  waf_settings {
    enable  = true
    preset  = var.waf_policy_ruleset
  }
}

###############################################################################
# tags output helper
###############################################################################

locals {
  common_tags = {
    environment = var.environment
    project     = var.project
    module      = "security"
  }
}
