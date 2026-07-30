# Ansible block

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
