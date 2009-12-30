package TAN::Controller::Login;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use Captcha::reCAPTCHA;

=head1 NAME

TAN::Controller::Login

=head1 DESCRIPTION

User Login

=head1 EXAMPLE

''/login''

 * show login form

''/login/login'' 

 * post here

''/login/logout''

 * logout url

=head1 METHODS

=cut

=head2 index: Path: Args(0)

'''@args = undef'''

 * redirects to / if user logged in
 * loads the login template

=cut
sub index: Path: Args(0){
    my ($self, $c) = @_;
    
    if ($c->user_exists){
        $c->flash->{'message'} = 'You are already logged in';
        $c->res->redirect('/');
        $c->detach();
    }
    
    $c->flash->{'ref'} = defined($c->req->referer) ? $c->req->referer : '/';
    
    $c->stash->{'template'} = 'login.tt';
}

=head2 login: Local

'''@params = (username, password)'''

 * authenticates the user

=cut
sub login: Local{
    my ($self, $c) = @_;
    
    my $ref = $c->flash->{'ref'};
    if (!defined($ref) || $ref =~ m/\/login\//){
        $ref = '/';
    }

    if ( $c->req->method eq 'POST' ){
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
    }

    $c->res->redirect($ref);
    $c->detach();
}

=head2 logout: Local

'''@args = undef'''

 * logs the user out

=cut
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
