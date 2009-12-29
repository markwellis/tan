#!/usr/bin/perl

use strict;
use warnings;
use Pod::Trac;

#does stuff to take the pod from TAN and inject it into trac

#########################
#  THIS IS NOT GOOD!    #
# Its a horrible module #
# and needs rewriting!  #
#########################

my $trac = Pod::Trac->new({
    'trac_url' => "http://trac.thisaintnews.com/thisaintnews",
    'login' => "pod_trac", 
    'passwd' => "Iek7Dohp",
});

$trac->from_path({
    'path' => "/srv/http/TAN/lib",
    'filter' => ["pm"],
});
