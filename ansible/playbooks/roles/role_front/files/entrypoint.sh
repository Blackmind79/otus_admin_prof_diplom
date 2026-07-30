#!/bin/bash
set -e

# one-time install
if [ ! -f /var/www/html/sites/default/settings.php ]; then
    echo "One-time install drush and site with defined credentials:"
    composer require --no-interaction drush/drush

    /opt/drupal/vendor/bin/drush site:install standard \
      --db-url="pgsql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${PG_HOST}:${POSTGRES_DB_PORT}/${POSTGRES_DB}" \
      --account-name="${DRUPAL_ADMIN_USER}" \
      --account-pass="${DRUPAL_ADMIN_PASSWORD}" \
      --account-mail="${DRUPAL_ADMIN_EMAIL}" \
      --site-name="${DRUPAL_SITE_NAME}" \
      --yes

    echo "Enabling multilingual modules..."
    /opt/drupal/vendor/bin/drush en language locale content_translation config_translation -y

    echo "Adding Russian language..."
    /opt/drupal/vendor/bin/drush language:add ru
    /opt/drupal/vendor/bin/drush config:set system.site default_langcode ru -y

    # echo "Add admin GIN theme..."
    # composer require --no-interaction 'drupal/gin:^5.0'
    # /opt/drupal/vendor/bin/drush en gin_toolbar -y

    echo "Setting correct file permissions..."
    # Create folder for upload files
    mkdir -p /var/www/html/sites/default/files
    # Set owner: www-data
    chown -R www-data:www-data /var/www/html/sites
    # Set rights
    find /var/www/html/sites -type d -exec chmod 755 {} \;
    find /var/www/html/sites -type f -exec chmod 644 {} \;

    echo "Clear drupal cache for applying changes..."
    /opt/drupal/vendor/bin/drush cr
fi

echo "Starting..."

if [ "$#" -eq 0 ]; then
    set -- apache2-foreground
fi

echo "ARGS: $@"

exec /usr/local/bin/docker-php-entrypoint "$@"