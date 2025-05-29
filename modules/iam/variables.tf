### variables.tf ###

variable "folder_id" {
  description = "Yandex Cloud Folder ID where service accounts and IAM bindings will be created"
  type        = string
}

variable "environment" {
  description = "Deployment environment tag (dev, stage, prod, …) used for naming"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project slug to prefix resource names and labels"
  type        = string
  default     = "chistologic"
}

variable "sa_roles" {
  description = "Map of roles to attach to the workload service account (least‑privilege)"
  type        = map(string)
  default = {
    # example:   role                = scope
    "storage.objectViewer"         = "cloud"
    "container-registry.images.puller" = "cloud"
    "container-registry.images.pusher" = "folder"
  }
}
