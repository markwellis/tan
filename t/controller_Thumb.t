use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'TAN' }
BEGIN { use_ok 'TAN::Controller::Thumb' }

ok( request('/thumb')->is_success, 'Request should succeed' );


