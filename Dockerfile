FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get update && apt-get install -y \
    nginx \
    php8.1-fpm \
    php8.1-mysql \
    php8.1-gd \
    php8.1-xml \
    php8.1-mbstring \
    php8.1-curl \
    php8.1-zip \
    curl \
    wget \
    unzip \
    php-redis\
    git \
    cron \
    nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add your cron job file
ADD cronjob /etc/cron.d/cronjob

# Give execute permissions to the cron job
RUN chmod 0644 /etc/cron.d/cronjob

# Apply cron job file
RUN crontab /etc/cron.d/cronjob
RUN mkdir -p /var/tmp/nginx && mkdir -p /var/cache/nginx  && mkdir -p /config/sync
RUN cron
RUN chown -R www-data:www-data /var/www/html \
    && chown -R www-data:www-data /run

RUN chown -R www-data:www-data /config/sync /etc/nginx/ /var/log/nginx/ /var/cache/nginx/ /var/www/html/ /var/lib/nginx /var/log

# Install Drupal, Composer, and Drush
RUN curl -s https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer && alias composer='/usr/local/bin/composer'
RUN cd /var/www/html && composer create-project drupal/recommended-project:^9 drupal
RUN cd /var/www/html && chown -R www-data:www-data drupal && cd drupal && composer require 'drush/drush:^11.0' 'aws/aws-sdk-php:~3.0'
RUN curl -OL https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar && chmod +x drush.phar && mv drush.phar /usr/local/bin/drush
    
# Copy Nginx configuration
COPY drupal.conf /etc/nginx/sites-available/drupal.conf
RUN ln -s /etc/nginx/sites-available/drupal.conf /etc/nginx/sites-enabled/ && rm /etc/nginx/sites-enabled/default
RUN chown www-data:www-data -R /var/www/html/drupal

USER www-data
COPY cloudfront_purger.settings.yml /tpm/cloudfront_purger.settings.yml
WORKDIR /var/www/html/drupal
COPY entry.sh /scripts/entry.sh
RUN rm -rf vendor/ && composer install
CMD ["bash", "-c", "/etc/init.d/php8.1-fpm start ; /etc/init.d/nginx start ; tail -f /var/log/nginx/error.log"]