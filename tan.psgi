use strict;
use warnings;
use Cwd 'abs_path';
use File::Basename;

use lib dirname( abs_path( $0 ) ) . '/lib';

use TAN;
my $app = TAN->apply_default_middlewares(TAN->psgi_app);

$app; 
