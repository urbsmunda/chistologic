### outputs.tf ###

output "zone_id" {
  value       = yandex_dns_zone.this.id
  description = "ID of the created DNS zone"
}

output "zone_name" {
  value       = yandex_dns_zone.this.zone
  description = "DNS zone name (FQDN with trailing dot)"
}
