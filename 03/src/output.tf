output "vm_info" {
  value = concat(
    [
      for vm in yandex_compute_instance.web : {
        name = vm.name
        id   = vm.id
        fqdn = vm.fqdn
      }
    ],
    [
      for vm in values(yandex_compute_instance.db) : {
        name = vm.name
        id   = vm.id
        fqdn = vm.fqdn
      }
    ]
  )
}

output "bastion_ip" {
  description = "Внешний IP бастион-сервера"
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}