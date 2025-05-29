### variables.tf ###

variable "folder_id" {
  description = "Yandex Cloud Folder ID where monitoring resources (notification channels, etc.) will be created"
  type        = string
}

variable "environment" {
  description = "Deployment environment tag (dev, stage, prod, …)"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project slug used as a prefix in resource names"
  type        = string
  default     = "chistologic"
}

variable "k8s_cluster_name" {
  description = "Name of the Managed Kubernetes cluster where the monitoring stack will be installed"
  type        = string
}

variable "retention_hot_days" {
  description = "Retention period (days) for hot Prometheus data (on‑cluster PV)"
  type        = number
  default     = 15
}

variable "retention_cold_days" {
  description = "Retention period (days) for cold metrics in object storage (Thanos / VictoriaMetrics)"
  type        = number
  default     = 365
}

variable "bucket_name" {
  description = "Existing Object Storage bucket for long‑term metrics and Loki chunks"
  type        = string
}

variable "telegram_bot_token_kms_secret_id" {
  description = "ID of KMS‑encrypted Lockbox secret that stores the Telegram bot token"
  type        = string
}

variable "telegram_chat_id" {
  description = "Telegram chat ID where alerts will be sent"
  type        = string
}
