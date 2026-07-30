## --> NAT
output "nt-main-outgoing-nat-id" {
  description = "main-outgoing-nat ID"
  value       = yandex_vpc_gateway.main-outgoing-nat.id
}
## <-- NAT

## --> Route tables
output "rt-otus-routes-id" {
  description = "Route table otus-routes ID"
  value       = yandex_vpc_route_table.otus-routes.id
}
## <-- Route tables

## --> Network subnets
output "sb-subnet-main-id" {
  description = "subnet-main ID"
  value       = yandex_vpc_subnet.subnet-main.id
}
## <-- Network subnets

## --> DNS zone
# --> otus-internal
output "yandex_dns_zone" {
  description = "DNS zone"
  value       = yandex_dns_zone.otus-internal.zone
}
output "yandex_dns_zone_id" {
  description = "DNS Zone ID"
  value       = yandex_dns_zone.otus-internal.id
}
# <-- otus-internal
## <-- DNS zone

## --> Security groups
output "sg-default-id" {
  value = yandex_vpc_security_group.sg-default.id
}
output "sg-server-postgre-internal-id" {
  value = yandex_vpc_security_group.sg-server-postgre-internal.id
}
output "sg-ssh-only-id" {
  value = yandex_vpc_security_group.sg-ssh-only.id
}
# output "sg-smb-id" {
#   value = yandex_vpc_security_group.sg-smb.id
# }
output "sg-allow-all-id" {
  value = yandex_vpc_security_group.sg-allow-all.id
}
output "sg-front-id" {
  value = yandex_vpc_security_group.sg-front.id
}
output "sg-nexus-id" {
  value = yandex_vpc_security_group.sg-nexus.id
}
output "sg-alloy-id" {
  value = yandex_vpc_security_group.sg-alloy.id
}
output "sg-obs-server-id" {
  value = yandex_vpc_security_group.sg-obs-server.id
}
# output "sg-icmp-allow-id" {
#   value = yandex_vpc_security_group.sg-icmp-allow.id
# }
## <-- Security groups

## --> Instances
# --> srv-front-001
output "internal_ip_srv-front-001" {
  value = yandex_compute_instance.srv-front-001.network_interface.0.ip_address
}
output "external_ip_srv-front-001" {
  value = yandex_compute_instance.srv-front-001.network_interface.0.nat_ip_address
}
output "srv-front-001-id" {
  value = yandex_compute_instance.srv-front-001.id
}
output "srv-front-001-hostname" {
  value = yandex_compute_instance.srv-front-001.hostname
}
output "srv-front-001-fqdn" {
  value = yandex_compute_instance.srv-front-001.fqdn
}
output "srv-front-001-zone" {
  value = yandex_compute_instance.srv-front-001.zone
  sensitive = true
}
# <-- srv-front-001
# --> srv-nexus
output "internal_ip_srv-nexus" {
  value = yandex_compute_instance.srv-nexus.network_interface.0.ip_address
}
output "external_ip_srv-nexus" {
  value = yandex_compute_instance.srv-nexus.network_interface.0.nat_ip_address
}
output "srv-nexus-id" {
  value = yandex_compute_instance.srv-nexus.id
}
output "srv-nexus-hostname" {
  value = yandex_compute_instance.srv-nexus.hostname
}
output "srv-nexus-fqdn" {
  value = yandex_compute_instance.srv-nexus.fqdn
}
output "srv-nexus-zone" {
  value = yandex_compute_instance.srv-nexus.zone
  sensitive = true
}
# <-- srv-nexus
# --> srv-obs
output "internal_ip_srv-obs" {
  value = yandex_compute_instance.srv-obs.network_interface.0.ip_address
}
output "external_ip_srv-obs" {
  value = yandex_compute_instance.srv-obs.network_interface.0.nat_ip_address
}
output "srv-obs-id" {
  value = yandex_compute_instance.srv-obs.id
}
output "srv-obs-hostname" {
  value = yandex_compute_instance.srv-obs.hostname
}
output "srv-obs-fqdn" {
  value = yandex_compute_instance.srv-obs.fqdn
}
output "srv-obs-zone" {
  value = yandex_compute_instance.srv-obs.zone
  sensitive = true
}
# <-- srv-obs
# --> srv-pg
output "internal_ip_srv-pg" {
  value = yandex_compute_instance.srv-pg.network_interface.0.ip_address
}
output "external_ip_srv-pg" {
  value = yandex_compute_instance.srv-pg.network_interface.0.nat_ip_address
}
output "srv-pg-id" {
  value = yandex_compute_instance.srv-pg.id
}
output "srv-pg-hostname" {
  value = yandex_compute_instance.srv-pg.hostname
}
output "srv-pg-fqdn" {
  value = yandex_compute_instance.srv-pg.fqdn
}
output "srv-pg-zone" {
  value = yandex_compute_instance.srv-pg.zone
  sensitive = true
}
# <-- srv-pg
# --> srv-pg-replica
output "internal_ip_srv-pg-replica" {
  value = yandex_compute_instance.srv-pg-replica.network_interface.0.ip_address
}
output "external_ip_srv-pg-replica" {
  value = yandex_compute_instance.srv-pg-replica.network_interface.0.nat_ip_address
}
output "srv-pg-replica-id" {
  value = yandex_compute_instance.srv-pg-replica.id
}
output "srv-pg-replica-hostname" {
  value = yandex_compute_instance.srv-pg-replica.hostname
}
output "srv-pg-replica-fqdn" {
  value = yandex_compute_instance.srv-pg-replica.fqdn
}
output "srv-pg-replica-zone" {
  value = yandex_compute_instance.srv-pg-replica.zone
  sensitive = true
}
# <-- srv-pg-replica
## <-- Instances
