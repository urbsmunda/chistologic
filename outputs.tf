### outputs.tf ###

output "kubeconfig_command" {
  description = "Command to fetch kube‑config for the created Managed K8s cluster"
  value       = "yc managed-kubernetes cluster get-credentials --name ${module.kubernetes.cluster_name} --external"
}

output "bucket_id" {
  description = "Object Storage bucket name that stores backups / artifacts"
  value       = module.storage.bucket_id
}

output "bucket_domain" {
  description = "Fully‑qualified HTTPS endpoint for the bucket"
  value       = module.storage.bucket_domain
}
