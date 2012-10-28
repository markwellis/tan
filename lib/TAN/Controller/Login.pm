package TAN::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

has '_mobile' => (
    'is' => 'ro',
    'isa' => 'HashRef',
    'default' => sub{
        return {'index' => 1};
    },
);

sub index: Path Args(0){
    my ( $self, $c ) = @_;
    
    if ( $c->user_exists ){
        $c->flash->{'message'} = 'You are already logged in';
        $c->res->redirect( '/index/all/0/', 303 );
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

    $c->flash->{'ref'} = defined($c->req->referer) ? $c->req->referer : '/index/all/0/';
    
    $c->stash(
        'page_title' => 'Login/Register',
        'template' => 'login.tt',
        'no_ads' => 1,
    );
}

sub login: Local Args(0){
    my ( $self, $c ) = @_;
    
    my $ref = $c->flash->{'ref'};
    if (!defined($ref) || $ref =~ m/\/login\//){
        $ref = '/index/all/0/';
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
                $ref = '/index/all/0/';
                $c->logout;
                $c->flash->{'message'} = "You have been deleted";
            } else {
                #post any saved comments
                if ( $c->check_usr_tcs ){
                    $c->forward('/view/comment/post_saved_comments');
                }
                $c->flash->{'message'} = 'You have logged in';
            }
        } else {
            $ref = '/login/';
            $c->flash->{'message'} = "Couldn't find you with that username and password";
        }
    }

    $c->res->redirect( $ref, 303 );
    $c->detach();
}

sub logout: Local Args(0){
    my ( $self, $c ) = @_;
    
    if ( $c->user_exists ){
        $c->logout;
        $c->flash->{'message'} = "You have logged out";
    } else {
        $c->flash->{'message'} = "You weren't logged in!";
    }

    my $ref = $c->req->referer || '/index/all/0/';
    $c->res->redirect( $ref, 303 );
    $c->detach();
}

__PACKAGE__->meta->make_immutable;
