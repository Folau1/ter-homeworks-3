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

