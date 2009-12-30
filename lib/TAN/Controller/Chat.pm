package TAN::Controller::Chat;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::Chat

=head1 DESCRIPTION

Mibbit iframe embedded in-page

=head1 EXAMPLE

I</chat>

=head1 METHODS

=cut

=head2 index: Path

B<@args = undef>

=over

loads chat template... 

=back

=cut
sub index :Path {
    my ( $self, $c ) = @_;

    $c->cache_page( 120 );

    $c->stash->{'template'} = 'chat.tt';
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
