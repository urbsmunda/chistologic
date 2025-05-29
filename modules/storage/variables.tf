### variables.tf ###

variable "folder_id" {
  description = "Yandex Cloud Folder ID where the backup / artifact bucket will be created"
  type        = string
}

variable "environment" {
  description = "Deployment environment tag (dev, stage, prod, …)"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project slug used as prefix for resource names"
  type        = string
  default     = "chistologic"
}

variable "bucket_name" {
  description = "S3 bucket name (leave default to generate automatically)"
  type        = string
  default     = ""
}

variable "enable_versioning" {
  description = "Enable object versioning (recommended for backups)"
  type        = bool
  default     = true
}

variable "lifecycle_policy" {
  description = "Map describing lifecycle rule: { id = string, days = number, status = string }"
  type = object({
    id     = string
    days   = number
    status = string
  })
  default = {
    id     = "expire-old-versions"
    days   = 30
    status = "Enabled"
  }
}
