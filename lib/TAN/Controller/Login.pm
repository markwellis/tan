package TAN::Controller::Login;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use Captcha::reCAPTCHA;

sub index: Private{
    my ($self, $c) = @_;
    
    if ($c->user_exists){
        $c->flash->{'message'} = 'You are already logged in';
        $c->res->redirect('/');
        $c->detach();
    }
    
    $c->flash->{'ref'} = defined($c->req->referer) ? $c->req->referer : '/';
    
    $c->stash->{'template'} = 'login.tt';
}

sub login: Local{
    my ($self, $c) = @_;
    
    my $ref = $c->flash->{'ref'};
    if (!defined($ref) || $ref =~ m/\/login\//){
        $ref = '/';
    }
    
    if (
        $c->authenticate({
            'username' => $c->req->param('username'),
            'password' => $c->req->param('password'),
        })
    ){
        $c->flash->{'message'} = 'You have logged in';
    } else {
        $ref = '/login/';
        $c->flash->{'message'} = "Couldn't find you with that username and password";
    }

    $c->res->redirect($ref);
    $c->detach();
}

sub logout: Local{
    my ($self, $c) = @_;
    
    my $ref = $c->req->referer;
    if (!defined($ref)){
        $ref = '/';
    }

    if ($c->user_exists){
        $c->logout;
        $c->flash->{'message'} = "You have logged out";
    } else {
        $c->flash->{'message'} = "You weren't logged in!";
    }

    $c->res->redirect($ref);
    $c->detach();
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
