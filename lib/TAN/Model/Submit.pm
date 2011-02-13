package TAN::Model::Submit;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'TAN::Submit' );

__PACKAGE__->meta->make_immutable;
