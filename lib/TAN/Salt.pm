package TAN::Salt;
use strict;
use warnings;
use Math::Random::Secure qw/irand/;

sub salt{
    return unpack( 'H*', join "", ('.', '/', '_', '+', '-', '=', 0..9, 'A'..'Z', 'a'..'z')[map {irand(64)} (1..512)] );
}

1;
