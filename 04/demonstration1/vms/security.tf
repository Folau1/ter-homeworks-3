resource "yandex_vpc_security_group" "private_vms" {
  name        = "develop-private-vms"
  description = "Security group for marketing and analytics VMs"
  network_id  = module.vpc_dev.network_id

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH from development subnet"
    v4_cidr_blocks = ["10.0.1.0/24"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow HTTP from development subnet"
    v4_cidr_blocks = ["10.0.1.0/24"]
    port           = 80
  }

  egress {
    protocol       = "ANY"
    description    = "Allow outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}