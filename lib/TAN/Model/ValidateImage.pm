package TAN::Model::ValidateImage;

use strict;
use warnings;
use parent 'Catalyst::Model';

use Data::Validate::Image;

sub COMPONENT{
    my ($self, $c, @config) = @_;

    return new Data::Validate::Image(@config);
}

1;
