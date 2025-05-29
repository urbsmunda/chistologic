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
  resolved_bucket_name = var.bucket_name != "" ? var.bucket_name : "${var.project}-${var.environment}-bucket"
}

resource "yandex_storage_bucket" "this" {
  folder_id   = var.folder_id
  access_key  = null           # IAM policy controls access
  secret_key  = null
  bucket      = local.resolved_bucket_name
  acl         = "private"
  force_destroy = false        # safety – cannot be interpolated with var

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }

  # Lifecycle rule – optional cold storage / expiration
  lifecycle_rule {
    id                                     = var.lifecycle_policy.id
    enabled                                = var.lifecycle_policy.status == "Enabled"
    noncurrent_version_expiration_days     = var.lifecycle_policy.days
    abort_incomplete_multipart_upload_days = 7
  }

  tags = {
    project     = var.project
    environment = var.environment
  }

  lifecycle {
    prevent_destroy = true   # безусловно защищаем bucket
  }
}
