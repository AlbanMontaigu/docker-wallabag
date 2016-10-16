#!/bin/bash
set -e

# Who and where am I ?
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] GLOBAL INFORMATIONS"
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] whoami : $(whoami)"
echo >&2 "[INFO] pwd : $(pwd)"

# Backup the prev install in case of fail...
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] Backup old wallabag installation in $(pwd)"
echo >&2 "[INFO] ---------------------------------------------------------------"
tar -zcvf /var/backup/wallabag/wallabag-v$(date '+%Y%m%d%H%M%S').tar.gz .
echo >&2 "[INFO] Complete! Backup successfully done in $(pwd)"

# Wallabag upgrade
# @see http://doc.wallabag.org/en/master/user/upgrade-2.0.x-2.1.1.html
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] Installing or upgrading wallabag in $(pwd)"
echo >&2 "[INFO] ---------------------------------------------------------------"

# Backup of parameters
echo >&2 "[INFO] Backup app/config/parameters.yml"
mv -vf app/config/parameters.yml /tmp/parameters.yml

# Removing old files except data
echo >&2 "[INFO] Removing old installation"
find -maxdepth 1 ! -regex '^\./data.*$' ! -regex '^\.$' -exec rm -rvf {} +

# Extracting new files
echo >&2 "[INFO] Extracting new installation"
tar cvf - --one-file-system -C /usr/src/wallabag . | tar xvf -

# Restore parameters
echo >&2 "[INFO] Restore app/config/parameters.yml"
mv -vf /tmp/parameters.yml app/config/parameters.yml

# Rights correction
echo >&2 "[INFO] Fixing rights"
chown -Rfv nginx:nginx .

# Done
echo >&2 "[INFO] Complete! Wallabag has been successfully installed / upgraded to $(pwd)"

# Exec main command
exec "$@"
