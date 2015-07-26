package TAN::Controller::Donate;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Try::Tiny;

sub auto: Private{
    my ( $self, $c )= @_;
    $c->detach('/default');
    return 1;
}

sub user_logged_in: PathPart('donate') Chained('/') CaptureArgs(0){
    my ( $self, $c ) = @_;

    if (!$c->user_exists){
        $c->flash->{'message'} = 'Please login';
        $c->res->redirect('/login/', 303);
        $c->detach();
    }
}

sub index: PathPart('') Chained('user_logged_in') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        'used_numbers' => $c->model('DB::Lotto')->used_numbers,
        'template' => 'donate.tt',
        'page_title' => 'Donate',
    );
}

sub buy: PathPart('buy') Chained('user_logged_in') Args(1) {
    my ( $self, $c, $number ) = @_;

    my $not_int_reg = $c->model('CommonRegex')->not_int;
    $number =~ s/$not_int_reg//g;
    if (
        !defined( $number)
        || $number < 0
        || $number > 99
    ){
        $c->res->redirect('/donate/', 303 );
        $c->detach;
    }
    $c->flash->{'lotto_number'} = $number;

    $c->model('DB')->txn_do(sub{
        if ( !$c->model('DB::Lotto')->number_available( $number ) ){ 
            $c->flash->{'message'} = 'Sorry this number is taken';
            $c->res->redirect('/donate/', 303);
            $c->detach;
        }

        $c->model('DB::Lotto')->set_unavailble( $number, $c->user->id ); 
    });

    my $button = $c->model('PayPal')->button( {
        'currency_code' => $c->config->{'donate'}->{'currency'},
        'amount' => $c->config->{'donate'}->{'cost'},
        'notify_url' => $c->uri_for('/donate/validate/'),
        'return' => $c->uri_for('/donate/thankyou/'),
        'cancel_return' => $c->uri_for('/donate/canceled/'),
        'no_shipping' => 1,
        'no_note' => 1,
        'item_name' => "Number ${number}",
        'item_number' => $number,
        'custom' => $c->user->id,
    } );

    $c->res->redirect( $button->as_string, 303 );
    $c->detach;
}

sub thankyou: Local{
    my ( $self, $c ) = @_;

    $c->stash(
        'template' => 'donate/thankyou.tt',
    );
}

sub canceled: Local{
    my ( $self, $c ) = @_;

    my $number = $c->flash->{'lotto_number'};
    
    if ( defined( $number ) ){
        $c->model('DB::Lotto')->remove_number( $number );
    }
    $c->stash(
        'template' => 'donate/canceled.tt',
    );
}

sub validate: Local{
    my ( $self, $c ) = @_;
   
#let these throw if need be (for logging)
    $c->model('PayPal')->validate( $c->req->params );

    if ( $c->req->param('mc_gross') != $c->config->{'donate'}->{'cost'} ){
        Exception::Simple->throw('invalid amount');
    }
    if ( $c->req->param('mc_currency') ne $c->config->{'donate'}->{'currency'} ){
        Exception::Simple->throw('invalid currency');
    }
    
#none of this is tested
    my $user_id = $c->req->param('custom');
    my $number = $c->req->param('item_number');
    my $txn_id = $c->req->param('txn_id');
#error handel any of the above being empty

    $c->model('DB::User')->find( { 
        'user_id' => $user_id 
    } )->update( { 
        'paypal' => $c->req->param('payer_email') 
    } );

    $c->model('DB::Lotto')->confirm_number( $user_id, $number, $txn_id );
#end untested
    $c->res->output('ok');
    $c->detach;
};

__PACKAGE__->meta->make_immutable;
