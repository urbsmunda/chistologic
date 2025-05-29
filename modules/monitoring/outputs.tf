output "grafana_url" {
  value       = "https://grafana.${var.domain}"
  description = "External URL of managed Grafana instance"
}
