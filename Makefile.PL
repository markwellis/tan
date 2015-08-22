#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;

name 'TAN';
version_from 'lib/TAN.pm';
author 'Mark Ellis <m@rkellis.com>';
license license "restricted";
#authenitcation 
#template toolkit 

#install_script glob('script/*.pl');
auto_install;

makemaker_args(
    dist => {
        COMPRESS    => 'gzip -9', #size is not an issue, but speed is
    },
    MAN1PODS    => {}, #disable manifaction
    MAN3PODS    => {},
);

WriteAll;
