### outputs.tf ###

output "service_account_id" {
  description = "ID of the workload Service Account"
  value       = yandex_iam_service_account.workload.id
}

output "service_account_name" {
  description = "Name of the workload Service Account"
  value       = yandex_iam_service_account.workload.name
}
