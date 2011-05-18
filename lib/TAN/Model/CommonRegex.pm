package TAN::Model::CommonRegex;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

has 'int' => (
    'is' => 'ro',
    'isa' => 'RegexpRef',
    'default' => sub { return qr/\d+/ },
);

has 'not_int' => (
    'is' => 'ro',
    'isa' => 'RegexpRef',
    'default' => sub { return qr/\D+/ },
);

has 'alpha_numeric' => (
    'is' => 'ro',
    'isa' => 'RegexpRef',
    'default' => sub { return qr/[a-zA-Z0-9]/ },
);

has 'not_alpha_numeric' => (
    'is' => 'ro',
    'isa' => 'RegexpRef',
    'default' => sub { return qr/[^a-zA-Z0-9]/ },
);

has 'type' => (
    'is' => 'ro',
    'isa' => 'RegexpRef',
    'default' => sub { return qr/^(?:link|blog|picture|poll|video)$/ },
);

has 'trim' => (
    'is' => 'ro',
    'isa' => 'RegexpRef',
    'default' => sub { return qr/^\s+|\s+$/ },
);

__PACKAGE__->meta->make_immutable;
