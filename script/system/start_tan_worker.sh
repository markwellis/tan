#!/bin/bash
source "$(dirname "$0")/use_perlbrew.sh"

cd /var/www/TAN
exec carton exec perl /var/www/TAN/script/workers/$1/$1.pl
