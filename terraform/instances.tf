data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}
resource "yandex_iam_service_account" "ig_sa" {
  name = "${var.flow}-ig-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "ig_sa_role" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.ig_sa.id}"
}

resource "yandex_compute_instance_group" "web_ig" {
  name               = "${var.flow}-web-ig"
  service_account_id = yandex_iam_service_account.ig_sa.id
  folder_id          = var.folder_id

  instance_template {
    platform_id = "standard-v3"
    resources {
      cores  = 2
      memory = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu_2204_lts.id
        type     = "network-ssd"
        size     = 10
      }
    }
    network_interface {
      network_id         = yandex_vpc_network.main.id
      security_group_ids = [yandex_vpc_security_group.main.id]
      #nat                = true
    }
    metadata = {
      # 🔥 Передаём ОБЕ переменные, которые ждёт твой cloud-init
      user-data = templatefile("${path.module}/cloud-init.yml.tftpl", {
        flow          = var.flow
        instance_name = "${var.flow}-vm"
      })
    }
  }

    allocation_policy {
    zones = var.zones
  }
  
  deploy_policy {
    max_unavailable = 1
    max_expansion   = 1
  }

  scale_policy {
    fixed_scale { size = 2 }
  }

  # Пустой блок → IG создаёт Target Group автоматически. Цикл с NLB разорван.
  load_balancer {}

  depends_on = [yandex_resourcemanager_folder_iam_member.ig_sa_role]
}