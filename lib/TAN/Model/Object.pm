package TAN::Model::Object;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

has 'public' => (
    'isa' => 'ArrayRef',
    'is' => 'ro',
    'lazy_build' => 1,
);
sub _build_public{
    return [qw/link blog picture poll video forum/];
}

has 'private' => (
    'isa' => 'ArrayRef',
    'is' => 'ro',
    'lazy_build' => 1,
);
sub _build_private{
    return [qw/profile/];
}

__PACKAGE__->meta->make_immutable;
