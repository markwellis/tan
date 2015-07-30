package TAN::Controller::Settings::Email;
use Moose;
use MooseX::MethodAttributes;

extends 'Catalyst::Controller';

use Try::Tiny;
use Data::Validate::Email;

sub email(): Chained(../check_user) CaptureArgs(0) { 1 }

sub index: GET Chained(email) PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        template    => 'settings/email.tt',
    );
}

sub change: POST Chained(email) Args(0) {
    my ( $self, $c ) = @_;

    my $email0 = $c->req->param('email0');
    my $email1 = $c->req->param('email1');

    try {
        die "Email already exists\n"
            if $c->model('DB::User')->find( {
                email   => $email0,
            } );

        die "Emails don't match, try again\n"
            if ( $email0 ne $email1 );

        die "Invalid email address\n"
            if ( !Data::Validate::Email::is_email( $email0 ) );
    }
    catch {
        $c->flash->{message} = $_;
        $c->res->redirect('/settings/email', 303);
        $c->detach;
    };

    $c->user->update( {
        email   => $email0,
    } );
    $c->persist_user;

    $c->flash->{message} = "Your email has been changed";
    $c->res->redirect( $c->user->profile_url, 303 );
}

1;
