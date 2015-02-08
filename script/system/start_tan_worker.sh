#!/bin/bash
source "$(dirname "$0")/use_perlbrew.sh"

exec carton exec -cpanfile /var/www/TAN/cpanfile perl /var/www/TAN/script/workers/$1/$1.pl
