### outputs.tf ###

output "cluster_id" {
  value       = yandex_mdb_postgresql_cluster.this.id
  description = "Managed PostgreSQL cluster ID"
}

output "primary_fqdn" {
  value       = yandex_mdb_postgresql_cluster.this.host[0].fqdn
  description = "FQDN of the primary host"
}

output "db_user" {
  value       = yandex_mdb_postgresql_user.app.name
  description = "Database user name"
  sensitive   = true
}

output "db_password" {
  value       = random_password.password.result
  description = "Database user password"
  sensitive   = true
}
