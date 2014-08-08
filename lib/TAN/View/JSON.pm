package TAN::View::JSON;
use strict;
use warnings;

use parent qw/Catalyst::View::JSON/;

sub encode_json {
    my( $self, $c, $data ) = @_;

    $c->model('JSON')->encode( $data );
}

1;
