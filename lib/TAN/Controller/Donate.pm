package TAN::Controller::Donate;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Try::Tiny;

sub index: Private{
    my ( $self, $c ) = @_;

#load in things here etc
# load this months used numbers, put i hash like { number => row }
# ?
    $c->stash(
        'button' => $c->model('PayPal')->button( {
            'currency_code' => $c->config->{'donate'}->{'currency'},
            'amount' => $c->config->{'donate'}->{'cost'},
            'notify_url' => $c->uri_for('/donate/validate'),
        } ),
        'template' => 'donate.tt',
        'page_title' => 'Donate',
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
    if ( $c->req->param('mc_currency') != $c->config->{'donate'}->{'currency'} ){
        die 'invalid currency';
    }
# process payment
    $c->res->output('ok');
    $c->detach;
};

__PACKAGE__->meta->make_immutable;
