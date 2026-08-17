output "network_id" {
  value = yandex_vpc_network.develop.id
}

output "subnets" {
  value = yandex_vpc_subnet.subnet
}