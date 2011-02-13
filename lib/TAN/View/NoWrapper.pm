package TAN::View::NoWrapper;
use Moose;
use namespace::autoclean;

extends 'TAN::View::Perl';

__PACKAGE__->config(
    'wrapper' => '',
);

__PACKAGE__->meta->make_immutable;
