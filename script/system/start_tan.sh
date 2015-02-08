#!/bin/bash
source "$(dirname "$0")/use_perlbrew.sh"

LISTEN=localhost:8081

cd /var/www/TAN
exec carton exec plackup -E production -s Gazelle -l $LISTEN --max-workers 40 --no-default-middleware tan.psgi
