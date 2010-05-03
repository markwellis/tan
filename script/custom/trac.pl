#!/usr/bin/perl

use strict;
use warnings;
use Pod::Trac;
use Cwd 'abs_path';

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

my $cwd = abs_path();
$trac->from_path({
    'path' => "${cwd}/../../lib",
    'filter' => ["pm"],
});
