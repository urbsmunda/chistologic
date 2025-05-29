### outputs.tf ###

output "cluster_id" {
  description = "ID of the Managed Kubernetes cluster"
  value       = yandex_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "Name of the cluster"
  value       = yandex_kubernetes_cluster.this.name
}

output "kubeconfig" {
  description = "Kubeconfig in YAML format (base64-encoded)"
  value       = yandex_kubernetes_cluster.this.kubeconfig
  sensitive   = true
}

output "node_group_id" {
  description = "ID of the default node group"
  value       = yandex_kubernetes_node_group.default.id
}
