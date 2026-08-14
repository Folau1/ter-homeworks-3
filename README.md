# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»

## Чек лист по готовности.

1. Аккаунт зарегистрирован в Yandex cloud (по прошлым занятиям)
2. Yandex CLI тоже установлен по прошлым занятиям.
3. Исходных код имеется на личном ПК.

Работа будет вестись через VS Code.

## Задание 1.

### 1-3

По заданию нам надо взять полностью код из demonstration1.

В providers.tf подставляем свои данные.
И в cloud-init.yml меняем параметры. Делаем ssh_public_key в виде списка (не строка).
Добавляем -nginx и получается следующий конфиг:

```
#cloud-config
users:
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    ssh_authorized_keys: 
          - ${ssh_public_key}
package_update: true
package_upgrade: false
packages:
  - vim
  - nginx

```

И меняем передачу cloud-init.yml:

```
data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    ssh_public_key = var.public_key
  }
}
```

Не забываем везде убрать токены для яндекса и в variables подставить свой ssh ключ.

Делаем terraform validation, plan, и apply:

```
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

out = [
  "develop-marketing-0.ru-central1.internal",
  "stage-analytics-0.ru-central1.internal",
]
```

Скриншоты модулей:

<img width="797" height="812" alt="image" src="https://github.com/user-attachments/assets/587762a1-9c62-4427-b52e-b86f0c6043dc" />

<img width="799" height="803" alt="image" src="https://github.com/user-attachments/assets/0df55981-82ed-461f-af31-8d2bbfabc907" />

И скриншот nginx -t с самого сервера:

<img width="563" height="83" alt="image" src="https://github.com/user-attachments/assets/b9405c9a-92aa-45ad-9a20-2c5ea00ed70c" />

Метка в яндекс клауде:

<img width="694" height="463" alt="image" src="https://github.com/user-attachments/assets/697ab7c3-bbc8-461a-8a16-2e1e2eb87377" />

## Задание 2.

### 1-5 

Пишем свой модуль.

Для этого создаем папку vpc и добавляем 4 новых файла:

```
main.tf
outputs:tf
providers.tf
variables.tf
```

В variables.tf объявили переменные:

```
variable "network_name" {
  type = string
}

variable "zone" {
  type = string
}

variable "v4_cidr_blocks" {
  type = list(string)
}
```
Дальше в main.tf записываем два ресурса это сеть и подсеть

```
#создаем облачную сеть
resource "yandex_vpc_network" "develop" {
  name = var.network_name
}

#создаем подсеть
resource "yandex_vpc_subnet" "develop_a" {
  name           = "${var.network_name}-${var.zone}"
  zone           = var.zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.v4_cidr_blocks
}
```

network_id не передаю т.к. внутри самого модуля уже есть.
Чтобы получить информацию о подсетях, добавим просто в output.tf

```
output "subnet" {
  value = yandex_vpc_subnet.develop_a
}
```

Таким образом наружу возвращается не только ID, а объект подсети целиком.
Для того, чтобы вызвать локальный модуль мы делаем в основном main.tf вызов:

```
module "vpc_dev" {
  source = "./vpc"

  network_name   = "develop"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.0.1.0/24"]
}
```

После вызова добавим параметры модуля в analytics_vm и marketing_vm

Для marketing_vm:
```
network_id   = module.vpc_dev.subnet.network_id
subnet_zones = [module.vpc_dev.subnet.zone]
subnet_ids   = [module.vpc_dev.subnet.id]
```

Для analytics_vm:
```
network_id   = module.vpc_dev.subnet.network_id
subnet_zones = [module.vpc_dev.subnet.zone]
subnet_ids   = [module.vpc_dev.subnet.id]
```

То есть теперь ВМ напрямую не обращаются к ресурсам VPC, а получают необходимую информацию через output нашего локального модуля.


Так как сеть и подсеть уже были созданы в предыдущем задании, после переноса ресурсов внутрь модуля Terraform сначала хотел удалить старые ресурсы и создать такие же заново:

```
Plan: 2 to add, 2 to change, 3 to destroy.
```


Чтобы не пересоздавать существующую инфраструктуру, добавил блоки moved:

```
moved {
  from = yandex_vpc_network.develop
  to   = module.vpc_dev.yandex_vpc_network.develop
}

moved {
  from = yandex_vpc_subnet.develop_a
  to   = module.vpc_dev.yandex_vpc_subnet.develop_a
}
```

После этого Terraform понял, что ресурсы не были удалены, а просто изменили своё расположение в конфигурации.
План изменился:
```
Plan: 0 to add, 0 to change, 1 to destroy.
```
Будет удалена только подсеть develop_b это нужно, потому что по заданию только одна подсеть должна быть.

Открываем terraform console и проверяем модуль:

```
PS C:\Users\Александр\Documents\Project3\ter-homeworks\04\demonstration1\vms> terraform console
> module.vpc_dev
{
  "subnet" = {
    "created_at" = "2026-08-14T05:03:51Z"
    "description" = ""
    "dhcp_options" = tolist([])
    "folder_id" = "b1g40q4ai8pdtrbga82v"
    "id" = "e9bo8cr29bbqosr2k6i0"
    "labels" = tomap({})
    "name" = "develop-ru-central1-a"
    "network_id" = "enppit0psk208btkn17f"
    "route_table_id" = ""
    "timeouts" = null /* object */
    "v4_cidr_blocks" = tolist([
      "10.0.1.0/24",
    ])
    "v6_cidr_blocks" = tolist([])
    "zone" = "ru-central1-a"
  }
}
```
И скриншот:

<img width="705" height="384" alt="image" src="https://github.com/user-attachments/assets/1c5c75e0-0ab1-4cde-ab01-dd917bc69ccb" />

Для генерации документации нужно скачать terraform-docs.
Я его скачал с гитхаба и засунул в PATH. Получилось следущее:

```
terraform-docs --version
terraform-docs version v0.24.0 9d44551 windows/amd64
```
После этого сгенерировал документ командой:

```
terraform-docs markdown table --output-file README.md --output-mode replace .\vpc
```

В результате в vpc/README.md автоматически появилась информация о:

Providers
Resources
Inputs
Outputs

И краткий вывод:
Наш локальный модуль создает одну сеть и подсеть, получает параметры через output и возвращает информацию о подсети обратно в root module.

## Задание 3.

Сначала посмотрим полный список state:

```
PS C:\Users\Александр\Documents\Project3\ter-homeworks\04\demonstration1\vms> terraform state list
data.template_file.cloudinit
module.analytics_vm.data.yandex_compute_image.my_image
module.analytics_vm.yandex_compute_instance.vm[0]
module.marketing_vm.data.yandex_compute_image.my_image
module.marketing_vm.yandex_compute_instance.vm[0]
module.vpc_dev.yandex_vpc_network.develop
module.vpc_dev.yandex_vpc_subnet.develop_a
```

Из вывода видно, что Terraform хранит в state ресурсы двух виртуальных машин и локального модуля vpc_dev.

<img width="744" height="220" alt="image" src="https://github.com/user-attachments/assets/92bffafe-2361-4d98-b107-3b1de215fb2b" />

Удаляем из state модуль vpc_dev:

terraform state rm 'module.vpc_dev'

```
PS C:\Users\Александр\Documents\Project3\ter-homeworks\04\demonstration1\vms> terraform state rm 'module.vpc_dev'
Removed module.vpc_dev.yandex_vpc_network.develop
Removed module.vpc_dev.yandex_vpc_subnet.develop_a
Successfully removed 2 resource instance(s).
```

Эта команда удаляет только информацию о Terraform state.
Удаляем виртуальные машины:

```
PS C:\Users\Александр\Documents\Project3\ter-homeworks\04\demonstration1\vms> terraform state rm 'module.marketing_vm'
Removed module.marketing_vm.data.yandex_compute_image.my_image
Removed module.marketing_vm.yandex_compute_instance.vm[0]
Successfully removed 2 resource instance(s).
PS C:\Users\Александр\Documents\Project3\ter-homeworks\04\demonstration1\vms> terraform state rm 'module.analytics_vm'
Removed module.analytics_vm.data.yandex_compute_image.my_image
Removed module.analytics_vm.yandex_compute_instance.vm[0]
Successfully removed 2 resource instance(s).
```
<img width="767" height="281" alt="image" src="https://github.com/user-attachments/assets/ce33a916-43c7-406f-96bd-8f25d421c790" />


После удалеиня делаем terraform state list:

```
PS C:\Users\Александр\Documents\Project3\ter-homeworks\04\demonstration1\vms> terraform state list          
data.template_file.cloudinit      
```

Остаеться только data.template_file.cloudinit это значит что все наши вирт машины удалены.

Реальные ресурсы в Yandex Cloud всё это время продолжали существовать. Чтобы Terraform снова начал ими управлять, импортировал их обратно по ID:

```
terraform import 'module.vpc_dev.yandex_vpc_network.develop' enppit0psk208btkn17f
terraform import 'module.vpc_dev.yandex_vpc_subnet.develop_a' e9bo8cr29bbqosr2k6i0
terraform import 'module.marketing_vm.yandex_compute_instance.vm[0]' fhmf6kkgn9chfds5bdj9
terraform import 'module.analytics_vm.yandex_compute_instance.vm[0]' fhm3gjgpee33f5rqtk7i
```

После импорта проверяем terraform state:

```
data.template_file.cloudinit
module.analytics_vm.data.yandex_compute_image.my_image
module.analytics_vm.yandex_compute_instance.vm[0]
module.marketing_vm.data.yandex_compute_image.my_image
module.marketing_vm.yandex_compute_instance.vm[0]
module.vpc_dev.yandex_vpc_network.develop
module.vpc_dev.yandex_vpc_subnet.develop_a
```

Таким образом Terraform снова видит и управляет существующими ресурсами.

И последнее, проверяем terraform plan.
Получил:

```
Plan: 0 to add, 2 to change, 0 to destroy.
```

В итоге ничего не добавляется и не уничтожается.
Я удалил ресурсы из Terraform state без удаления самих ресурсов в Yandex Cloud, а затем импортировал их обратно и восстановил управление ими через Terraform.
Задание выполнено!

Задание 4*

