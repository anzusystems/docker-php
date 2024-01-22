#
# NOTE:
# THIS DOCKERFILE IS GENERATED VIA "update.sh".
# PLEASE DO NOT EDIT IT DIRECTLY!
# CHECK README FOR MORE INFO.
#
FROM php:8.3.2-cli

LABEL maintainer="Lubomir Stanko <lubomir.stanko@petitpress.sk>"

# ----------------------------------------------------------------------------------------------------------------------
# COMMON ENVIRONMENT VARIABLES
# ----------------------------------------------------------------------------------------------------------------------
# Building envs
ENV MAKEFLAGS="-j4"
# Php
# Php error reporting constants https://www.php.net/manual/en/errorfunc.constants.php
# Calculate the number for config on https://maximivanov.github.io/php-error-reporting-calculator/
# error_reporting = "E_ALL & ~E_STRICT & ~E_DEPRECATED & ~E_USER_DEPRECATED" => 6143
ENV PHP_DATE_TIMEZONE="UTC" \
    PHP_ACCESS_LOG_FORMAT="%R - %u %t \"%m %r\" %s path:%{REQUEST_URI}e pid:%p took:%ds mem:%{mega}Mmb cpu:%C%% status:%s {%{REMOTE_ADDR}e|%{HTTP_USER_AGENT}e}" \
    PHP_ACCESS_LOG="/proc/self/fd/2" \
    PHP_DISPLAY_ERRORS=0 \
    PHP_DISPLAY_STARTUP_ERRORS=0 \
    PHP_ERROR_LOG="/proc/self/fd/2" \
    PHP_ERROR_REPORTING=6143 \
    PHP_EXPOSE_PHP=0 \
    PHP_LOG_LEVEL="notice" \
    PHP_MAX_EXECUTION_TIME=30 \
    PHP_MEMORY_LIMIT="256M" \
    PHP_OPCACHE_CLI_ENABLE=0 \
    PHP_OPCACHE_ENABLE=1 \
    PHP_OPCACHE_ERROR_LOG="/proc/self/fd/2" \
    PHP_OPCACHE_INTERNED_STRINGS_BUFFER=32 \
    PHP_OPCACHE_LOG_VERBOSITY_LEVEL=1 \
    PHP_OPCACHE_MAX_ACCELERATED_FILES=32531 \
    PHP_OPCACHE_MEMORY_CONSUMPTION=256 \
    PHP_OPCACHE_PRELOAD_PATH="" \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_POST_MAX_SIZE="0M"\
    PHP_SESSION_COOKIE_SAMESITE="" \
    PHP_SESSION_COOKIE_SECURE="" \
    PHP_SESSION_SAVE_HANDLER="files" \
    PHP_SESSION_SAVE_PATH="/tmp" \
    PHP_SLOW_LOG="/proc/self/fd/2" \
    PHP_UPLOAD_MAX_FILESIZE="20M" \
    PHP_VARIABLES_ORDER="GPCS" \
    XDEBUG_LOG="/var/www/html/xdebug.log"
# Composer
ENV COMPOSER_HOME="/composer" \
    PATH="/composer/vendor/bin:$PATH"
# Packages
ENV BUILD_DEPS="build-essential \
                libicu-dev \
                libjpeg-dev \
                libxml2-dev \
                libzip-dev"
ENV PECL_BUILD_DEPS="libcurl4-openssl-dev \
                     libssl-dev"
ENV RUN_DEPS="ca-certificates \
              cron \
              curl \
              g++ \
              gcc \
              gettext-base \
              git \
              gnupg \
              less \
              libpng-dev \
              libjpeg62-turbo \
              libzip4 \
              logrotate \
              lsb-release \
              lsof \
              lz4 \
              make \
              nano \
              openssh-client \
              procps \
              screen \
              unzip \
              vim \
              wget \
              zip"

# ----------------------------------------------------------------------------------------------------------------------
# PHP
# Initialization with PHP installation
# ----------------------------------------------------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y \
        ${BUILD_DEPS} \
        ${PECL_BUILD_DEPS} \
        ${RUN_DEPS} \
        supervisor=4.2.5-1 && \
    docker-php-ext-configure intl && \
    docker-php-ext-configure opcache && \
    docker-php-ext-configure pcntl --enable-pcntl && \
    docker-php-ext-configure pdo_mysql && \
    docker-php-ext-configure zip && \
    docker-php-ext-install -j$(nproc) \
        intl \
        opcache \
        pcntl \
        pdo_mysql \
        zip && \
    apt-get purge \
        -y --auto-remove \
        -o APT::AutoRemove::RecommendsImportant=false \
        ${BUILD_DEPS} \
        ${PECL_BUILD_DEPS} && \
# Cleanup
    apt-get clean && \
    rm -r /var/lib/apt/lists/* && \
    rm -f /usr/local/etc/php-fpm.d/docker.conf && \
    rm -f /usr/local/etc/php-fpm.d/zz-docker.conf

# ----------------------------------------------------------------------------------------------------------------------
# PECL PACKAGES
# ----------------------------------------------------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y \
        ${PECL_BUILD_DEPS} && \
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install apcu-5.1.23 && \
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install mongodb-1.17.2 && \
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install pcov-1.0.11 && \
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install redis-6.0.2 && \
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install xdebug-3.3.1 && \
    docker-php-ext-enable \
        apcu \
        mongodb \
        pcov \
        redis \
        xdebug && \
    { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } && \
    pecl clear-cache && \
    rm -rf /tmp/pear && \
    apt-get purge \
        -y --auto-remove \
        -o APT::AutoRemove::RecommendsImportant=false \
        ${PECL_BUILD_DEPS} && \
# Cleanup
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

# ----------------------------------------------------------------------------------------------------------------------
# PHP SECURITY CHECKER
# ----------------------------------------------------------------------------------------------------------------------
# Php Security Checker binary package setup
RUN wget -q \
        https://github.com/fabpot/local-php-security-checker/releases/download/v2.0.6/local-php-security-checker_2.0.6_linux_amd64 \
        -O /usr/local/bin/local-php-security-checker && \
    chmod +x /usr/local/bin/local-php-security-checker

# ----------------------------------------------------------------------------------------------------------------------
# COMPOSER
# ----------------------------------------------------------------------------------------------------------------------
RUN curl -sS https://getcomposer.org/installer | \
    php -- \
        --install-dir=/usr/local/bin \
        --filename=composer \
        --version=2.6.6

# ----------------------------------------------------------------------------------------------------------------------
# REDIS-TOOLS
# ----------------------------------------------------------------------------------------------------------------------
RUN DEBIAN_FRONTEND=noninteractive && \
    REDIS_KEYRING=/usr/share/keyrings/redis-archive-keyring.gpg && \
    REDIS_REPO="$(lsb_release -c -s)" && \
    curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o ${REDIS_KEYRING} && \
    echo "deb [signed-by=${REDIS_KEYRING}] https://packages.redis.io/deb ${REDIS_REPO} main" > /etc/apt/sources.list.d/redis.list && \
    apt-get update && \
    apt-get install -y redis-tools=6:6.2.13-1rl1~bookworm1 && \
# Cleanup
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

##<autogenerated>##
##</autogenerated>##

# ----------------------------------------------------------------------------------------------------------------------
# RUN CONFIGURATION
# ----------------------------------------------------------------------------------------------------------------------
COPY ./etc /etc
COPY ./usr /usr

# ----------------------------------------------------------------------------------------------------------------------
# RUN
# Run setup and entrypoint start
# ----------------------------------------------------------------------------------------------------------------------
WORKDIR /var/www/html

ENTRYPOINT ["docker-entrypoint"]
