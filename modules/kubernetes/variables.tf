### variables.tf ###

variable "folder_id" {
  description = "Yandex Cloud Folder ID where the Managed Kubernetes cluster will be created"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC network to which the cluster will be attached"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs that the cluster control-plane and node groups will use"
  type        = list(string)
}

variable "environment" {
  description = "Deployment environment name (dev, stage, prod, etc.) used in resource names and tags"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project slug added to resource names to keep them unique"
  type        = string
  default     = "chistologic"
}

variable "cluster_version" {
  description = "Desired Kubernetes minor version to deploy (supported by YC)"
  type        = string
  default     = "1.29"
}

variable "public_endpoint" {
  description = "Expose public API endpoint for the cluster (true / false)"
  type        = bool
  default     = true
}

variable "node_count" {
  description = "Initial number of nodes in the default node group"
  type        = number
  default     = 3
}

variable "node_min_count" {
  description = "Minimal number of nodes when autoscaler is enabled"
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum number of nodes when autoscaler is enabled"
  type        = number
  default     = 10
}

variable "node_instance_type" {
  description = "YC compute instance type for cluster nodes"
  type        = string
  default     = "standard-v2"
}

variable "node_platform_id" {
  description = "YC hardware platform ID (intel-broadwell, etc.)"
  type        = string
  default     = "standard-v2"
}

variable "node_disk_type" {
  description = "Disk type for cluster nodes"
  type        = string
  default     = "network-ssd"
}

variable "node_disk_size" {
  description = "Boot disk size in GB for cluster nodes"
  type        = number
  default     = 50
}

variable "enable_ingress" {
  description = "Deploy NGINX Ingress Controller via YC Marketplace helm-chart"
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Deploy cert-manager via helm chart if true"
  type        = bool
  default     = true
}

variable "cluster_autoscaler" {
  description = "Object with cluster-autoscaler settings"
  type = object({
    enabled          = bool
    min_nodes_total  = number
    max_nodes_total  = number
  })
  default = {
    enabled          = true
    min_nodes_total  = 1
    max_nodes_total  = 10
  }
}
