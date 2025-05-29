### outputs.tf ###

output "telegram_channel_id" {
  description = "ID of the created Telegram notification channel"
  value       = yandex_monitoring_notification_channel.telegram.id
}

output "grafana_admin_password" {
  description = "Randomly‑generated admin password for Grafana (from Helm release)"
  value       = helm_release.kube_prom_stack.metadata["annotations"].admin-password
  sensitive   = true
}

output "grafana_url" {
  description = "Public URL of Grafana ingress (if DNS configured)"
  value       = "https://grafana.${var.domain}"
}
