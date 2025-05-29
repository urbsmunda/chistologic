variable "domain" {
  description = "Root DNS zone for Grafana/Alertmanager FQDN"
  type        = string
}

variable "k8s_cluster_id" {
  description = "Target Managed Kubernetes cluster ID"
  type        = string
}
