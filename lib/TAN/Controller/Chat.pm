package TAN::Controller::Chat;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head2 index

=cut
sub index :Private {
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
