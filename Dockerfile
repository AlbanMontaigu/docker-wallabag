# ================================================================================================================
#
# Wallabag with NGINX and PHP-FPM
#
# @see https://github.com/AlbanMontaigu/docker-nginx-php-plus
# @see https://github.com/AlbanMontaigu/docker-dokuwiki
# ================================================================================================================

# Base is a nginx install with php
FROM amontaigu/nginx-php-plus:5.6.14

# Maintainer
MAINTAINER alban.montaigu@gmail.com

# Wallabag env variables
ENV WALLABAG_VERSION="1.9.1"

# System update & install the PHP extensions we need
RUN apt-get update \
    && apt-get install -y rsync libtidy-0.99-0 libtidy-dev unzip \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install tidy

# Get Wallabag and install it
RUN mkdir -p --mode=777 /var/backup/wallabag \
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

# Entrypoint to enable live customization
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Volume for wallabag backup
VOLUME /var/backup/wallabag

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord"]
