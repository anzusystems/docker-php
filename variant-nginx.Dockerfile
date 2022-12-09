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
    NGINX_FASTCGI_CONNECT_TIMEOUT="60s" \
    NGINX_FASTCGI_READ_TIMEOUT="60s" \
    NGINX_FASTCGI_SEND_TIMEOUT="60s" \
    NGINX_KEEPALIVE_REQUESTS=10000 \
    NGINX_KEEPALIVE_TIMEOUT=650 \
    NGINX_LARGE_CLIENT_HEADER_BUFFERS_SIZE=16k \
    NGINX_PHP_ACCESS_CONTROL_MAX_AGE=1728000 \
    NGINX_PHP_FASTCGI_BUFFER_SIZE=32K \
    NGINX_PHP_LOCATION_REGEX="^/.+\.php(/|$)" \
    NGINX_PHP_STRICT_TRANSPORT_SECURITY="max-age=31536000" \
    NGINX_PHP_X_ROBOTS_TAG="noindex, nofollow, noarchive, nosnippet" \
    NGINX_PORT=8080 \
    NGINX_ROOT=/var/www/html/public \
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
# Inspiration taken from the official Nginx Dockerfile
RUN NGINX_GPGKEY=573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62; \
    found=''; \
    for server in \
        ha.pool.sks-keyservers.net \
        hkp://keyserver.ubuntu.com:80 \
        hkp://p80.pool.sks-keyservers.net:80 \
        pgp.mit.edu; \
    do \
        echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
        apt-key adv --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" && found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1; \
    echo "deb http://nginx.org/packages/debian $(lsb_release -cs) nginx" \
        | tee /etc/apt/sources.list.d/nginx.list && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        nginx=${NGINX_VERSION}-${NGINX_PKG_RELEASE} \
        nginx-module-xslt=${NGINX_VERSION}-${NGINX_PKG_RELEASE} \
        nginx-module-geoip=${NGINX_VERSION}-${NGINX_PKG_RELEASE} \
        nginx-module-image-filter=${NGINX_VERSION}-${NGINX_PKG_RELEASE} \
        nginx-module-njs=${NGINX_VERSION}+${NGINX_NJS_VERSION}-${NGINX_PKG_RELEASE} && \
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
