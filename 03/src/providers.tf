terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
  required_version = "~>1.12.0"
}

provider "yandex" {

  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}
