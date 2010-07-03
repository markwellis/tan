package TAN::Model::Search;

use strict;
use warnings;
use parent 'Catalyst::Model';

use Plucene::Simple;

=head1 NAME

TAN::Model::Search

=head1 DESCRIPTION

Interface to L<Plucene::Simple>

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

    return Plucene::Simple->open( $config->{'index_path'} );
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
