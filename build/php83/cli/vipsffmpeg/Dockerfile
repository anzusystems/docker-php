#
# NOTE:
# THIS DOCKERFILE IS GENERATED VIA "update.sh".
# PLEASE DO NOT EDIT IT DIRECTLY!
# CHECK README FOR MORE INFO.
#
FROM php:8.3.16-cli

LABEL maintainer="Lubomir Stanko <lubomir.stanko@petitpress.sk>"

# ----------------------------------------------------------------------------------------------------------------------
# COMMON ENVIRONMENT VARIABLES
# ----------------------------------------------------------------------------------------------------------------------
# Building envs
ENV MAKEFLAGS="-j4"
# Common envs
ENV PROJECT_ROOT="/var/www/html"
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
    PHP_FFI_ENABLED="preload" \
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
    PROJECT_WEBROOT="${PROJECT_ROOT}/public" \
    XDEBUG_LOG="${PROJECT_ROOT}/xdebug.log"
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
    APT_SUPERVISOR_VERSION=$(apt-cache madison supervisor | awk -v ver="4.2.5" '$3 ~ ver {print $3; exit}') && \
    apt-get install -y \
        ${BUILD_DEPS} \
        ${PECL_BUILD_DEPS} \
        ${RUN_DEPS} \
        supervisor=${APT_SUPERVISOR_VERSION} && \
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
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install apcu-5.1.24 && \
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install mongodb-1.20.1 && \
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install pcov-1.0.12 && \
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install redis-6.1.0 && \
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install xdebug-3.4.1 && \
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
# COMPOSER
# ----------------------------------------------------------------------------------------------------------------------
RUN curl -sS https://getcomposer.org/installer | \
    php -- \
        --install-dir=/usr/local/bin \
        --filename=composer \
        --version=2.8.4

# ----------------------------------------------------------------------------------------------------------------------
# REDIS-TOOLS
# ----------------------------------------------------------------------------------------------------------------------
RUN DEBIAN_FRONTEND=noninteractive && \
    REDIS_KEYRING=/usr/share/keyrings/redis-archive-keyring.gpg && \
    REDIS_REPO="$(lsb_release -c -s)" && \
    curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o ${REDIS_KEYRING} && \
    echo "deb [signed-by=${REDIS_KEYRING}] https://packages.redis.io/deb ${REDIS_REPO} main" > /etc/apt/sources.list.d/redis.list && \
    apt-get update && \
    APT_REDIS_TOOLS_VERSION=$(apt-cache madison redis-tools | awk -v ver="7.2.4" '$3 ~ ver {print $3; exit}') && \
    apt-get install -y redis-tools=${APT_REDIS_TOOLS_VERSION} && \
# Cleanup
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

##<autogenerated>##
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# VIPS FFMPEG SETUP START
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ----------------------------------------------------------------------------------------------------------------------
# VIPS ENVIRONMENT VARIABLES
# Packages
ENV PHP_FFI_ENABLED=true
ENV VIPS_BUILD_DEPS="automake \
                    build-essential \
                    libexpat1-dev \
                    libfreetype6-dev \
                    libgirepository1.0-dev \
                    libglib2.0-dev \
                    libgsf-1-dev \
                    libjpeg-dev \
                    libjpeg62-turbo-dev \
                    libmagickwand-dev \
                    libmatio-dev \
                    libtiff5-dev \
                    libxml2-dev \
                    ninja-build \
                    pkg-config \
                    python3-mesonpy \
                    python3-setuptools \
                    python3-wheel"
ENV VIPS_RUN_DEPS="gobject-introspection \
                   gtk-doc-tools \
                   imagemagick \
                   jpegoptim \
                   libcfitsio-dev \
                   libcurl4-openssl-dev \
                   libexif-dev \
                   libffi8 \
                   libfftw3-dev \
                   libfile-mimeinfo-perl \
                   libgif-dev \
                   libgsf-1-114 \
                   libheif-dev \
                   libjpeg62-turbo \
                   libmatio11 \
                   libopenexr-3-1-30 \
                   libopenslide-dev \
                   liborc-0.4-dev \
                   libpango1.0-dev \
                   libpoppler-glib8 \
                   librsvg2-dev \
                   libturbojpeg0-dev \
                   libwebp-dev \
                   python3 \
                   python3-pip"

# ----------------------------------------------------------------------------------------------------------------------
# VIPS
# Dependency installation
RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y \
        ${VIPS_BUILD_DEPS} \
        ${VIPS_RUN_DEPS} && \
    docker-php-ext-configure ffi && \
    docker-php-ext-install -j$(nproc) \
        ffi && \
    cd /tmp && \
    wget -qc \
        https://github.com/libvips/libvips/releases/download/v8.16.0/vips-8.16.0.tar.xz \
        -O - | \
        tar -xJ && \
    cd vips-8.16.0 && \
    meson setup release --libdir=lib --buildtype=release && \
    cd release && \
    meson compile && \
    meson install && \
    cd ../.. && \
    rm -rf vips* && \
# Pecl Vips installation
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install vips-1.0.13 && \
    docker-php-ext-enable vips && \
    { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } && \
# Cleanup
    pecl clear-cache && \
    apt-get purge \
        -y --auto-remove \
        -o APT::AutoRemove::RecommendsImportant=false \
        ${VIPS_BUILD_DEPS} && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

# ----------------------------------------------------------------------------------------------------------------------
# FFMPEG
# Package installation
RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    APT_FFMPEG_VERSION=$(apt-cache madison ffmpeg | awk -v ver="5.1.6" '$3 ~ ver {print $3; exit}') && \
    apt-get install -y \
        ffmpeg=${APT_FFMPEG_VERSION} \
        libavcodec59=${APT_FFMPEG_VERSION} \
        libavdevice59=${APT_FFMPEG_VERSION} \
        libavfilter8=${APT_FFMPEG_VERSION} \
        libavformat59=${APT_FFMPEG_VERSION} \
        libswresample4=${APT_FFMPEG_VERSION} \
        libavutil57=${APT_FFMPEG_VERSION} \
        libpostproc56=${APT_FFMPEG_VERSION} \
        libswresample4=${APT_FFMPEG_VERSION} \
        libswscale6=${APT_FFMPEG_VERSION} && \
# Cleanup
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# VIPS FFMPEG SETUP END
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
WORKDIR ${PROJECT_ROOT}

ENTRYPOINT ["docker-entrypoint"]
