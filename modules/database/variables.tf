### variables.tf ###

variable "folder_id" {
  description = "Yandex Cloud Folder ID in which the PostgreSQL cluster will be created"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod, etc.) used in resource names"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project slug used as a prefix for resource names"
  type        = string
  default     = "chistologic"
}

variable "subnet_ids" {
  description = "List of subnet IDs dedicated to the database cluster"
  type        = list(string)
}

variable "db_version" {
  description = "PostgreSQL major version"
  type        = number
  default     = 17
}

variable "instance_type" {
  description = "YC compute instance type for each host"
  type        = string
  default     = "s3.nano"
}

variable "disk_type" {
  description = "Disk type for data storage (network-ssd, network-hdd, etc.)"
  type        = string
  default     = "network-ssd"
}

variable "disk_size" {
  description = "Disk size in GiB"
  type        = number
  default     = 50
}

variable "extensions" {
  description = "List of DB extensions to enable"
  type        = list(string)
  default     = []
}

variable "backup_retention" {
  description = "Number of days to keep automatic backups"
  type        = number
  default     = 7
}
