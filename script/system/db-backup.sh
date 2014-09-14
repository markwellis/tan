#!/bin/bash
source "$(dirname "$0")/backup_helper.sh"

DB='tan'
DBUSER='backupguy'
DBPASSWORD='FiewieJ0'

OUTPUT_DIR='/mnt/stuff/db_backups'

#filename = yyyy-mm-dd.sql
OUTPUT_FILENAME="${OUTPUT_DIR}/$(date --rfc-3339=date).sql"

debug "dumping schema"
mysqldump -u$DBUSER -p$DBPASSWORD --single-transaction --no-data --skip-triggers --skip-add-drop-table $DB > $OUTPUT_FILENAME

debug "dumping data"
mysqldump -u$DBUSER -p$DBPASSWORD --single-transaction --no-create-info --skip-triggers --ignore-table=$DB.views $DB >> $OUTPUT_FILENAME

debug "dumping triggers"
mysqldump -u$DBUSER -p$DBPASSWORD --single-transaction --no-create-info --no-data --triggers $DB >> $OUTPUT_FILENAME

debug "compressing"
#xz $OUTPUT_FILENAME

exit 0;
