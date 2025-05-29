###########################################################################
#  NOTE: значения по умолчанию не ссылаются на другие переменные – это    #
#  устраняет предыдущую ошибку Terraform validate.                         #
###########################################################################

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
  # Формируем имя SA через locals, а не default = "sa-${var.environment}..."
  sa_name = "sa-${var.project}-${var.environment}"
}

resource "yandex_iam_service_account" "workload" {
  folder_id   = var.folder_id
  name        = local.sa_name
  description = "Service Account for workloads in ${var.environment}"
  labels = {
    project     = var.project
    environment = var.environment
  }

  lifecycle {
    prevent_destroy = true
  }
}

# IAM bindings (least privilege)
resource "yandex_resourcemanager_folder_iam_member" "sa_roles" {
  for_each = var.sa_roles

  folder_id = var.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.workload.id}"
  role      = each.key
}
