package TAN::Model::Stemmer;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'Lingua::Stem::Snowball' );

sub mangle_arguments {
    my ( $self, $args ) = @_;

    return %$args; # now the args are a plain list
}

__PACKAGE__->meta->make_immutable;
