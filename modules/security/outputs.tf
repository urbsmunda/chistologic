### outputs.tf ###

output "kms_key_id" {
  description = "ID of the root KMS symmetric key"
  value       = yandex_kms_symmetric_key.default.id
}

output "sg_public_lb_id" {
  description = "Security Group ID for ALB public listener"
  value       = try(yandex_vpc_security_group.public_lb[0].id, null)
}

output "sg_k8s_nodes_id" {
  description = "Security Group ID for Kubernetes nodes"
  value       = try(yandex_vpc_security_group.k8s_nodes[0].id, null)
}

output "sg_postgresql_id" {
  description = "Security Group ID for PostgreSQL"
  value       = try(yandex_vpc_security_group.postgresql[0].id, null)
}

output "waf_http_router_id" {
  description = "HTTP router ID configured with WAF (null if disabled)"
  value       = try(yandex_alb_http_router.main[0].id, null)
}

output "waf_enabled" {
  description = "Flag indicating whether WAF is enabled"
  value       = var.enable_waf
}
