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
  name_prefix = "${var.project}-${var.environment}-db"
}

resource "yandex_mdb_postgresql_cluster" "this" {
  name                = local.name_prefix
  environment         = var.environment == "prod" ? "PRODUCTION" : "PRESTABLE"
  network_id          = data.yandex_vpc_network.default.id
  version             = var.db_version

  resources {
    resource_preset_id = var.instance_type
    disk_type_id       = var.disk_type
    disk_size          = var.disk_size
  }

  deployment_mode = "MANUAL"

  host {
    zone      = "ru-central1-a"
    subnet_id = var.subnet_ids[0]
    assign_public_ip = false
    name = "${local.name_prefix}-a"
  }

  host {
    zone      = "ru-central1-b"
    subnet_id = var.subnet_ids[1]
    assign_public_ip = false
    name = "${local.name_prefix}-b"
  }

  maintenance_window {
    type = "ANYTIME"
  }

  dynamic "extension" {
    for_each = var.extensions
    content {
      name = extension.value
    }
  }

  backup_window_start {
    hours   = 23
    minutes = 30
  }

  backup_retention_period = "${var.backup_retention}d"

  lifecycle {
    prevent_destroy = true
  }
}

data "yandex_vpc_network" "default" {
  folder_id = var.folder_id
  name      = "default"
}

resource "yandex_mdb_postgresql_database" "db" {
  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = "app"
  owner      = "app"
  encoding   = "UTF8"
}

resource "yandex_mdb_postgresql_user" "app" {
  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = "app"
  password   = random_password.password.result
  permissions {
    database_name = yandex_mdb_postgresql_database.db.name
  }
}

resource "random_password" "password" {
  length  = 24
  special = true
}
