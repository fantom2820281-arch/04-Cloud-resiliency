resource "yandex_lb_network_load_balancer" "nlb" {
  name      = "${var.flow}-lb"
  region_id = "ru-central1"

  listener {
    name        = "http"
    port        = 80
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.web_ig.load_balancer[0].target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
      interval            = 10
      timeout             = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }
  }
}