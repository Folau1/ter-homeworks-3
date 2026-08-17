terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "~>1.12.0"
}

provider "yandex" {
  # token                    = "do not use!!!"
  cloud_id                 = "b1gv7lvg8rc9365h90lt"
  folder_id                = "b1g40q4ai8pdtrbga82v"
  service_account_key_file = file("~/authorized_key.json")
  zone                     = "ru-central1-a"
}
