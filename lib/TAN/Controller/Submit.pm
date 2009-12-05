package TAN::Controller::Submit;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head2 index

=cut
my $location_reg = qr/^link|blog|picture$/;
my $int_reg = qr/\D+/;

sub location: Chained('/') PathPart('submit') CaptureArgs(1){
    my ( $self, $c, $location ) = @_;

    if (!$c->user_exists){
        $c->flash->{'message'} = 'Please login';
        $c->res->redirect('/login/');
        $c->detach();
    }

    if ($location !~ m/$location_reg/){
        $c->forward('/default');
        $c->detach();
    }
    $c->stash->{'location'} = $location;
}

sub index : PathPart('') Chained('location') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'submit.tt';
}

sub post: PathPart('post') Chained('location') Args(0){
    my ( $self, $c ) = @_;

warn $c->stash->{'location'};
warn Data::Dumper::Dumper($c->req->params);

    # validate
    # submit
    # redirect
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
