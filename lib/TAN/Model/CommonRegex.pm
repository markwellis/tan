package TAN::Model::CommonRegex;
use Moose;

extends 'Catalyst::Model';

has 'is_number' => (
    'is' => 'ro',
    'isa' => 'RegexpRef',
    'default' => sub { return qr/\d+/ },
);

has 'isnt_number' => (
    'is' => 'ro',
    'isa' => 'RegexpRef',
    'default' => sub { return qr/\D+/ },
);

has 'location' => (
    'is' => 'ro',
    'isa' => 'RegexpRef',
    'default' => sub { return qr/^link|blog|picture|poll$/ },
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
