package TAN::Controller::Donate;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Try::Tiny;

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
        'used_numbers' => $c->model('MySQL::Lotto')->used_numbers,
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

    $c->model('MySQL')->txn_do(sub{
        if ( !$c->model('MySQL::Lotto')->number_available( $number ) ){ 
            $c->flash->{'message'} = 'Sorry this number is taken';
            $c->res->redirect('/donate/', 303);
            $c->detach;
        }

        $c->model('MySQL::Lotto')->set_unavailble( $number, $c->user->id ); 
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
        $c->model('MySQL::Lotto')->remove_number( $number );
    }
    $c->stash(
        'template' => 'donate/canceled.tt',
    );
}

sub validate: Local{
    my ( $self, $c ) = @_;
    
    my $error = try{
        $c->model('PayPal')->validate( $c->req->params );
    };

#shouldn't die
    die if $error;
    if ( $c->req->param('mc_gross') != $c->config->{'donate'}->{'cost'} ){
        die 'invalid amount';
    }
    if ( $c->req->param('mc_currency') ne $c->config->{'donate'}->{'currency'} ){
        die 'invalid currency';
    }
#harvest user paypal email (trciky coz this isnt the user, it's paypal ) but we should be able to $number->user->update( { 'paypal' => $paypal_email } )
#how to get the number here????
#    my $number = ???;
#    my $txn_id = ???;

#    $c->model('MySQL::Lotto')->confirm_number( $number, $txn_id );

    $c->res->output('ok');
    $c->detach;
};

__PACKAGE__->meta->make_immutable;
