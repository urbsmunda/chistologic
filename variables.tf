### variables.tf ###

variable "cloud_id" {
  description = "Yandex Cloud ID (organisation level)"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID where all resources will be provisioned"
  type        = string
}

variable "environment" {
  description = "Deployment environment tag (dev, stage, prod, etc.)"
  type        = string
  default     = "prod"
}

variable "default_zone" {
  description = "Default availability zone for resources that accept a single zone"
  type        = string
  default     = "ru-central1-a"
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.10.0.0/24"]
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "db_subnets_cidr" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.10.2.0/28"]
}

variable "domain" {
  description = "Root DNS domain managed by the platform"
  type        = string
  default     = "chistologic.ru"
}

variable "object_storage_access_key" {
  description = "Access key for Object Storage bucket that stores the remote Terraform state"
  type        = string
  sensitive   = true
}

variable "object_storage_secret_key" {
  description = "Secret key for Object Storage bucket that stores the remote Terraform state"
  type        = string
  sensitive   = true
}

variable "telegram_bot_token_kms_secret_id" {
  description = "KMS secret ID that contains the Telegram bot token for alerting"
  type        = string
}
