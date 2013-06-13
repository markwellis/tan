#!/bin/bash

#use perlbrew perl
export PERLBREW_ROOT=/mnt/stuff/perl
export PERLBREW_HOME=/mnt/stuff/perl/.perlbrew

source /mnt/stuff/perl/etc/bashrc 

#config
WORKERS=5
USER=tan
GROUP=$USER
LISTEN=localhost:8081
ERROR_LOG=/var/log/tan.log

if [ $(hostname) == 'tandev' ]; then 
    export PERL5LIB="/mnt/stuff/perl_modules/data-validate-image/lib:/mnt/stuff/perl_modules/exception-simple/lib:/mnt/stuff/perl_modules/fetch-image/lib:/mnt/stuff/perl_modules/gearmanx-simple/lib:/mnt/stuff/perl_modules/html-video-embed/lib:/mnt/stuff/perl_modules/lucyx-simple/lib"
    export CATALYST_DEBUG=1
    WORKERS=1
fi;

#start tan (use exec (don't daemonize!) so upstart gets the right pid)
exec starman --user $USER --group $GROUP --workers $WORKERS --l $LISTEN --error-log $ERROR_LOG /var/www/TAN/tan.psgi
