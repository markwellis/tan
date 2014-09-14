#!/bin/bash
source "$(dirname "$0")/backup_helper.sh"

DB='tan'
DBUSER='backupguy'
DBPASSWORD='FiewieJ0'

OUTPUT_DIR='/mnt/stuff/db_backups'

#filename = yyyy-mm-dd.sql
OUTPUT_FILENAME="${OUTPUT_DIR}/$(date --rfc-3339=date).sql"

debug "creating backup"
mysqldump -u$DBUSER -p$DBPASSWORD --single-transaction --triggers --no-data $DB > $OUTPUT_FILENAME
mysqldump -u$DBUSER -p$DBPASSWORD --single-transaction --no-create-info --ignore-table=$DB.views $DB >> $OUTPUT_FILENAME
xz $OUTPUT_FILENAME

exit 0;
