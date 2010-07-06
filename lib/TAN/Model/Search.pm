package TAN::Model::Search;

use strict;
use warnings;
use parent 'Catalyst::Model';

use KinoSearch::TAN;

=head1 NAME

TAN::Model::Search

=head1 DESCRIPTION

Interface to L<KinoSearch::TAN>

=head1 METHODS

=cut

=head2 COMPONENT

B<@args = undef>

=over

sets up Plucene

=back

=cut
sub COMPONENT {
    my ( $class, $c, $config ) = @_;

    return KinoSearch::TAN->new($config);
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
