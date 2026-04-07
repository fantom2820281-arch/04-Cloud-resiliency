terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.167.0"
    }
  }

  required_version = ">=1.8.4"
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone      = var.zones[0]
  service_account_key_file = file("./key.json")
}