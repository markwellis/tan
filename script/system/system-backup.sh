#!/bin/bash

OUTPUT_DIR="/mnt/stuff/backups"
OUTPUT_FILENAME="${OUTPUT_DIR}/$(date --rfc-3339=date).tar.xz"
BIND_MOUNTPOINT="/mnt/backup"

function debug(){
    if [ $DEBUG ]; then
        echo -e "\e[01;31m$@\e[00m"
    fi
}

debug "bind mounting /"
mkdir -p $BIND_MOUNTPOINT
mount -o bind / $BIND_MOUNTPOINT

debug "creating tarball"
cd $BIND_MOUNTPOINT
tar -cJpf $OUTPUT_FILENAME . --exclude "mnt/*" --exclude "tmp/*" --exclude "usr/tmp/*" --exclude "var/tmp/*" --exclude "var/cache/apt/archives/*" --exclude "var/lib/varnish/*" --exclude "var/lib/mysql/*"

debug "creating sha512sum"
sha512sum -b $OUTPUT_FILENAME > $OUTPUT_FILENAME.sha512sum

debug "unmounting bind mount"
umount $BIND_MOUNTPOINT
