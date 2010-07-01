#!/usr/bin/perl
use strict;
use warnings;

use Linux::Inotify2;
use App::Daemon;
use File::Path qw/mkpath/;
use Time::HiRes qw/time/;
use File::Basename;

App::Daemon::daemonize();

my $inotify = Linux::Inotify2->new();
my $cwd = Cwd::cwd();

mkpath('/tmp/tan_control');

my $lastrun;
my $script_dir = dirname($0);

$inotify->watch("/tmp/tan_control", IN_CREATE, sub{
    my ( $event ) = @_; 
    my $name = $event->name;

    if ( ($name eq 'sitemap_ping') && ( !$lastrun || (time - $lastrun) > 600 ) ){
#10 min limit
        #run sitemap pinger. this might be harassment, lolz
        do "${script_dir}/sitemap_pinger.pl";
        $lastrun = time;
    }
    unlink( $event->fullname );
});

while(1){
    $inotify->poll;
}
