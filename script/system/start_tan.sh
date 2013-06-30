#!/bin/bash
source "$(dirname "$0")/use_perlbrew.sh"

#config
WORKERS=5
LISTEN=localhost:8081

if [ $DEVELOPMENT ]; then 
    export CATALYST_DEBUG=1
    export CATALYST_CONFIG_LOCAL_SUFFIX=devel
    WORKERS=1
fi;

exec starman --workers $WORKERS --l $LISTEN /var/www/TAN/tan.psgi
