output "k8s_subnet_ids" {
  description = "IDs of subnets dedicated to the Kubernetes cluster"
  value       = [for s in yandex_vpc_subnet.k8s : s.id]
}

output "db_subnet_ids" {
  description = "IDs of subnets dedicated to the managed Postgres cluster"
  value       = [for s in yandex_vpc_subnet.db : s.id]
}
