USER=thisaint
SERVER=thisaintnews.pl

SOURCE=/mnt/stuff
DESTINATION=/homez.365/thisaint/www/backups/tan
BACKUP_DIRS="tan trac svn backups"

LOCK_FILE=/tmp/backup-sync

ARGS="-aze ssh --delete"
if [ $VERBOSE ]; then
    ARGS="${ARGS} -v"
fi

(
    if flock -n 88; then
        for DIR in $BACKUP_DIRS; do
            rsync $ARGS $SOURCE/$DIR $USER@$SERVER:$DESTINATION/$DIR
        done;
    fi
) 88 > $LOCK_FILE
