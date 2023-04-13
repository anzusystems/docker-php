# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# VIPS FFMPEG SETUP START
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ----------------------------------------------------------------------------------------------------------------------
# VIPS ENVIRONMENT VARIABLES
# Packages
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
                    pkg-config"
ENV PYTHON_BUILD_DEPS="meson \
                       setuptools \
                       wheel"
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
                  libwebp-dev \
                  python3 \
                  python3-pip"

# ----------------------------------------------------------------------------------------------------------------------
# VIPS
# Dependency installation
RUN apt-get update && \
    apt-get install -y \
        ${VIPS_BUILD_DEPS} \
        ${VIPS_RUN_DEPS} && \
    pip install -U \
        pip \
        ${PYTHON_BUILD_DEPS} && \
    cd /tmp && \
    wget -qc \
        https://github.com/libvips/libvips/releases/download/v${LIBVIPS_VERSION}/vips-${LIBVIPS_VERSION}.tar.xz \
        -O - | \
        tar -xJ && \
    cd vips-${LIBVIPS_VERSION} && \
    meson setup release --libdir=lib --buildtype=release && \
    cd release && \
    meson compile && \
    meson install && \
    cd ../.. && \
    rm -rf vips* && \
# Pecl Vips installation
    yes '' | MAKEFLAGS="-j$(($(nproc)+2))" pecl install vips-${PECL_VIPS_VERSION} && \
    docker-php-ext-enable vips && \
    { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } && \
# Cleanup
    pip uninstall -y \
        ${PYTHON_BUILD_DEPS} && \
    pip cache purge && \
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
# VIPS FFMPEG SETUP END
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
