module "vpc" {
  source      = "./modules/vpc"
  project     = var.project
  environment = var.environment
}

module "kubernetes" {
  source          = "./modules/kubernetes"
  subnet_ids      = module.vpc.k8s_subnet_ids
  # …
}

module "database" {
  source      = "./modules/database"
  subnet_ids  = module.vpc.db_subnet_ids
  # …
}

module "dns" {
  source      = "./modules/dns"
  project     = var.project
  environment = var.environment
  domain      = var.domain
}

module "monitoring" {
  source           = "./modules/monitoring"
  domain           = var.domain
  k8s_cluster_id   = module.kubernetes.cluster_id
  telegram_chat_id = var.telegram_chat_id
  telegram_bot_token_kms_secret_id = var.telegram_bot_token_kms_secret_id
}
