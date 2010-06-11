package TAN::Controller::FAQ;
use strict;
use warnings;

use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::FAQ

=head1 DESCRIPTION

FAQ page

=head1 EXAMPLE

I</faq>

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

    $c->cache_page( 60 );

    $c->stash->{'template'} = 'faq.tt';
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
