package TAN::Controller::Login;
use strict;
use warnings;

use parent 'Catalyst::Controller';
use Data::Validate::Email;

=head1 NAME

TAN::Controller::Login

=head1 DESCRIPTION

User Login

=head1 EXAMPLE

I</login>

=over

show login form

=back

I</login/login>

=over

post here

=back

I</login/logout>

=over

logout url

=back

=head1 METHODS

=cut

=head2 index: Path: Args(0)

B<@args = undef>

=over

redirects to / if user logged in

loads the login template

=back

=cut
sub index: Path Args(0){
    my ( $self, $c ) = @_;
    
    if ( $c->user_exists ){
        $c->flash->{'message'} = 'You are already logged in';
        $c->res->redirect('/');
        $c->detach();
    }
    
    $c->stash->{'recaptcha_html'} = $c->model('reCAPTCHA')->get_html( 
        $c->config->{'recaptcha_public_key'},
        undef,
        undef,
        {
            'theme' => 'blackglass',
        }
    );

    $c->flash->{'ref'} = defined($c->req->referer) ? $c->req->referer : '/';
    
    $c->stash(
        'page_title' => 'Login/Register',
        'template' => 'Login',
        'no_ads' => 1,
    );
}

=head2 login: Local Args(0)

B<@params = (username, password)>

=over

authenticates the user

=back

=cut
sub login: Local Args(0){
    my ( $self, $c ) = @_;
    
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
            if ( $c->user->confirmed eq 'N' ){
                $ref = '/login/';
                $c->logout;
                $c->flash->{'message'} = "You need to confirm your email address";
            } elsif ( $c->user->deleted eq 'Y' ){
                $ref = '/';
                $c->logout;
                $c->flash->{'message'} = "You have been deleted";
            } else {
                #post any saved comments
                $c->forward('/view/post_saved_comments');
                $c->flash->{'message'} = 'You have logged in';
            }
        } else {
            $ref = '/login/';
            $c->flash->{'message'} = "Couldn't find you with that username and password";
        }
    }

    $c->res->redirect($ref);
    $c->detach();
}

=head2 logout: Local Args(0)

B<@args = undef>

=over

logs the user out

=back

=cut
sub logout: Local Args(0){
    my ( $self, $c ) = @_;
    
    if ( $c->user_exists ){
        $c->logout;
        $c->flash->{'message'} = "You have logged out";
    } else {
        $c->flash->{'message'} = "You weren't logged in!";
    }

    my $ref = $c->req->referer || '/';
    $c->res->redirect( $ref );
    $c->detach();
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
