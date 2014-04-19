package TAN::Controller::Settings::Password;
use Moose;
use MooseX::MethodAttributes;

extends 'Catalyst::Controller';

sub password(): Chained(../check_user) CaptureArgs(0) { 1 }

sub index: GET Chained(password) PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        template    => 'settings/password.tt',
    );
}

sub change: POST Chained(password) Args(0) {
    my ( $self, $c ) = @_;

    my $password0 = $c->req->param('password0');
    my $password1 = $c->req->param('password1');

    if ( $password0 ne $password1 ) {
        $c->flash->{message} = "Passwords don't match, try again";
        $c->res->redirect('/settings/password', 303);
        $c->detach;
    }

    $c->user->set_password( $password0 );
    $c->persist_user;

    $c->flash->{message} = "Your password has been changed";
    $c->res->redirect( $c->user->profile_url, 303 );
}

1;
