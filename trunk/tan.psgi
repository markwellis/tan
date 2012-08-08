use strict;
use warnings;

use TAN;

my $app = TAN->apply_default_middlewares(TAN->psgi_app);
$app;
