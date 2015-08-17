#!/bin/bash
source ~/perl5/perlbrew/etc/bashrc

LISTEN=localhost:8081

exec carton exec -- plackup -E production -s Gazelle -l $LISTEN --max-workers 40 --no-default-middleware tan.psgi
