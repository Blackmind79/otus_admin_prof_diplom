# Дипломная работа курса Administrator Linux. Professional

## О проекте

Дипломная работа курса Administrator Linux. Professional

## Источники

Инструкции и полезные источники:

- [Authentication thru service account](https://yandex.cloud/ru/docs/cli/operations/authentication/service-account)
- [Sonatype Nexus Docs](https://help.sonatype.com/en/sonatype-nexus-repository.html)
- [Sonatype Nexus dockerhub](https://hub.docker.com/r/sonatype/nexus3)
- [Databasus](https://databasus.com/advanced-config)

## Yandex Terraform

Для начала создайте файл провайдера `~/.terraformrc`, откуда будет проходить непосредственно запуск.

```text
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

Установите командную оболочку yc с сайта яндекса [Yandex CLI](https://yandex.cloud/ru/docs/cli/operations/install-cli).
Обновите консоль, т.к. при установке может быть не последняя версия `yc components update`.
Создайте отдельный профиль для работы с вашим облаком [Create profile](https://yandex.cloud/ru/docs/cli/operations/profile/profile-create).

Для начала посмотрите уже созданные профили `yc config profile list`. Далее создайте профиль:

```bash
yc config profile create otus_diplom
# если не активирован профиль
yc config profile activate otus_diplom
# настройте профиль
yc init --username=<электронная_почта>
```

Далее выгрузите сервисный ключ (скрипт `create_service_account_key.sh`) и добавьте его в конфиг.
Старайтесь не держать ключ в открытом виде! Защитите по максимуму либо удалите и храните только в конфиге.

## Перед запуском

Если вы не работаете в TF через ключ `key.json` (безопасно), то перед запуском загрузите данные из конфига в переменные сессии:

```bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

Terraform возьмет данные из переменных окружения. Имейте ввиду. что время жизни токена 12 часов!
Либо задайте в `provider.tf` параметр `service_account_key_file="<path_to_key>/key.json"` (менее безопасно).

Создайте S3-бакет для хранения данных (заранее определите имя бакета и класс):

```bash
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
```

## Проверка и запуск создания ресурсов

Для проверки и запуска развертывания серверов, перейдите в каталог `terraform` и запустите и

```bash
terraform init -upgrade -backend-config=.backend
terraform validate
terraform plan -var-file=.tfvars
terraform apply -var-file=.tfvars
```

## DNS зона

В текущей конфигурации зона DNS создается автоматически в TF.
Также зону вы можете создать руками, но имейте ввиду, что IP адреса выдаются случайным образом в подсети.

```bash
yc dns zone create \
  --name otus-internal-dns-zone \
  --description Otus internal DNS zone \
  --zone <название зоны> \
  --private-visibility=true \
  --network-ids <ID вашей сети>
```

где <название зоны> - название домена для VM

## Информация о модулях

### Версия Terraform Provider

Последнюю версию можно посмотреть в официальном репозитории [terraform-provider-yandex](https://github.com/yandex-cloud/terraform-provider-yandex). Значение версии провайдера устанавливается в `main.tf`.

### Ubuntu 26.04

Идентификаторы продукта:

```text
Продукт: f2eksu9515viqg7mk4is
Версия продукта: f2e9936niidanbtm1b2u
Образ ВМ: fd8u10mhsprdmr9rotp4
Семейство образа: ubuntu-2604-lts
```

## Скрипты

### Создание сервисного аккаунта и получение ключа

Привожу пример скрипта для создания сервисного аккаунта

```bash
#!/usr/bin/env bash

set -euo pipefail

SERVICE_ACCOUNT_NAME=<имя вашего создаваемого сервисного аккаунта>
FOLDER_ID=<id вашего каталога>

# Создание папки для хранения ключа (можно сразу удалить ключ после записи в конфиг)
FLD_NAME="./ENV"
mkdir -p "${FLD_NAME}"
chmod -R 700 "${FLD_NAME}"

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
```

### Создание S3 бакета

Создание S3 бакета в Яндекс Облаке

```bash
#!/usr/bin/env bash

set -euo pipefail

SERVICE_ACCOUNT_NAME=<имя вашего создаваемого сервисного аккаунта>
FOLDER_ID=<id вашего каталога>

S3_BUCKET_NAME=s3-otus
S3_STORAGE_CLASS=standard

# Создать S3-бакет (50Gb, standard)
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
```

## Разное

### Fail2ban

Документация: [Crazy-max Fail2ban](https://github.com/crazy-max/docker-fail2ban).

Контейнер, поднятый на VM с обратным прокси для контроля попыток входа из сети интернет.
В базовом варианте настроено на бан попыток подбора входа по ssh.
Можно настроить на любой порт, если есть логи о попытке подключения.

Проверка работы:

```bash
docker exec -it fail2ban fail2ban-client status
docker exec -it fail2ban fail2ban-client status --all
```

В поле `Jail list` будут отображены все ваши сконфигурированные "тюрьмы".

Забаненные IP:

```bash
docker exec -it fail2ban fail2ban-client banned
```

Забанить IP вручную ибо задолбал(`JAIL` - название "тюрьмы", `IP` - ip-адрес для блокировки):

```bash
docker exec -it fail2ban fail2ban-client set <JAIL> banip <IP>
```

Посмотреть конкретную "тюрьму" (в примере sshd):

```bash
docker exec -it fail2ban fail2ban-client status sshd
```

Разбанить IP-адреса

```bash
# один IP в указанной тюрьме
docker exec -it fail2ban fail2ban-client set <JAIL> unbanip <IP>
```
