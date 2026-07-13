#!/usr/bin/env bash

set -euo pipefail

# Читаем данные
. ./.env

# Создание папки для хранения ключа (можно сразу удалить ключ после записи в конфиг)
FLD_NAME="./ENV"
mkdir -p "${FLD_NAME}"
chmod 700 -R "${FLD_NAME}"

# Создание сервисного аккаунта
yc iam service-account create --name "${SERVICE_ACCOUNT_NAME}"

# Назначение роли admin(или editor и resource-manager.admin для S3)
yc resource-manager folder add-access-binding \
  --id "${FOLDER_ID}" \
  --role admin \
  --service-account-name "${SERVICE_ACCOUNT_NAME}"

# Создание авторизованного ключа
yc iam key create \
  --service-account-name "${SERVICE_ACCOUNT_NAME}" \
  --folder-id "${FOLDER_ID}" \
  --output "${FLD_NAME}/key.json"

# Запись ключа в текущий активный конфиг
yc config set service-account-key "${FLD_NAME}/key.json"

# Убедитесь, что параметры для сервисного аккаунта добавлены верно:
yc config list

# Удалите ключ, если нужно
#rm -f "${FLD_NAME}/key.json"
