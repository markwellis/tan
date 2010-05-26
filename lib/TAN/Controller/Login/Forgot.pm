package TAN::Controller::Login::Forgot;
use strict;
use warnings;

use parent 'Catalyst::Controller';
use Data::Validate::Email;

=head1 NAME

TAN::Controller::Login::Forgot

=head1 DESCRIPTION

User forgot username/password

=head1 EXAMPLE

I</login/forgot>

=over

show email form

=back

=head1 METHODS

=cut

=head2 index: Path: Args(0)

B<@args = undef>

=over

redirects to / if user logged in

loads the forgot template

=back

=cut
sub index: Path Args(0){
    my ( $self, $c ) = @_;
   
    if ( $c->user_exists ){
        $c->flash->{'message'} = "You're already logged in";
        $c->res->redirect('/');
        $c->detach();
    }

    $c->flash->{'ref'} = defined($c->req->referer) ? $c->req->referer : '/';
    
    $c->stash->{'template'} = 'login/forgot/index.tt';
}

=head2 step1: Local

B<@args = undef>

=over

finds user by email, then emails them a reset token

=back

=cut
sub step1: Local{
    my ( $self, $c ) = @_;
   
    my $email = $c->req->param('email');
    if ( $c->req->method ne 'POST' || !defined($email) ){
        $c->res->redirect('/login/forgot');
        $c->detach();
    }

    my $user = $c->model('MySQL::User')->by_email($email);
    if ( !defined($user) ){
        $c->flash->{'message'} = 'Not a valid email';
        $c->res->redirect('/login/forgot');
        $c->detach();
    }

#create user token
#send email
    $c->stash->{'user'} = $user;
    $c->stash->{'token'} = $user->tokens->new_token($user->id, 'forgot');

    $c->email(
        'header' => [
            'From'    => 'noreply@thisaintnews.com',
            'To'      => $email,
            'Subject' => 'User Details',
            'Content-Type' => 'text/html',
        ],
        'body' => $c->view('NoWrapper')->render( $c, 'login/forgot/email.tt' ),
    );

#add a message and redirect user somewhere...
    $c->flash->{'message'} = 'Email sent';
    $c->res->redirect('/');
    $c->detach();
}

=head2 step2: Local Args(2)

B<@args = $user_id, $token>

=over

lets a user change their password

=back

=cut
sub step2: Local Args(2){
    my ( $self, $c, $user_id, $token ) = @_;

    my $token_rs = $c->model('MySQL::UserTokens')->compare($user_id, $token, 'forgot', 1);

    if ( !defined($token_rs) ){
    #token doesn't match
        $c->flash->{'message'} = 'There has been a problem';
        $c->res->redirect('/');
        $c->detach();
    }

    if ( $c->req->method eq 'POST' ){
        my $password0 = $c->req->param('password0');
        my $password1 = $c->req->param('password1');
        if ( $password0 eq $password1 ){
            if ( length($password0) > 5 ){
                #good stuff
                $c->model('MySQL::User')->change_password($user_id, $password0);
                #delete the token since we're done with it now
                $token_rs->delete;

                $c->flash->{'message'} = 'Your password has been changed';
                $c->res->redirect('/login/');
                $c->detach();
            } else {
                #why stash not flash?
                # coz flash is transfered to stash in $c->check_cache, 
                # but we don't hit that here or below coz we jump into the render
                $c->stash->{'message'} = 'Password needs to be at least 6 letters';
            }
        } else {
            #see note above
            $c->stash->{'message'} = 'Passwords do not match';
        }
    }

    $c->stash->{'token'} = $token;
    $c->stash->{'user_id'} = $user_id;
    $c->stash->{'template'} = 'login/forgot/step2.tt';
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
