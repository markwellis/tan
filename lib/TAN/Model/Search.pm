package TAN::Model::Search;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'LucyX::Simple' );

__PACKAGE__->meta->make_immutable;
