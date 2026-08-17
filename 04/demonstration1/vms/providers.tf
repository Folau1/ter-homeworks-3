terraform {
  required_version = "~> 1.12.0"

  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  backend "s3" {
    bucket = "folau1-tfstate-bga82v"
    key    = "terraform.tfstate"
    region = "ru-central1"

    use_lockfile = true

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  # token                    = "do not use!!!"
  cloud_id                 = "b1gv7lvg8rc9365h90lt"
  folder_id                = "b1g40q4ai8pdtrbga82v"
  service_account_key_file = file("~/authorized_key.json")
  zone                     = "ru-central1-a"
}