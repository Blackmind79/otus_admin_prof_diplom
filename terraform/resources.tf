resource "yandex_compute_instance" "srv-front-001" {
  boot_disk {
    initialize_params {
      name       = var.vm_front_disk
      type       = "network-ssd"
      size       = 20
      block_size = 4096
      image_id   = var.ubuntu2604_image_id
    }
    auto_delete = true
  }
  folder_id          = var.folder_id
  hostname           = var.vm_front
  name               = var.vm_front
  zone               = var.zone

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-main.id
    security_group_ids = [
        yandex_vpc_security_group.sg-default.id,
        yandex_vpc_security_group.sg-ssh-only.id,
        yandex_vpc_security_group.sg-front.id,
        yandex_vpc_security_group.sg-server-postgre-internal.id,
        yandex_vpc_security_group.sg-alloy.id
    ]
    nat            = true
    nat_ip_address = var.reserved_external_ip[index(var.reserved_external_ip.*.name, "ip_001_web")].value
    dns_record {
      fqdn        = "${var.vm_front}"
      dns_zone_id = yandex_dns_zone.otus-internal.id
      ttl         = 600
    }
  }
  platform_id = "standard-v3"
  resources {
    memory        = 2
    cores         = 2
    core_fraction = 100
  }
  scheduling_policy {
    preemptible   = false
  }

  metadata = {
    enable-oslogin          = "false" # See [OS Login settings] part upper for enable=true
    serial-port-enable      = 0       # 1 - enable serial console, 0 - disable
    install-unified-agent   = 0
    user-data               = "${file("./usr.meta")}"
    private_ui_created_from = "console"
  }
}

# Nexus
resource "yandex_compute_instance" "srv-nexus" {
  boot_disk {
    initialize_params {
      name       = var.vm_nexus_disk
      # type       = "network-ssd"
      type       = "network-hdd"
      size       = 50
      block_size = 4096
      image_id   = var.ubuntu2604_image_id
    }
    auto_delete = true
  }
  folder_id          = var.folder_id
  hostname           = var.vm_nexus
  name               = var.vm_nexus
  zone               = var.zone

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-main.id
    security_group_ids = [
        yandex_vpc_security_group.sg-default.id,
        yandex_vpc_security_group.sg-ssh-only.id,
        yandex_vpc_security_group.sg-nexus.id,
        yandex_vpc_security_group.sg-alloy.id
    ]
    nat            = false
    dns_record {
      fqdn        = "${var.vm_nexus}"
      dns_zone_id = yandex_dns_zone.otus-internal.id
      ttl         = 600
    }
  }
  platform_id = "standard-v3"
  resources {
    memory        = 4
    cores         = 2
    core_fraction = 20
  }
  scheduling_policy {
    preemptible   = false
  }

  metadata = {
    enable-oslogin          = "false" # See [OS Login settings] part upper for enable=true
    serial-port-enable      = 0       # 1 - enable serial console, 0 - disable
    install-unified-agent   = 0
    user-data               = "${file("./usr.meta")}"
    private_ui_created_from = "console"
  }
}

# Observability
resource "yandex_compute_instance" "srv-obs" {
  boot_disk {
    initialize_params {
      name       = var.vm_obs_disk
      type       = "network-ssd"
      size       = 50
      block_size = 4096
      image_id   = var.ubuntu2604_image_id
    }
    auto_delete = true
  }
  folder_id          = var.folder_id
  hostname           = var.vm_obs
  name               = var.vm_obs
  zone               = var.zone

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-main.id
    security_group_ids = [
        yandex_vpc_security_group.sg-default.id,
        yandex_vpc_security_group.sg-ssh-only.id,
        yandex_vpc_security_group.sg-obs-server.id,
        yandex_vpc_security_group.sg-alloy.id
    ]
    nat            = false
    dns_record {
      fqdn        = "${var.vm_obs}"
      dns_zone_id = yandex_dns_zone.otus-internal.id
      ttl         = 600
    }
  }
  platform_id = "standard-v3"
  resources {
    memory        = 4
    cores         = 2
    core_fraction = 100
  }
  scheduling_policy {
    preemptible   = false
  }

  metadata = {
    enable-oslogin          = "false" # See [OS Login settings] part upper for enable=true
    serial-port-enable      = 0       # 1 - enable serial console, 0 - disable
    install-unified-agent   = 0
    user-data               = "${file("./usr.meta")}"
    private_ui_created_from = "console"
  }
}

# Postgres Master
resource "yandex_compute_instance" "srv-pg" {
  boot_disk {
    initialize_params {
      name       = var.vm_pg_disk
      type       = "network-ssd"
      size       = 40
      block_size = 4096
      image_id   = var.ubuntu2604_image_id
    }
    auto_delete = true
  }
  folder_id          = var.folder_id
  hostname           = var.vm_pg
  name               = var.vm_pg
  zone               = var.zone

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-main.id
    security_group_ids = [
        yandex_vpc_security_group.sg-default.id,
        yandex_vpc_security_group.sg-ssh-only.id,
        yandex_vpc_security_group.sg-server-postgre-internal.id,
        yandex_vpc_security_group.sg-alloy.id
    ]
    nat            = false
    dns_record {
      fqdn        = "${var.vm_pg}"
      dns_zone_id = yandex_dns_zone.otus-internal.id
      ttl         = 600
    }
  }
  platform_id = "standard-v3"
  resources {
    memory        = 4
    cores         = 2
    core_fraction = 20
  }
  scheduling_policy {
    preemptible   = false
  }

  metadata = {
    enable-oslogin          = "false" # See [OS Login settings] part upper for enable=true
    serial-port-enable      = 0       # 1 - enable serial console, 0 - disable
    install-unified-agent   = 0
    user-data               = "${file("./usr.meta")}"
    private_ui_created_from = "console"
  }
}

# Postgres Replica
resource "yandex_compute_instance" "srv-pg-replica" {
  boot_disk {
    initialize_params {
      name       = var.vm_pg_replica_disk
      type       = "network-ssd"
      size       = 40
      block_size = 4096
      image_id   = var.ubuntu2604_image_id
    }
    auto_delete = true
  }
  folder_id          = var.folder_id
  hostname           = var.vm_pg_replica
  name               = var.vm_pg_replica
  zone               = var.zone

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-main.id
    security_group_ids = [
        yandex_vpc_security_group.sg-default.id,
        yandex_vpc_security_group.sg-ssh-only.id,
        yandex_vpc_security_group.sg-server-postgre-internal.id,
        yandex_vpc_security_group.sg-alloy.id
    ]
    nat            = false
    dns_record {
      fqdn        = "${var.vm_pg_replica}"
      dns_zone_id = yandex_dns_zone.otus-internal.id
      ttl         = 600
    }
  }
  platform_id = "standard-v3"
  resources {
    memory        = 4
    cores         = 2
    core_fraction = 20
  }
  scheduling_policy {
    preemptible   = false
  }

  metadata = {
    enable-oslogin          = "false" # See [OS Login settings] part upper for enable=true
    serial-port-enable      = 0       # 1 - enable serial console, 0 - disable
    install-unified-agent   = 0
    user-data               = "${file("./usr.meta")}"
    private_ui_created_from = "console"
  }
}
