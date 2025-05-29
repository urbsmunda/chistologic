variable "project" {
  description = "Project prefix for all resources"
  type        = string
  default     = "chistologic"
}

variable "domain" {
  description = "Public domain for the project (e.g. chisto.log)"
  type        = string
}

# остальные переменные (cloud_id, folder_id …) остаются без изменений
