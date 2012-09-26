package TAN::Model::Submit::Module;

use Moose::Role;
use Exception::Simple;

has 'config' => (
    'is' => 'ro',
    'isa' => 'HashRef',
    'builder' => '_build_config',
);

requires '_build_config';

sub prepare{
    my ( $self, $c, $params, $validator_return_values ) = @_;

    my $prepared = {};
#we don't do much to prepare, just build the hash ready for db insert
    foreach my $key ( keys( %{$self->config->{'schema'}} ) ){
        next if ( $c->stash->{'edit'} && $self->config->{'schema'}->{ $key }->{'no_edit'} );

        $prepared->{ $key } = $params->{ $key };
    }

    return $prepared;
}

1;
