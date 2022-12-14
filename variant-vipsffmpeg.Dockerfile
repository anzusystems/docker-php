# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# VIPS SETUP START
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ----------------------------------------------------------------------------------------------------------------------
# VIPS ENVIRONMENT VARIABLES
# Packages
ENV VIPS_BUILD_DEPS="automake \
                    build-essential \
                    libexpat1-dev \
                    libfreetype6-dev \
                    libglib2.0-dev \
                    libgsf-1-dev \
                    libjpeg-dev \
                    libjpeg62-turbo-dev \
                    libmagickwand-dev \
                    libmatio-dev \
                    libtiff5-dev \
                    libxml2-dev \
                    pkg-config"
ENV VIPS_RUN_DEPS="fftw3-dev \
                  gobject-introspection \
                  gtk-doc-tools \
                  imagemagick \
                  jpegoptim \
                  libcfitsio-dev \
                  libcurl4-openssl-dev \
                  libexif-dev \
                  libgif-dev \
                  libgsf-1-114 \
                  libjpeg62-turbo \
                  libmatio11 \
                  liborc-0.4-dev \
                  libopenexr25 \
                  libopenslide-dev \
                  libpango1.0-dev \
                  libpoppler-glib8 \
                  librsvg2-dev \
                  libturbojpeg0-dev \
                  libwebp-dev"

# ----------------------------------------------------------------------------------------------------------------------
# VIPS
# Dependency installation
RUN apt-get update && \
    apt-get install -y \
        ${VIPS_BUILD_DEPS} \
        ${VIPS_RUN_DEPS} && \
    cd /tmp && \
    wget -q \
        https://github.com/libvips/libvips/releases/download/v${LIBVIPS_VERSION}/vips-${LIBVIPS_VERSION}.tar.gz \
        -O vips.tar.gz && \
    tar xvzf vips.tar.gz && \
    cd vips-${LIBVIPS_VERSION} && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf vips* && \
# Pecl Vips installation
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install vips-${PECL_VIPS_VERSION} && \
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
RUN apt-get update && \
    apt-get install -y \
        ffmpeg=${FFMPEG_PRE_RELEASE}:${FFMPEG_VERSION}-${FFMPEG_PKG_RELEASE} \
        libavcodec58=${FFMPEG_PRE_RELEASE}:${FFMPEG_VERSION}-${FFMPEG_PKG_RELEASE} \
        libavdevice58=${FFMPEG_PRE_RELEASE}:${FFMPEG_VERSION}-${FFMPEG_PKG_RELEASE} \
        libavfilter7=${FFMPEG_PRE_RELEASE}:${FFMPEG_VERSION}-${FFMPEG_PKG_RELEASE} \
        libavformat58=${FFMPEG_PRE_RELEASE}:${FFMPEG_VERSION}-${FFMPEG_PKG_RELEASE} \
        libavresample4=${FFMPEG_PRE_RELEASE}:${FFMPEG_VERSION}-${FFMPEG_PKG_RELEASE} \
        libavutil56=${FFMPEG_PRE_RELEASE}:${FFMPEG_VERSION}-${FFMPEG_PKG_RELEASE} \
        libpostproc55=${FFMPEG_PRE_RELEASE}:${FFMPEG_VERSION}-${FFMPEG_PKG_RELEASE} \
        libswresample3=${FFMPEG_PRE_RELEASE}:${FFMPEG_VERSION}-${FFMPEG_PKG_RELEASE} \
        libswscale5=${FFMPEG_PRE_RELEASE}:${FFMPEG_VERSION}-${FFMPEG_PKG_RELEASE} && \
# Cleanup
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# VIPS SETUP END
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
