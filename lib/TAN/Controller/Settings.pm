package TAN::Controller::Settings;
use Moose;
use MooseX::MethodAttributes;

extends 'Catalyst::Controller';

sub settings(): Chained(/) PathPart(settings) CaptureArgs(0) { 1 }

sub check_user: Chained(settings) PathPart('') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    if ( !$c->user_exists ) {
        $c->flash->{'message'} = 'Please login';
        $c->res->redirect('/login/', 303);
        $c->detach;
    }
}

sub toggle_nsfw: Chained(settings) Args(0) {
    my ( $self, $c ) = @_;

    #bitwise ftw
    $c->nsfw($c->nsfw ^ 1);

    my $ref = $c->req->referer // '/';

    $c->res->redirect( $ref, 303 );
    $c->detach;
}

1;
