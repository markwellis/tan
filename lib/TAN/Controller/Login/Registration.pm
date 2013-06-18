package TAN::Controller::Login::Registration;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Data::Validate::Email;

sub index: Path Args(0){
    my ( $self, $c ) = @_;

# do some security shit here, perhaps add a nonce

#check recaptcha
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
        $error = "Captcha words do not match";
    } elsif ( !$password0  || !$password1 || !$email || !$username ){
    #form incomplete
        $error = 'Please complete the form';
    } elsif ( !Data::Validate::Email::is_email($email) ){
    #invalid email address
        $error = 'Not an valid email address';
    } elsif ( $password0 ne $password1 ){
    #passwords dont match
        $error = 'Passwords do not match';
    } elsif ( length($password0) < 5  ){
    #password  short
        $error = 'Password needs to be atleast 6 letters';
    } elsif ( $username =~ m/\W+/g ){
    #username cantains invalid chars
        $error = 'Username can only contain letters or numbers';
    } elsif ( $c->model('MySQL::User')->username_exists($username) ) {
    #username exists
        $error = 'Username already exists';
    } elsif ( $c->model('MySQL::User')->email_exists($email) ) {
    #email exists
       $error = 'Email address already exists';
    }

    if ( $error ){
        $c->flash->{'username'} = $username;
        $c->flash->{'email'} = $email;

        $c->flash->{'message'} = $error;
        $c->res->redirect( '/login/', 303 );
        $c->detach();
    }

#return new user object or error
    my $new_user = $c->model('MySQL::User')->new_user($username, $password0, $email);
    if ( !$new_user ){
        $c->flash->{'username'} = $c->req->param('rusername');
        $c->flash->{'email'} = $c->req->param('remail');

        $c->flash->{'message'} = 'Something done fucked up';
        $c->res->redirect( '/login', 303 );
        $c->detach();
    }

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

    if ( $c->model('MySQL::UserTokens')->compare($user_id, $token, 'reg') ){
        my $user = $c->model('MySQL::User')->find({
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
