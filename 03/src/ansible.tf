resource "local_file" "hosts_templatefile" {
  content = templatefile("${path.module}/hosts.tftpl", {
    webservers = yandex_compute_instance.web
    databases  = values(yandex_compute_instance.db)
    storage    = [yandex_compute_instance.storage]
    bastion_ip = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
  })

  filename = "${abspath(path.module)}/hosts.ini"
}

resource "null_resource" "ansible_playbook" {
  triggers = {
    inventory_sha256 = local_file.hosts_templatefile.content_sha256
    playbook_sha256  = filesha256("${path.module}/test.yml")
  }

  depends_on = [
    local_file.hosts_templatefile
  ]

  provisioner "local-exec" {
    command = "wsl.exe -d Ubuntu-24.04 -- ansible-playbook -i /mnt/c/Users/Александр/Documents/Project3/ter-homeworks/03/src/hosts.ini /mnt/c/Users/Александр/Documents/Project3/ter-homeworks/03/src/test.yml"
  }

}