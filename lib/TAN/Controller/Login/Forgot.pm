package TAN::Controller::Login::Forgot;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Data::Validate::Email;

has '_mobile' => (
    'is' => 'ro',
    'isa' => 'HashRef',
    'default' => sub{
        return {
            'index' => 1,
            'step1' => 1,
            'step2' => 1,
        };
    },
);

sub index: Path Args(0){
    my ( $self, $c ) = @_;
   
    if ( $c->user_exists ){
        $c->flash->{'message'} = "You're already logged in";
        $c->res->redirect('/index/all/0/', 303);
        $c->detach();
    }

    $c->flash->{'ref'} = defined($c->req->referer) ? $c->req->referer : '/index/all/0/';
    
    $c->stash->{'template'} = 'login/forgot/index.tt';
}

sub step1: Local{
    my ( $self, $c ) = @_;
   
    my $email = $c->req->param('email');
    if ( $c->req->method ne 'POST' || !defined($email) ){
        $c->res->redirect('/login/forgot/', 303);
        $c->detach();
    }

    my $user = $c->model('MySQL::User')->by_email($email);
    if ( !defined($user) ){
        $c->flash->{'message'} = 'Not a valid email';
        $c->res->redirect('/login/forgot/', 303);
        $c->detach();
    }

#create user token
#send email
    $c->stash->{'user'} = $user;
    $c->stash->{'token'} = $user->tokens->new_token($user->id, 'forgot');

    $c->model('Email')->send(
        'from'    => 'noreply@thisaintnews.com',
        'to'      => $email,
        'subject' => 'User Details',
        'htmltext' => $c->view('NoWrapper')->render( $c, 'login/forgot/email.tt' ),
    );

#add a message and redirect user somewhere...
    $c->flash->{'message'} = 'Email sent';
    $c->res->redirect('/index/all/0/', 303);
    $c->detach();
}

sub step2: Local Args(2){
    my ( $self, $c, $user_id, $token ) = @_;

    my $token_rs = $c->model('MySQL::UserTokens')->compare($user_id, $token, 'forgot', 1);

    if ( !defined($token_rs) ){
    #token doesn't match
        $c->flash->{'message'} = 'There has been a problem';
        $c->res->redirect('/index/all/0/', 303);
        $c->detach();
    }

    if ( $c->req->method eq 'POST' ){
        my $password0 = $c->req->param('password0');
        my $password1 = $c->req->param('password1');
        if ( $password0 eq $password1 ){
            if ( length($password0) > 5 ){
                #good stuff
                $c->model('MySQL::User')->find( $user_id )->set_password( $password0 );
                #delete the token since we're done with it now
                $token_rs->delete;

                $c->flash->{'message'} = 'Your password has been changed';
                $c->res->redirect('/login/', 303);
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

__PACKAGE__->meta->make_immutable;
