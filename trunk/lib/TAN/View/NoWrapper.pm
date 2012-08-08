package TAN::View::NoWrapper;
use strict;
use warnings;

use base 'TAN::View::TT';

__PACKAGE__->config(WRAPPER => '');

1;
