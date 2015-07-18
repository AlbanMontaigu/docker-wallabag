#!/bin/bash
set -e

# Backup the prev install in case of fail...
tar -zcf wallabag-v$(date '+%y%m%d%H%M%S').tar.gz /var/local/backup/wallabag

# Wallabag method to do the upgrade !
# @see http://doc.wallabag.org/fr/Administrateur/maj_wallabag.html
echo >&2 "Installing or upgrading wallabag in $(pwd) - copying now..."
rsync -ur /usr/src/wallabag/* /var/www/
rm -rf cache/*
chown -R nginx:nginx *
echo >&2 "Complete! wallabag has been successfully installed / upgraded to $(pwd)"

# Exec main command
exec "$@"
