resource "yandex_iam_service_account" "workload" {
  name        = "${var.project}-${var.environment}-sa"
  description = "Service account for workload identity federation"
}
