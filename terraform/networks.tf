# Networks
# ---------------------------------------------------

# --> Networks.Subnets
resource "yandex_vpc_subnet" "subnet-database" {
  folder_id      = var.folder_id
  name           = var.ya_cloud_subnet_main
  description    = "Main subnet"
  v4_cidr_blocks = [
    var.ya_cloud_subnet_cidr
  ]
  zone           = var.zone

  network_id = var.ya_cloud_network_id
  labels = {
    network-type = "main-network"
  }
}
# <-- Networks.Subnets

# --> DNS zone
resource "yandex_dns_zone" "otus-internal" {
  name        = "otus-internal"
  description = "Otus internal DNS zone"

  labels = {
    kind = "otus"
  }

  zone   = "internal.net."
  public = false
  private_networks = [
    var.ya_cloud_network_id
  ]
}

# resource "yandex_dns_recordset" "rs_front_001" {
#   zone_id = yandex_dns_zone.otus-internal.id
#   name    = yandex_compute_instance.srv-front-001.name
#   # name    = "srv.example.com."
#   type = "CNAME"
#   ttl  = 600
#   data = [yandex_compute_instance.srv-front-001.fqdn]
# }

# resource "yandex_dns_recordset" "rs_db_001" {
#   zone_id = yandex_dns_zone.otus-internal.id
#   name    = yandex_compute_instance.srv-db-001.name
#   type    = "CNAME"
#   ttl     = 600
#   data    = [yandex_compute_instance.srv-db-001.fqdn]
# }
# <-- DNS zone

# --> Networks.Security groups
resource "yandex_vpc_security_group" "sg-server-postgre-internal" {
  name        = "sg-server-postgre-internal"
  description = "internal communication between backend and PostgreSQL DB"
  network_id  = var.ya_cloud_network_id
  labels = {
    sg-access-type = "sg-server-postgre-internal"
  }
  ingress {
    protocol          = "TCP"
    description       = "(self) PostgreSQL port 5432"
    predefined_target = "self_security_group"
    port              = 5432
  }
  egress {
    protocol          = "TCP"
    description       = "(self) PostgreSQL port 5432"
    predefined_target = "self_security_group"
    port              = 5432
  }
}

resource "yandex_vpc_security_group" "sg-ssh-only" {
  name        = "sg-ssh-only"
  description = "minimal access by ssh"
  network_id = var.ya_cloud_network_id

  labels = {
    sg-access-type = "sg-ssh-only"
  }
  # SSH
  ingress {
    protocol    = "TCP"
    description = "SSH access"
    # v4_cidr_blocks = [
    #   "192.168.1.0/24",
    #   "192.168.0.0/24"
    # ]
    v4_cidr_blocks = ["0.0.0.0/0"]
    port = 22
  }

  egress {
    protocol    = "TCP"
    description = "SSH access"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port = 22
  }
}

# resource "yandex_vpc_security_group" "sg-smb" {
#   name        = "sg-smb"
#   description = "SMB (Server Message Block)"
#   network_id  = var.ya_cloud_network_id

#   labels = {
#     sg-access-type = "sg-smb"
#   }
#   ingress {
#     protocol       = "TCP"
#     description    = "TCP 445 — SMB over TCP: Windows"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     port           = 445
#   }
#   ingress {
#     protocol       = "TCP"
#     description    = "TCP 139 — SMB over TCP: NetBIOS. For Session Service."
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     port           = 139
#   }
#   ingress {
#     protocol       = "UDP"
#     description    = "SMB over UDP: Name Services"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     port           = 137
#   }
#   ingress {
#     protocol       = "UDP"
#     description    = "SMB over UDP: Datagram"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     port           = 138
#   }

#   egress {
#     protocol       = "ANY"
#     description    = "ANY ports to output"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     from_port      = 0
#     to_port        = 65535
#   }
# }

resource "yandex_vpc_security_group" "sg-allow-all" {
  name        = "sg-allow-all"
  description = "Allow all access"
  network_id  = var.ya_cloud_network_id

  labels = {
    sg-access-type = "sg-allow-all"
  }

  ingress {
    protocol       = "ANY"
    description    = "ANY ports to output"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    protocol       = "ANY"
    description    = "ANY ports to output"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "sg-front" {
  name        = "sg-front-server-access"
  description = "FRONT server access"
  network_id  = var.ya_cloud_network_id

  labels = {
    sg-access-type = "sg-front-server"
  }

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      protocol       = "TCP"
      description    = "Input rule for port ${ingress.value}"
      v4_cidr_blocks = ["0.0.0.0/0"]
      from_port      = ingress.value
      to_port        = ingress.value
    }
  }

  dynamic "egress" {
    for_each = ["80", "443"]
    content {
      protocol       = "TCP"
      description    = "Output rule for port ${egress.value}"
      v4_cidr_blocks = ["0.0.0.0/0"]
      from_port      = egress.value
      to_port        = egress.value
    }
  }
}

## Default security group have ICMP access only
# resource "yandex_vpc_security_group" "sg-icmp-allow" {
#   name        = "sg-icmp-allow"
#   description = "allow ping"
#   network_id  = var.ya_cloud_network_id

#   labels = {
#     sg-access-type = "sg-icmp-allow"
#   }
#   # ICMP
#   ingress {
#     protocol       = "ICMP"
#     description    = "ICMP incomming"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     protocol       = "ICMP"
#     description    = "ICMP outgoing"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# <-- Networks.Security groups
