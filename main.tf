### main.tf ###

###############################################################################
#  ChistoLogic – root Terraform layer                                         #
#  (clean structure: provider + modules only)                                 #
###############################################################################

terraform {
  required_version = ">= 1.5"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.90"
    }
  }
}

provider "yandex" {
  # IAM‑token supplied by GitHub Actions OIDC step, so token argument is omitted
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}

###############################################################################
#  MODULES                                                                    #
###############################################################################

module "iam" {
  source      = "./modules/iam"
  folder_id   = var.folder_id
  environment = var.environment
}

module "vpc" {
  source               = "./modules/vpc"
  folder_id            = var.folder_id
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  db_subnets_cidr      = var.db_subnets_cidr
  environment          = var.environment
}

module "dns" {
  source      = "./modules/dns"
  folder_id   = var.folder_id
  domain      = var.domain
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

module "kubernetes" {
  source          = "./modules/kubernetes"
  folder_id       = var.folder_id
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.k8s_subnet_ids
  environment     = var.environment
  public_endpoint = true

  cluster_autoscaler = {
    enabled         = true
    min_nodes_total = 1
    max_nodes_total = 10
  }
}

module "database" {
  source           = "./modules/database"
  folder_id        = var.folder_id
  subnet_ids       = module.vpc.db_subnet_ids
  environment      = var.environment
  db_version       = 17
  instance_type    = "s3.nano"
  disk_type        = "network-ssd"
  disk_size        = 50
  backup_retention = 7
  extensions       = ["postgis"]
}

module "storage" {
  source              = "./modules/storage"
  folder_id           = var.folder_id
  environment         = var.environment
  project             = "chistologic"
  bucket_name         = "chistologic-${var.environment}-backups"
  enable_versioning   = true
  lifecycle_policy = {
    id     = "expire-old-versions"
    days   = 30
    status = "Enabled"
  }
}

module "monitoring" {
  source                           = "./modules/monitoring"
  folder_id                        = var.folder_id
  environment                      = var.environment
  telegram_bot_token_kms_secret_id = var.telegram_bot_token_kms_secret_id
  retention_hot_days               = 15
  retention_cold_days              = 365
  bucket_name                      = var.bucket_name
  telegram_chat_id                 = var.telegram_chat_id
  k8s_cluster_name                 = var.k8s_cluster_name

}

module "security" {
  source             = "./modules/security"
  folder_id          = var.folder_id
  environment        = var.environment
  enable_waf         = true
  waf_policy_ruleset = "OWASP_CRS"
}
