resource "yandex_alb_virtual_host" "waf" {
  name           = "${var.project}-${var.environment}-waf"
  http_router_id = yandex_alb_http_router.waf.id
  authority      = ["${var.domain}"]

  route {
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.waf.id
      }
    }
  }
}
