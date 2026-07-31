# Ansible block

## О каталоге

Ниже приведена информация по особенностям развертывания сервисов на VM.

## Замеченные баги

### Развертывание drupal

По непонятное причине после развертывания сайта не применяются права `www-data` на папку сайтов.
Даже с учетом того, что применяются права в entrypoint.

Вероятно после развертывания идут еще какие-то процессы, которые запускаются от root.
Баг выражается в ошибке сохранения фото или других файлов в текст.

После запуска контейнера на всякий случай проведите повторно назначение прав на папки (на srv-front):

```bash
sudo docker exec -it portfolio chown -R www-data:www-data /var/www/html/sites
sudo docker exec -it portfolio find /var/www/html/sites -type d -exec chmod 755 {} \;
sudo docker exec -it portfolio find /var/www/html/sites -type f -exec chmod 644 {} \;
```

Файлы находятся в томе, так что это разовая операция

## Предварительные действия перед развертыванием

Создайте два файла `.vault.pwd` и `.vault.notenc` по их примерам `.vault.pwd.example` и `.vault.notenc.example` соответственно.
Зашифруйте хранилище, как описано ниже.

Если вы работаете над проектом с кем-либо и вам нужно хранить креды в репозитории, то можете передать
полученный файл `.vault.enc`. И только ваши коллеги, который знают пароль `.vault.pwd` смогут деплоить.

## Шифрование секретов

Для шифрования секретов введите

```bash
ansible-vault encrypt .vault.notenc --output .vault.enc --vault-password-file .vault.pwd
```

## Структура плейбуков

Playbook        | Описание
----------------|---------
playbook_global | Установка базовых пакетов и мониторинг на все хосты
playbook_front  | Установка фронта и CMS
playbook_nexus  | Установка репозитория и приложения бэкапа
playbook_obs    | Установка Observability
playbook_pg     | Установка и настройка PostgreSQL (primary и standby)

> **Важно!**
> 
> Установку CMS проводить ПОСЛЕ настройки PostgreSQL, так как на сервере БД крутится её база

> **Примечание**
>
> *playbook_nexus* устанавливает приложения для хранения репозиториев, а также приложение для управления бэкапами баз.
> Так как образы для работы в ansible уже закачаны туда, то уничтожение VM с ними потребует заново перезалить образы.
> Аналогично для *postgresus* - к сожалению он не настраивается через скрипты, поэтому удаление его базы также
> приведет к очистке всех данных и конфигов внутри.

Соответственно запуск плейбуков:

```bash
ansible-playbook playbooks/playbook_global.yaml --vault-password-file=.vault.pwd
```

Или точечно:

```bash
ansible-playbook playbooks/playbook_front.yaml --vault-password-file=.vault.pwd
```

## Пакеты

Используются пакеты:

```bash
ansible-galaxy collection install community.general
ansible-galaxy collection install community.postgresql
```

## Важное дополнение

При установке ubuntu 24.04 в ранних билдах было замечено, что по-умолчанию открыт доступ по паролю!
Обязательно проверьте файл `/etc/ssh/sshd_config.d/50-cloud-init.conf`. Содержимое файла должно быть:

```text
PasswordAuthentication no
```

## Репликация

Источники:

- [Ansible Replica](https://opensource-db.com/pg18-hacktober-31-days-of-new-features-ansible-based-installation-replication)
- [PostgreSQL](https://www.postgresql.org/download/linux/ubuntu)

Посмотреть на primary слоты репликации

```bash
sudo -u postgres psql -c "SELECT * FROM pg_replication_slots;"
sudo -u postgres psql -c "SELECT slot_name, active, restart_lsn, wal_status FROM pg_replication_slots;" -t -A -F ','
```

Удаление слота репликации на primary, если был сбой при создании реплики

```bash
sudo -u postgres psql -c "SELECT pg_drop_replication_slot('standby_slot_{{ inventory_hostname }}');"
```

## NSF папка бэкапов

На VM `srv-nexus.internal.net` развернут репозиторий `Nexus`, приложение архивирование Postgresql баз `Databasus`, а также NFS папка.

Настройки на сервер NFS лежат в `ansible/group_vars/all.yaml`.
Если нужно - укажите другой сервер в переменных и перенесите код настройки
сервера NFS на другой сервер (из `playbook_nexus.yml`).

```bash
nfs_global_server: "srv-nexus.internal.net"
nfs_global_share: "/srv/nfs/backup"
nfs_global_version: "4.2"
nfs_client_mount_point: "/mnt/remote_backup"
nfs_client_cidr: "10.130.0.0/24"
```

Посмотреть открытые папка NFS на сервере:

```bash
# Ресурсы
exportfs -v

# Упрощенно
showmount -e localhost

# Работа самого сервиса
systemctl status nfs-kernel-server

# Если интересны RPC сервисы
rpcinfo -p
```

Проверка на клиенте:

```bash
## NFS4
rpcinfo -p srv-nexus.internal.net

## NFS3: showmount -e <IP_NFS_SERVER>
#showmount -e srv-nexus.internal.net
```
