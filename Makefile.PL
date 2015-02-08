#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;

name 'TAN';
all_from 'lib/TAN.pm';

#authenitcation 
#template toolkit 

#install_script glob('script/*.pl');
auto_install;
WriteAll;
