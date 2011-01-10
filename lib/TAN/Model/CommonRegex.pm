package TAN::Model::CommonRegex;
use Moose;

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

has 'location' => (
    'is' => 'ro',
    'isa' => 'RegexpRef',
    'default' => sub { return qr/^(?:link|blog|picture|poll)$/ },
);

no Moose;

=head1 NAME

TAN::Model::CommonRegex

=head1 DESCRIPTION

Commonly used regex

=head1 METHODS

=cut

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
