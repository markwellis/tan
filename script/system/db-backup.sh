#!/bin/bash
source "$(dirname "$0")/backup_helper.sh"

DB='tan'
DBUSER='backupguy'
DBPASSWORD='FiewieJ0'

OUTPUT_DIR='/mnt/stuff/db_backups'

#filename = yyyy-mm-dd.sql
OUTPUT_FILENAME="${OUTPUT_DIR}/$(date --rfc-3339=date).sql.xz"

debug "creating backup"
mysqldump -u$DBUSER -p$DBPASSWORD --single-transaction --triggers $DB | xz > $OUTPUT_FILENAME

encrypt_file "${OUTPUT_FILENAME}"

exit 0;
