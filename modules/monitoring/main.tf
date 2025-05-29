data "yandex_kubernetes_cluster" "this" {
  cluster_id = var.k8s_cluster_id
}

locals {
  kubeconfig = data.yandex_kubernetes_cluster.this.kube_config[0].raw_config
}

provider "kubernetes" {
  config_path    = "/tmp/kubeconfig.yml"

  dynamic "kubeconfig_raw" {
    for_each = [local.kubeconfig]
    content  = kubeconfig_raw.value
  }
}

provider "helm" {
  kubernetes {
    config_path = "/tmp/kubeconfig.yml"
  }
}

resource "local_file" "tmp_kubeconfig" {
  content  = local.kubeconfig
  filename = "/tmp/kubeconfig.yml"
}

resource "yandex_monitoring_notification_service" "telegram" {
  name        = "${var.domain}-tg"
  telegram_settings {
    telegram_chat_id = var.telegram_chat_id
    bot_token_secret_id = var.telegram_bot_token_kms_secret_id
  }
}
