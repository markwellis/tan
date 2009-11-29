package TAN::Controller::Submit;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head2 index

=cut
my $location_reg = qr/^(link|blog|picture)$/;
my $int_reg = qr/\D+/;
sub index :Path :Args(1) {
    my ( $self, $c, $location ) = @_;

    $c->cache_page( 120 );

    if ($location !~ m/$location_reg/){
        $c->forward('/default');
        $c->detach();
    }
    $c->stash->{'location'} = $location;

    $c->stash->{'template'} = 'submit.tt';
}

sub submit: Path('submit'){
    my ( $self, $c ) = @_;
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
