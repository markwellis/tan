#!/bin/bash
source "$(dirname "$0")/use_perlbrew.sh"

exec carton install perl /var/www/TAN/script/workers/$1/$1.pl
