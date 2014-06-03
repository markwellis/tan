#!/bin/bash
source "$(dirname "$0")/use_perlbrew.sh"

LISTEN=localhost:8081

exec plackup -s Starlet -l $LISTEN --max-workers 40 --no-default-middleware /var/www/TAN/tan.psgi
