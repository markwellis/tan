#!/bin/bash
source "$(dirname "$0")/use_perlbrew.sh"

LISTEN=localhost:8081

exec carton -cpanfile /var/www/TAN/cpanfile exec plackup -E production -s Gazelle -l $LISTEN --max-workers 40 --no-default-middleware /var/www/TAN/tan.psgi
