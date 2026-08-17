module "vpc_dev" {
  source   = "./vpc"
  env_name = "develop"

  subnets = [
    {
      zone = "ru-central1-a"
      cidr = "10.0.1.0/24"
    }
  ]
}

module "vpc_prod" {
  source   = "./vpc"
  env_name = "production"

  subnets = [
    {
      zone = "ru-central1-a"
      cidr = "10.0.1.0/24"
    },
    {
      zone = "ru-central1-b"
      cidr = "10.0.2.0/24"
    },
    {
      zone = "ru-central1-d"
      cidr = "10.0.3.0/24"
    }
  ]
}

module "marketing_vm" {
  source     = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name   = "develop"
  network_id = module.vpc_dev.network_id
  subnet_zones = [
    module.vpc_dev.subnets["ru-central1-a"].zone
  ]
  subnet_ids = [
    module.vpc_dev.subnets["ru-central1-a"].id
  ]
  instance_name  = "marketing"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    project = "marketing"
  }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
    serial-port-enable = 1
  }

}

module "analytics_vm" {
  source     = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name   = "stage"
  network_id = module.vpc_dev.network_id
  subnet_zones = [
    module.vpc_dev.subnets["ru-central1-a"].zone
  ]
  subnet_ids = [
    module.vpc_dev.subnets["ru-central1-a"].id
  ]
  instance_name  = "analytics"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    project = "analytics"
  }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
    serial-port-enable = 1
  }

}

#Пример передачи cloud-config в ВМ для демонстрации №3
data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    ssh_public_key = var.public_key
  }
}

moved {
  from = yandex_vpc_network.develop
  to   = module.vpc_dev.yandex_vpc_network.develop
}

moved {
  from = yandex_vpc_subnet.develop_a
  to   = module.vpc_dev.yandex_vpc_subnet.develop_a
}

