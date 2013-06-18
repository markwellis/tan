package TAN::Model::Email;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Factory';

__PACKAGE__->config( class => 'Mail::Builder::Simple' );

__PACKAGE__->meta->make_immutable;
