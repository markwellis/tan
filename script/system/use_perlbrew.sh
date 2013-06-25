#use perlbrew perl
export PERLBREW_ROOT=/mnt/stuff/perl
export PERLBREW_HOME=/mnt/stuff/perl/.perlbrew
export SHELL=bash

source /mnt/stuff/perl/etc/bashrc 

if [ $(hostname) == 'tandev' ]; then 
    export PERL5LIB="/mnt/stuff/perl_modules/data-validate-image/lib:/mnt/stuff/perl_modules/exception-simple/lib:/mnt/stuff/perl_modules/fetch-image/lib:/mnt/stuff/perl_modules/gearmanx-simple/lib:/mnt/stuff/perl_modules/html-video-embed/lib:/mnt/stuff/perl_modules/lucyx-simple/lib:$PERL5LIB"
    DEVELOPMENT=1
fi
