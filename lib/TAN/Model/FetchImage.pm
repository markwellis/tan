package TAN::Model::FetchImage;

use strict;
use warnings;
use parent 'Catalyst::Model';

use Fetch::Image;

sub COMPONENT{
    my ($self, $c, @config) = @_;

    return new Fetch::Image(@config);
}

1;
