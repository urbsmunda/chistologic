### main.tf ###

terraform {
  required_version = ">= 1.5"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.90"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Providers (K8s + Helm) – получаем kube‑config автоматически через data source
# ─────────────────────────────────────────────────────────────────────────────

data "yandex_kubernetes_cluster" "this" {
  name      = var.k8s_cluster_name
  folder_id = var.folder_id
}

provider "kubernetes" {
  host                   = data.yandex_kubernetes_cluster.this.master[0].external_v4_endpoint
  cluster_ca_certificate = base64decode(data.yandex_kubernetes_cluster.this.master[0].cluster_ca_certificate)
  token                  = data.yandex_kubernetes_cluster.this.master[0].cluster_auth_token
}

provider "helm" {
  kubernetes {
    host                   = data.yandex_kubernetes_cluster.this.master[0].external_v4_endpoint
    cluster_ca_certificate = base64decode(data.yandex_kubernetes_cluster.this.master[0].cluster_ca_certificate)
    token                  = data.yandex_kubernetes_cluster.this.master[0].cluster_auth_token
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Notification channel (Telegram)
# ─────────────────────────────────────────────────────────────────────────────

resource "yandex_monitoring_notification_channel" "telegram" {
  name        = "${local.name_prefix}-alerts-telegram"
  description = "Telegram alerts for ${var.environment}"
  telegram {
    chatbot_token_secret_id = var.telegram_bot_token_kms_secret_id
    chat_id                 = var.telegram_chat_id
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Helm release: kube‑prometheus‑stack + Loki + Thanos (minio‑gw)
# ─────────────────────────────────────────────────────────────────────────────

resource "helm_release" "kube_prom_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "57.0.2"          # совместимо с K8s 1.29
  namespace        = "monitoring"
  create_namespace = true

  values = [
    yamlencode({
      grafana = {
        ingress = {
          enabled = true
          annotations = {
            "nginx.ingress.kubernetes.io/rewrite-target" = "/"
          }
          hosts = ["grafana.${var.domain}"]
        }
      }
      prometheus = {
        prometheusSpec = {
          retention          = "${var.retention_hot_days}d"
          retentionSize      = "20Gi"
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "network-hdd"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "20Gi"
                  }
                }
              }
            }
          }
        }
      }
    })
  ]
}

resource "helm_release" "loki_stack" {
  name             = "loki-stack"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  version          = "2.10.2"
  namespace        = "monitoring"
  depends_on       = [helm_release.kube_prom_stack]

  values = [
    yamlencode({
      loki = {
        persistence = {
          enabled      = true
          size         = "20Gi"
          storageClass = "network-hdd"
        }
        structuredConfig = {
          storage_config = {
            aws = {
              s3       = "https://${var.bucket_name}.storage.yandexcloud.net"
              bucketnames = var.bucket_name
              endpoint  = "storage.yandexcloud.net"
            }
          }
          schema_config = {
            configs = [
              {
                from = "2020-10-24"
                store = "boltdb-shipper"
                object_store = "aws"
                schema = "v11"
                index = {
                  prefix = "loki_index_"
                  period = "${var.retention_cold_days}d"
                }
              }
            ]
          }
        }
      }
    })
  ]
}

# (опционно) Thanos store‑gateway / compactor / query – добавляется аналогично
