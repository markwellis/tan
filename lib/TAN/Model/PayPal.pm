package TAN::Model::PayPal;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

has 'email' => (
    'isa' => 'Str',
    'is' => 'ro',
    'required' => 1,
);

has 'username' => (
    'isa' => 'Str',
    'is' => 'ro',
    'required' => 1,
);

has 'password' => (
    'isa' => 'Str',
    'is' => 'ro',
    'required' => 1,
);

has 'signature' => (
    'isa' => 'Str',
    'is' => 'ro',
    'required' => 1,
);

has 'sandbox' => (
    'isa' => 'Num',
    'is' => 'ro',
    'required' => 1,
    'default' => 1,
);

__PACKAGE__->meta->make_immutable;
