provider "yandex" {
  # service_account_key_file = "<path_to_key>/key.json" # for issue checking only!
  # token = "<your token>"
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}
