ARG PHP_VERSION=7.4
ARG XDEBUG_VERSION=2.9.6

#####################################
##               PHP               ##
#####################################
FROM php:${PHP_VERSION}-apache AS php

# Install dependencies for the operating system software
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libicu-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    libzip-dev \
    unzip \
    git \
    libonig-dev \
    curl \
    # Clean aptitude cache and tmp directory
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install the PHP extensions
RUN docker-php-ext-configure intl \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j "$(nproc)" \
        gd \
        pcntl \
        intl \
        opcache \
        pdo_mysql \
        mbstring \
        exif \
        zip \
    && docker-php-ext-enable \
        opcache \
    && docker-php-source delete \
    # Clean aptitude cache and tmp directory
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# configure apache document root as per the image documentation in addition rewrite header
ENV APP_HOME /var/www/html
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Use the PORT environment variable in Apache configuration files.
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

RUN a2enmod rewrite headers

#####################################
##              ASSETS             ##
#####################################
FROM php AS assets-builder

WORKDIR /var/www/html
COPY . ./

# Install composer (php package manager)
COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN composer install

#####################################
##              PROD               ##
#####################################
FROM php AS release

ARG APP_ENV
ENV APP_ENV ${APP_ENV:-production}

ARG APP_DEBUG
ENV APP_DEBUG ${APP_DEBUG:-false}

ARG LOG_LEVEL
ENV LOG_LEVEL ${LOG_LEVEL:-info}

# Configure PHP for Cloud Run.
RUN set -ex; \
  { \
    echo "; Cloud Run enforces memory & timeouts"; \
    echo "memory_limit = -1"; \
    echo "max_execution_time = 0"; \
    echo "; File upload at Cloud Run network limit"; \
    echo "upload_max_filesize = 32M"; \
    echo "post_max_size = 32M"; \
    echo "; Configure Opcache for Containers"; \
    echo "opcache.enable = On"; \
    echo "opcache.validate_timestamps = Off"; \
    echo "; Configure Opcache Memory (Application-specific)"; \
    echo "opcache.memory_consumption = 32"; \
  } > "$PHP_INI_DIR/conf.d/cloud-run.ini"

# Switch to the production php.ini for production operations.
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
# https://github.com/docker-library/docs/blob/master/php/README.md#configuration
# RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

COPY --from=assets-builder --chown=www-data /var/www/html /var/www/html
WORKDIR /var/www/html

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN composer install \
        --ignore-platform-reqs \
        --no-ansi \
        # --no-dev \ # TODO: allow to have a stage for dev
        --no-interaction

RUN composer dump-autoload

# Change the group ownership of the storage and bootstrap/cache directories to www-data
# Recursively grant all permissions, including write and execute, to the group
RUN chgrp -R www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R ug+rwx /var/www/html/storage /var/www/html/bootstrap/cache

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# start php-fpm server (for FastCGI Process Manager)
ENTRYPOINT ["entrypoint.sh"]