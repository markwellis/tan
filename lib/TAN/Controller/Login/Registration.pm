package TAN::Controller::Login::Registration;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Data::Validate::Email;
use Try::Tiny;
use Exception::Simple;

sub index: Path Args(0){
    my ( $self, $c ) = @_;

#check recaptcha
    my $result = do {
        #meh
        local $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

        $c->model('reCAPTCHA')->check_answer_v2(
            $c->config->{'recaptcha_private_key'},
            $c->req->param("g-recaptcha-response"),
            $c->req->address,
        );
    };

    my $password0 = $c->req->param("rpassword0");
    my $password1 = $c->req->param("rpassword1");
    my $username = $c->req->param("rusername");
    my $email = $c->req->param("remail");

    my $new_user;
    try {
        Exception::Simple->throw("registrations disabled");

        if ( !$result->{'is_valid'} ){
        # recaptcha failed
            Exception::Simple->throw("Captcha words do not match");
        }
        if ( !$password0  || !$password1 || !$email || !$username ){
        #form incomplete
            Exception::Simple->throw('Please complete the form');
        }
        if ( !Data::Validate::Email::is_email($email) ){
        #invalid email address
            Exception::Simple->throw('Not an valid email address');
        }
        if ( $password0 ne $password1 ){
        #passwords dont match
            Exception::Simple->throw('Passwords do not match');
        }
        if ( $username =~ m/\W+/g ){
        #username cantains invalid chars
            Exception::Simple->throw('Username can only contain letters or numbers');
        }
        if ( $c->model('DB::User')->username_exists($username) ) {
        #username exists
            Exception::Simple->throw('Username already exists');
        }
        if ( $c->model('DB::User')->email_exists($email) ) {
        #email exists
           Exception::Simple->throw('Email address already exists');
        }
        $new_user = eval {$c->model('DB::User')->new_user($username, $password0, $email);};
        Exception::Simple->throw("problem registering") if $@;
    }
    catch {
        $c->flash->{'username'} = $username;
        $c->flash->{'email'} = $email;

        $c->flash->{'message'} = "$_";
        $c->res->redirect( '/login/', 303 );
        $c->detach;
    };

    #get new users token
# mail token to user
    $c->stash->{'token'} = $new_user->tokens->find({
        'type' => 'reg',
    })->token;
    $c->stash->{'user_id'} = $new_user->id;

    $c->model('Email')->send(
        'from'    => 'noreply@thisaintnews.com',
        'to'      => $email,
        'subject' => 'Confirm email address',
        'htmltext' => $c->view('NoWrapper')->render( $c, 'login/registration/email.tt' ),
    );

    $c->flash->{'message'} = 'Thanks for registering, you will recieve a confirmation email shortly';

    my $ref = $c->flash->{'ref'};
    if ( !$ref || $ref =~ m|/login/| ){
        $ref = '/index/all/0/';
    }
    $c->res->redirect($ref, 303);
}

sub confirm: Local{
    my ( $self, $c, $user_id, $token ) = @_;

    if ( $c->model('DB::UserTokens')->compare($user_id, $token, 'reg') ){
        my $user = $c->model('DB::User')->find({
            'user_id' => $user_id,
        });
        if ( $user ){
            $user->confirm;
            $c->flash->{'message'} = 'Your email has been confirmed, please login';
        } else {
            $c->flash->{'message'} = 'Shit el problemo';
        }
    } else {
        $c->flash->{'message'} = 'There has been a problem';
    }
    $c->res->redirect('/login/', 303);
}

__PACKAGE__->meta->make_immutable;
