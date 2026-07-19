# Ansible block

## Шифрование секретов

Для шифрования секретов введите

```bash
ansible-vault encrypt .vault.notenc --output .vault.enc --vault-password-file .vault.pwd
```

## Структура плейбуков

Playbook | Описание
---------|---------
playbook_front | Установка фронта и CMS

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
```

## Важное дополнение

При установке ubuntu 24.04 в ранних билдах было замечено, что по-умолчанию открыт доступ по паролю!
Обязательно проверьте файл `/etc/ssh/sshd_config.d/50-cloud-init.conf`. Содержимое файла должно быть:

```text
PasswordAuthentication no
```
