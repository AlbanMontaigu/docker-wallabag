# ================================================================================================================
#
# Wallabag with NGINX and PHP-FPM
#
# @see https://github.com/AlbanMontaigu/docker-nginx-php/blob/master/Dockerfile
# @see https://github.com/AlbanMontaigu/docker-dokuwiki
# ================================================================================================================

# Base is a nginx install with php
FROM amontaigu/nginx-php

# Maintainer
MAINTAINER alban.montaigu@gmail.com

# Wallabag env variables
ENV WALLABAG_VERSION="1.9"

# System update & install the PHP extensions we need
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y libpng12-dev libjpeg-dev rsync tidy unzip && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install tidy \
    && docker-php-ext-install gettext

# Get Wallabag and install it
RUN mkdir -p --mode=777 /var/local/backup/wallabag \
    && mkdir -p --mode=777 /usr/src/wallabag \
    && curl -o wallabag.tgz -SL https://github.com/wallabag/wallabag/archive/$WALLABAG_VERSION.tar.gz \
    && tar -xzf wallabag.tgz --strip-components=1 -C /usr/src/wallabag \
        --exclude=.gitignore \
        --exclude=CONTRIBUTING.md \
        --exclude=CREDITS.md \
        --exclude=README.md \
        --exclude=Vagrantfile \
        --exclude=composer.lock \
        --exclude=docs \
        --exclude=COPYING.md \
        --exclude=GUIDELINES.md \
        --exclude=TRANSLATION.md \
        --exclude=composer.json \
    && rm wallabag.tgz \
    && curl -o vendor.zip -SL http://static.wallabag.org/files/vendor.zip \
    && unzip vendor.zip -d /usr/src/wallabag \
    && rm vendor.zip \
    && chown -R nginx:nginx /usr/src/wallabag

# NGINX tuning for WALLABAG
COPY ./nginx/conf/sites-enabled/default.conf /etc/nginx/sites-enabled/default.conf

# Entrypoint to enable live customization
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Volume for wallabag backup
VOLUME /var/local/backup/wallabag

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord"]
