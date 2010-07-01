#!/usr/bin/perl
use strict;
use warnings;

use Linux::Inotify2;
use App::Daemon;
use Cwd;
use File::Path qw/mkpath/;
use Time::HiRes qw/time/;

App::Daemon::daemonize();

my $inotify = Linux::Inotify2->new();
my $cwd = Cwd::cwd();

mkpath('/tmp/tan_control');

my $lastrun;

$inotify->watch("/tmp/tan_control", IN_CREATE, sub{
    my ( $event ) = @_; 
    my $name = $event->name;

    if ( ($name eq 'sitemap_ping') && ( !$lastrun || (time - $lastrun) > 600 ) ){
#10 min limit
        #run sitemap pinger. this might be harassment, lolz
        do "${cwd}/sitemap_pinger.pl";
        $lastrun = time;
    }
    unlink( $event->fullname );
});

while(1){
    $inotify->poll;
}
