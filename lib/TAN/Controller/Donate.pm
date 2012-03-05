package TAN::Controller::Donate;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Try::Tiny;

sub index: Private{
    my ( $self, $c ) = @_;
    
    if (!$c->user_exists){
        $c->flash->{'message'} = 'Please login';
        $c->res->redirect('/login/', 303);
        $c->detach();
    }

#load in things here etc
# load this months used numbers, put i hash like { number => row }
# ?
    $c->stash(
        'button' => $c->model('PayPal')->button( {
            'currency_code' => $c->config->{'donate'}->{'currency'},
            'amount' => $c->config->{'donate'}->{'cost'},
            'notify_url' => $c->uri_for('/donate/validate/'),
            'return' => $c->uri_for('/donate/thankyou/'),
            'cancel_return' => $c->uri_for('/donate/canceled/'),
            'no_shipping' => 1,
            'no_note' => 1,
        } ),
        'template' => 'donate.tt',
        'page_title' => 'Donate',
    );
}

sub thankyou: Local{
    my ( $self, $c ) = @_;

    $c->stash(
        'template' => 'donate/thankyou.tt',
    );
}

sub canceled: Local{
    my ( $self, $c ) = @_;

    $c->stash(
        'template' => 'donate/canceled.tt',
    );
}

sub validate: Local{
    my ( $self, $c ) = @_;
    
    my $error = try{
        $c->model('PayPal')->validate( $c->req->params );
    };

    die if $error;
    if ( $c->req->param('mc_gross') != $c->config->{'donate'}->{'cost'} ){
        die 'invalid amount';
    }
    if ( $c->req->param('mc_currency') ne $c->config->{'donate'}->{'currency'} ){
        die 'invalid currency';
    }
# process payment
    $c->res->output('ok');
    $c->detach;
};

__PACKAGE__->meta->make_immutable;
