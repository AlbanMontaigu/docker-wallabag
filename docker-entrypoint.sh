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

# Wallabag method to do the upgrade !
# @see http://doc.wallabag.org/fr/Administrateur/maj_wallabag.html
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] Installing or upgrading wallabag in $(pwd) - copying now..."
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] Checking if this is and upgrade"
wb_upgrade=0
if [ -f ./index.php ] 
then
    wb_upgrade=1
fi
echo >&2 "[INFO] wb_upgrade = $wb_upgrade"
echo >&2 "[INFO] Syncing your installation with rsync and last source"
rsync -urv /usr/src/wallabag/* .
echo >&2 "[INFO] Removing cache"
rm -rvf cache/*
echo >&2 "[INFO] If upgrade, will remove the install directory (if not you won't see remove log)"
if [ $wb_upgrade -eq 1 ]
then
     rm -rvf ./install
fi
echo >&2 "[INFO] Fixing rights"
chown -Rfv nginx:nginx .
echo >&2 "[INFO] Complete! wallabag has been successfully installed / upgraded to $(pwd)"

# Exec main command
exec "$@"
