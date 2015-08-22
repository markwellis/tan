#!/bin/bash
source ~/perl5/perlbrew/etc/bashrc

LISTEN=0.0.0.0:8081

exec carton exec -- plackup -E production -s Gazelle -l $LISTEN --max-workers 20 --no-default-middleware tan.psgi
