#!/bin/bash
source "$(dirname "$0")/backup_helper.sh"

OUTPUT_DIR="/mnt/stuff/backups"
OUTPUT_FILENAME="${OUTPUT_DIR}/$(date --rfc-3339=date).tar.xz"
BIND_MOUNTPOINT="/mnt/backup"

debug "bind mounting /"
mkdir -p $BIND_MOUNTPOINT
mount -o bind / $BIND_MOUNTPOINT

debug "creating tarball"
cd $BIND_MOUNTPOINT
tar -cJpf $OUTPUT_FILENAME . --exclude "mnt/*" --exclude "tmp/*" --exclude "usr/tmp/*" --exclude "var/tmp/*" --exclude "var/cache/apt/archives/*" --exclude "var/lib/varnish/*" --exclude "var/lib/mysql/*"

debug "unmounting bind mount"
cd /
umount $BIND_MOUNTPOINT

exit 0;
