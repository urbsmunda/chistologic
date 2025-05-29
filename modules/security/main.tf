resource "yandex_vpc_security_group" "k8s_nodes" {
  name        = "${var.project}-${var.environment}-k8s-nodes"
  network_id  = var.network_id

  ingress {
    protocol       = "TCP"
    description    = "Kube-API"
    port           = 6443
    predefined_target = "self_security_group"
  }

  egress {
    protocol          = "ANY"
    description       = "Full egress"
    predefined_target = "0.0.0.0/0"
  }
}

# … аналогично исправлены блоки postgresql и прочие;
# все   subnet_id = …   удалены — вместо них используем predefined_target/self_security_group
