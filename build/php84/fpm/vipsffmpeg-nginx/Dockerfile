#
# NOTE:
# THIS DOCKERFILE IS GENERATED VIA "update.sh".
# PLEASE DO NOT EDIT IT DIRECTLY!
# CHECK README FOR MORE INFO.
#
FROM php:8.4.6-fpm

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
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install mongodb-2.0.0 && \
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install pcov-1.0.12 && \
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install redis-6.2.0 && \
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install xdebug-3.4.2 && \
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
        --version=2.8.8

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
        https://github.com/libvips/libvips/releases/download/v8.16.1/vips-8.16.1.tar.xz \
        -O - | \
        tar -xJ && \
    cd vips-8.16.1 && \
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
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# NGINX SETUP START
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ----------------------------------------------------------------------------------------------------------------------
# NGINX ENVIRONMENT VARIABLES
ENV NGINX_ACCESS_CONTROL_ALLOW_HEADERS="Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With,X-App-Version" \
    NGINX_ACCESS_LOG="/var/log/nginx/access.log main" \
    NGINX_ALLOWED_ORIGINS_REGEX="^https?://.*" \
    NGINX_CLIENT_BODY_BUFFER_SIZE=16k \
    NGINX_CLIENT_MAX_BODY_SIZE=1m \
    NGINX_CORS_CONFIG=true \
    NGINX_ERROR_LOG="/var/log/nginx/error.log warn" \
    NGINX_KEEPALIVE_REQUESTS=10000 \
    NGINX_KEEPALIVE_TIMEOUT=650 \
    NGINX_LARGE_CLIENT_HEADER_BUFFERS_SIZE=16k \
    NGINX_PHP_404_LOCATION_REGEX="\.php$" \
    NGINX_PHP_ACCESS_CONTROL_MAX_AGE=1728000 \
    NGINX_PHP_FASTCGI_BUFFER_SIZE=32K \
    NGINX_PHP_FASTCGI_CONNECT_TIMEOUT="60s" \
    NGINX_PHP_FASTCGI_READ_TIMEOUT="60s" \
    NGINX_PHP_FASTCGI_SEND_TIMEOUT="60s" \
    NGINX_PHP_FASTCGI_SPLIT_PATH_INFO="^(.+\.php)(/.*)$" \
    NGINX_PHP_LOCATION_REGEX="^/index\.php(/|$)" \
    NGINX_PHP_STRICT_TRANSPORT_SECURITY="max-age=31536000" \
    NGINX_PHP_X_ROBOTS_TAG="noindex, nofollow, noarchive, nosnippet" \
    NGINX_PORT=8080 \
    NGINX_SERVER_TOKENS="off" \
    NGINX_STATIC_ALLOWED_ORIGINS_REGEX="^https?://.*" \
    NGINX_STATIC_CACHE_CONTROL_HEADER="public, max-age=31557600, s-maxage=31557600" \
    NGINX_STATIC_LOCATION_REGEX="\.(gif|ico|css|js|svg|png|jpg|jpeg|bmp|eot|webp|woff|woff2|ttf|otf)$" \
    NGINX_STATIC_X_ROBOTS_TAG="noindex, nofollow, noarchive, nosnippet" \
    NGINX_WORKER_CONNECTIONS=1024 \
    NGINX_WORKER_PROCESSES=1 \
    NGINX_WORKER_RLIMIT_NOFILE=65535 \
    NGINX_X_CONTENT_TYPE_OPTIONS="nosniff" \
    NGINX_X_XSS_PROTECTION="1; mode=block"

# ----------------------------------------------------------------------------------------------------------------------
# NGINX
RUN DEBIAN_FRONTEND=noninteractive && \
    NGINX_KEYRING=/usr/share/keyrings/nginx-archive-keyring.gpg && \
    NGINX_REPO="$(lsb_release -c -s) nginx" && \
    curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o ${NGINX_KEYRING} && \
    echo "deb [signed-by=${NGINX_KEYRING}] http://nginx.org/packages/debian ${NGINX_REPO}" > /etc/apt/sources.list.d/nginx.list && \
    apt-get update && \
    APT_NGINX_VERSION=$(apt-cache madison nginx | awk -v ver="1.26.3" '$3 ~ ver {print $3; exit}') && \
    APT_NGINX_MODULE_GEOIP_VERSION=$(apt-cache madison nginx-module-geoip | awk -v ver="1.26.3" '$3 ~ ver {print $3; exit}') && \
    APT_NGINX_MODULE_IMAGE_FILTER_VERSION=$(apt-cache madison nginx-module-image-filter | awk -v ver="1.26.3" '$3 ~ ver {print $3; exit}') && \
    APT_NGINX_MODULE_NJS_VERSION=$(apt-cache madison nginx-module-njs | awk -v ver="1.26.3" '$3 ~ ver {print $3; exit}') && \
    APT_NGINX_MODULE_XSLT_VERSION=$(apt-cache madison nginx-module-xslt | awk -v ver="1.26.3" '$3 ~ ver {print $3; exit}') && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        nginx=${APT_NGINX_VERSION} \
        nginx-module-geoip=${APT_NGINX_MODULE_GEOIP_VERSION} \
        nginx-module-image-filter=${APT_NGINX_MODULE_IMAGE_FILTER_VERSION} \
        nginx-module-njs=${APT_NGINX_MODULE_NJS_VERSION} \
        nginx-module-xslt=${APT_NGINX_MODULE_XSLT_VERSION} && \
# Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------------------------------------------------
# NGINX LOGGING AND USER SETUP
# Create PID folders and forward nginx logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# NGINX SETUP END
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
