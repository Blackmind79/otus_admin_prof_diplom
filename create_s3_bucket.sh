#!/usr/bin/env bash

set -euo pipefail

# Читаем данные
. ./.env

S3_BUCKET_NAME=s3-otus
S3_STORAGE_CLASS=standard

# Создать S3-бакет (50Gb, standart)
yc storage bucket create \
  --name "${S3_BUCKET_NAME}" \
  --default-storage-class "${S3_STORAGE_CLASS}" \
  --max-size 53687091200 \
  --public-read=false \
  --public-list=false \
  --public-config-read=false

# Назначение прав на каталог
yc resource-manager folder add-access-binding "${FOLDER_ID}" \
  --role storage.uploader \
  --service-account-name "${SERVICE_ACCOUNT_NAME}"

# Генерация статического ключа доступа (запишите полученные key_id и secret например в файл .backend)
yc iam access-key create --service-account-name "${SERVICE_ACCOUNT_NAME}"