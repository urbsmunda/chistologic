### clone\modules\vpc\outputs.tf ###

output "vpc_id" {
  description = "ID of the created VPC network"
  value       = yandex_vpc_network.this.id
}

output "subnet_ids" {
  description = "Map of subnet category to list of subnet IDs"
  value = {
    public  = [for s in yandex_vpc_subnet.public : s.id]
    private = [for s in yandex_vpc_subnet.private : s.id]
    db      = [for s in yandex_vpc_subnet.db : s.id]
  }
}

output "nat_gateway_id" {
  description = "ID of NAT gateway (if created)"
  value       = var.enable_nat_gateway ? yandex_vpc_gateway.nat[0].id : null
}

output "dns_zone_id" {
  description = "ID of DNS zone (if created)"
  value       = var.enable_dns_zone ? yandex_dns_zone.public[0].id : null
}
