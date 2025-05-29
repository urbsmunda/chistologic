### main.tf ###

terraform {
  required_version = ">= 1.5"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.90"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

###############################################################################
# Managed Kubernetes Cluster                                                  #
###############################################################################

resource "yandex_kubernetes_cluster" "this" {
  name        = "${var.project}-${var.environment}-k8s"
  description = "Managed Kubernetes cluster for ${var.project} (${var.environment})"

  folder_id   = var.folder_id
  network_id  = var.vpc_id
  cluster_ipv4_range = "10.200.0.0/16"

  master {
    version   = var.cluster_version

    public_ip = var.public_endpoint

    regional {
      region = "ru-central1"

      location {
        zone      = "ru-central1-a"
        subnet_id  = var.subnet_ids[0]
      }
      location {
        zone      = "ru-central1-b"
        subnet_id  = length(var.subnet_ids) > 1 ? var.subnet_ids[1] : var.subnet_ids[0]
      }
      location {
        zone      = "ru-central1-c"
        subnet_id  = length(var.subnet_ids) > 2 ? var.subnet_ids[2] : var.subnet_ids[0]
      }
    }

    maintenance_policy {
      auto_upgrade = "true"
    }
  }

  service_account_id        = null  # IAM SA could be passed from root if created
  node_service_account_id   = null

  network_policy_provider = "CALICO"

  lifecycle {
    prevent_destroy = true
  }
}

###############################################################################
# Default Node Group                                                          #
###############################################################################

resource "yandex_kubernetes_node_group" "default" {
  name        = "${var.project}-${var.environment}-ng-default"
  cluster_id  = yandex_kubernetes_cluster.this.id
  folder_id   = var.folder_id

  instance_template {
    platform_id = var.node_platform_id
    resources {
      cores  = 2
      memory = 4
    }
    boot_disk_type = var.node_disk_type
    boot_disk_size = var.node_disk_size

    network_interface {
      subnet_ids = var.subnet_ids
      nat        = false  # public IPs disabled to reduce cost and improve security
    }
  }

  scale_policy {
    auto_scale {
      initial        = var.node_count
      min            = var.node_min_count
      max            = var.node_max_count
      preemptible    = false
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
    location {
      zone = "ru-central1-b"
    }
    location {
      zone = "ru-central1-c"
    }
  }

  maintenance_policy {
    auto_upgrade = true
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "40m"
  }

  depends_on = [yandex_kubernetes_cluster.this]
}

###############################################################################
# Optional addons via Helm                                                     #
###############################################################################

locals {
  kube_config = yandex_kubernetes_cluster.this.kubeconfig
}

provider "helm" {
  kubernetes {
    host                   = local.kube_config["server" ]
    cluster_ca_certificate = base64decode(local.kube_config["certificate-authority-data"])
    token                  = local.kube_config["token"]
  }
}

resource "helm_release" "ingress_nginx" {
  count      = var.enable_ingress ? 1 : 0
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.1"
  namespace  = "kube-system"

  values = [
    <<-EOF
    controller:
      replicaCount: 2
      service:
        annotations:
          service.beta.kubernetes.io/yandex-load-balancer-type: "external"
    EOF
  ]
  depends_on = [yandex_kubernetes_node_group.default]
}

resource "helm_release" "cert_manager" {
  count      = var.enable_cert_manager ? 1 : 0
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.15.0"
  namespace  = "cert-manager"

  set {
    name  = "installCRDs"
    value = "true"
  }
  depends_on = [yandex_kubernetes_node_group.default]
}

###############################################################################
# Cluster Autoscaler (optional)                                               #
###############################################################################

resource "helm_release" "cluster_autoscaler" {
  count      = var.cluster_autoscaler.enabled ? 1 : 0
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.29.0"
  namespace  = "kube-system"

  set {
    name  = "autoDiscovery.clusterName"
    value = yandex_kubernetes_cluster.this.name
  }

  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "true"
  }

  set {
    name  = "extraArgs.scale-down-unneeded-time"
    value = "10m"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  depends_on = [yandex_kubernetes_node_group.default]
}
