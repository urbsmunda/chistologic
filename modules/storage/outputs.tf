### outputs.tf ###

output "bucket_id" {
  description = "Name / ID of the created Object Storage bucket"
  value       = yandex_storage_bucket.this.bucket
}

output "bucket_domain" {
  description = "FQDN to access the bucket via HTTPS"
  value       = "https://${yandex_storage_bucket.this.bucket}.storage.yandexcloud.net"
}
