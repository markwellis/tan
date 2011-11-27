USER=thisaint
SERVER=thisaintnews.pl

SOURCE=/mnt/stuff
DESTINATION=/homez.365/thisaint/www/backups/tan
BACKUP_DIRS="TAN/user trac svn backups db_backups"

LOCK_FILE=/tmp/backup-sync

#some parts stolen from http://blog.iangreenleaf.com/2009/03/rsync-and-retrying-until-we-get-it.html
trap "echo Exited!; exit;" SIGINT SIGTERM

MAX_RETRIES=3

ARGS="-az --partial -e ssh"
if [ $VERBOSE ]; then
    ARGS="${ARGS} -v"
fi

(
    if flock -n 88; then
        for DIR in $BACKUP_DIRS; do
            # Set the initial return value to failure
            i=0
            false
            while [ $? -ne 0 -a $i -lt $MAX_RETRIES ]; do
                i=$(($i+1))
                rsync $ARGS $SOURCE/$DIR $USER@$SERVER:$DESTINATION
            done
        done;
    fi
) 88>$LOCK_FILE
