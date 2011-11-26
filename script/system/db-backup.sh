#!/bin/bash
DB='tan'
DBUSER='backupguy'
DBPASSWORD='FiewieJ0'

OUTPUT_DIR='/mnt/stuff/db_backups'

#filename = yyyy-mm-dd.sql || yyyy-mm.sql.master
OUTPUT_FILENAME="${OUTPUT_DIR}/$(date --rfc-3339=date).sql"
MASTER_FILENAME="${OUTPUT_DIR}/$(date '+%Y-%m').sql.master"

function debug(){
    if [ $DEBUG ]; then
        echo -e "\e[01;31m$@\e[00m"
    fi
}

#figure out if the .master file exists for this month
if [ ! -f "${MASTER_FILENAME}" ]; then
    IS_MASTER=1
fi

debug "creating backup"
mysqldump -u$DBUSER -p$DBPASSWORD --single-transaction $DB > $OUTPUT_FILENAME

if [ $IS_MASTER ]; then
    debug "moving file to master file"
    mv $OUTPUT_FILENAME $MASTER_FILENAME
    exit
fi

debug "creating diff"
diff -Naur $MASTER_FILENAME $OUTPUT_FILENAME > $OUTPUT_FILENAME.diff

debug "removing none diff backup file"
rm $OUTPUT_FILENAME

debug "compressing diff"
xz $OUTPUT_FILENAME.diff
