package TAN::Model::Search;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Factory::PerRequest';

__PACKAGE__->config( class => 'KinoSearchX::Simple' );

__PACKAGE__->meta->make_immutable;
