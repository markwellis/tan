package TAN::Model::JSON;
use strict;
use warnings;

use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config(
    class   => 'JSON::MaybeXS',
    args    =>  {
        utf8            => 1,
        allow_nonref    => 1,
        allow_blessed   => 1,
        convert_blessed => 1,
    },
);

sub prepare_arguments {
    #we need just the parts from self->config->{args}, not the rest of the
    #stuff that will get mixed in (catalyst_component_name,args,class etc)
    return $_[0]->config->{args};
}

1;
