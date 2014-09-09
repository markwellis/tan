package TAN::Controller::Settings::Password;
use Moose;
use MooseX::MethodAttributes;

use Try::Tiny;

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
        $c->res->redirect( $c->uri_for_action( $self->action_for('index') ), 303 );
        $c->detach;
    }
warn length( $password0 );
    try {
        my $max_password_length = $c->config->{'max_password_length'};
        my $password_length = length( $password0 );
warn $password_length;
        die "Password cannot be over ${max_password_length} chars\n"
            if ( $password_length > $max_password_length );

        die "Password needs to be atleast 6 letters\n"
            if ( $password_length < 5  );
    }
    catch {
        $c->flash->{message} = $_;
        $c->res->redirect( $c->uri_for_action( $self->action_for('index') ), 303 );
        $c->detach;
    };

    $c->user->set_password( $password0 );
    $c->persist_user;

    $c->flash->{message} = "Your password has been changed";
    $c->res->redirect( $c->user->profile_url, 303 );
}

1;
