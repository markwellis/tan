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
    
    $c->stash->{'recaptcha_html'} = $c->model('reCAPTCHA')->get_html( $c->config->{'recaptcha_public_key'}, undef, undef, {
        'theme' => 'blackglass',
    });

    $c->flash->{'ref'} = defined($c->req->referer) ? $c->req->referer : '/';
    
    $c->stash->{'template'} = 'login.tt';
}

=head2 login: Local

B<@params = (username, password)>

=over

authenticates the user

=back

=cut
sub login: Local{
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
            #post any saved comments
            $c->forward('/view/post_saved_comments');

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

B<@args = undef>

=over

logs the user out

=back

=cut
sub logout: Local{
    my ( $self, $c ) = @_;
    
    if ( $c->user_exists ){
        $c->logout;
        $c->flash->{'message'} = "You have logged out";
    } else {
        $c->flash->{'message'} = "You weren't logged in!";
    }

    my $ref = $c->req->referer || '/';
    $c->res->redirect( $ref);
    $c->detach();
}

=head2 register: Local

B<@args = undef>

=over

registers a user

=back

=cut
sub register: Local{
    my ( $self, $c ) = @_;

# do some security shit here, perhaps add a nonce

    my $result = $c->model('reCAPTCHA')->check_answer(
        $c->config->{'recaptcha_private_key'}, 
        $c->req->address, 
        $c->req->param("recaptcha_challenge_field"), 
        $c->req->param("recaptcha_response_field"),
    );

    my $password0 = $c->req->param("rpassword0");
    my $password1 = $c->req->param("rpassword1");
    my $username = $c->req->param("rusername");
    my $email = $c->req->param("remail");

    my $error;
    if ( !$result->{'is_valid'} ){
    # recaptcha failed
        $c->flash->{'username'} = $c->req->param('rusername');
        $c->flash->{'email'} = $c->req->param('remail');

        $c->flash->{'message'} = "Captcha words do not match";

        my $ref = $c->req->referer || '/';
        $c->res->redirect( $ref);
        $c->detach();
    }
    
    if ( !$password0  || !$password1 || !$email || !$username ){
        $error = 'Please complete the form';
    } elsif ( !Data::Validate::Email::is_email($email) ){
        $error = 'Not an valid email address';
    } elsif ( $password0 ne $password1 ){
        $error = 'Passwords do not match';
    } elsif ( length($password0) < 5  ){
        $error = 'Password needs to be atleast 6 letters';
    } elsif ( $username =~ m/\W+/g ){
        $error = 'Username can only contain letters or numbers';
    } elsif ( $c->model('MySQL::User')->username_exists($username) ) {
        $error = 'Username already exists';
    } elsif ( $c->model('MySQL::User')->email_exists($email) ) {
       $error = 'Email address already exists';
    }

    if ( $error ){
        $c->flash->{'username'} = $c->req->param('rusername');
        $c->flash->{'email'} = $c->req->param('remail');

        $c->flash->{'message'} = $error;
        $c->res->redirect( '/login' );
        $c->detach();
    }

#return new user object or error
    my $new_user = $c->model('MySQL::User')->new_user($username, $password0, $email);
    if ( !ref( $new_user ) ){
    # blank ref, aka an actual scalar
        $c->flash->{'username'} = $c->req->param('rusername');
        $c->flash->{'email'} = $c->req->param('remail');

        $c->flash->{'message'} = 'Something done fucked up';
        $c->res->redirect( '/login' );
        $c->detach();
    }

    #get new users token
# mail token to user
    $c->stash->{'token'} = $new_user->tokens->find({
        'type' => 'reg',
    });
    $c->stash->{'user_id'} = $new_user->id;

    $c->email(
        'header' => [
            'From'    => 'noreply@thisaintnews.com',
            'To'      => $email,
            'Subject' => 'Confirm email address'
        ],
        'body' => $c->view('NoWrapper')->render( $c, 'login/email_confirm.tt' ),
    );

    $c->flash->{'message'} = 'Thanks for registering, you will recieve a confirmation email shortly';

    my $ref = $c->flash->{'ref'};
    if ( !$ref || $ref =~ m|/login/| ){
        $ref = '/';
    }
    $c->res->redirect($ref);
}

sub test: Local{
    my ($self, $c) = @_;

    $c->email(
        'header' => [
            'From'    => 'noreply@thisaintnews.com',
            'To'      => 'shit@thisaintnews.com',
            'Subject' => 'Confirm email address',
            'Content-Type' => 'text/html',
        ],
        'body' => $c->view('NoWrapper')->render( $c, 'login/email_confirm.tt' ),
    );
    $c->res->output('email sent');
}
=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
