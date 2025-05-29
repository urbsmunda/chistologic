resource "yandex_storage_bucket" "this" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    expiration_days = var.lifecycle_policy.days
  }
}
