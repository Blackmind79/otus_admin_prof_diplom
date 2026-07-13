## --> Security groups
output "sg-server-postgre-internal" {
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
# output "sg-icmp-allow-id" {
#   value = yandex_vpc_security_group.sg-icmp-allow.id
# }
## <-- Security groups

# ## --> Instances
# # --> srv-front-001
# output "internal_ip_srv-front-001" {
#   value = yandex_compute_instance.srv-front-001.network_interface.0.ip_address
# }
# output "external_ip_srv-front-001" {
#   value = yandex_compute_instance.srv-front-001.network_interface.0.nat_ip_address
# }
# output "srv-front-001-id" {
#   value = yandex_compute_instance.srv-front-001.id
# }
# output "srv-front-001-hostname" {
#   value = yandex_compute_instance.srv-front-001.hostname
# }
# output "srv-front-001-fqdn" {
#   value = yandex_compute_instance.srv-front-001.fqdn
# }
# output "srv-front-001-zone" {
#   value = yandex_compute_instance.srv-front-001.zone
# }
# # <-- srv-front-001
# ## <-- Instances

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
