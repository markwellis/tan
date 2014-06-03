use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use TAN;
my $app = TAN->apply_default_middlewares( TAN->psgi_app );

$app;
