drush -y si --db-url=$DATABASE_URL --account-pass=$ADM_PASS
composer require 'drupal/redis:^1.6' 'drupal/cdn:^4.0' 'drupal/cloudfront_purger:^2.0' 'aws/aws-sdk-php:~3.0' 'drupal/purge_queuer_url:^1.0' drush/drush:"^11.0" 'drupal/purge:^3.4'
drush -y en redis cdn cdn_ui cloudfront_purger purge_tokens purge_ui  purge_processor_cron purge_processor_lateruntime purge_drush purge_queuer_url purge_queuer_coretags
drush -y ppadd cloudfront
drush -y cset cdn.settings mapping.type simple
drush -y cset cdn.settings mapping.domain $DOMAIN
drush -y cset cdn.settings farfuture.status true
drush -y cset cdn.settings status true
drush -y cset purge_queuer_url.settings queue_paths true
drush -y pm:uninstall page_cache
drush -y cset system.performance cache.page.max_age 31536000
chmod 777 /var/www/html/drupal/web/sites/default/settings.php
echo -e "\$settings['config_sync_directory'] = '/config/sync';" >> /var/www/html/drupal/web/sites/default/settings.php
drush -y cex
cp /tpm/cloudfront_purger.settings.yml /config/sync/
drush -y cim
drush -y config-set cloudfront_purger.settings distribution_id $DISTRIBUTION_ID
echo -e "\$settings['redis.connection']['interface'] = 'PhpRedis';" >> /var/www/html/drupal/web/sites/default/settings.php
echo -e "\$settings['redis.connection']['host'] = '$REDIS_HOST';" >> /var/www/html/drupal/web/sites/default/settings.php
echo -e "\$settings['redis.connection']['port'] = '6379';" >> /var/www/html/drupal/web/sites/default/settings.php
echo -e "\$settings['cache']['default'] = 'cache.backend.redis';" >> /var/www/html/drupal/web/sites/default/settings.php
chmod 444 /var/www/html/drupal/web/sites/default/settings.php

cp -prR /var/www/html/drupal/web/sites/* /mnt/sites
cp -prR /var/www/html/drupal/web/modules/* /mnt/modules
cp -prR /config/sync/* /mnt/config
drush cr