package TAN::Model::PayPal;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use LWPx::ParanoidAgent;
use Exception::Simple;

has 'email' => (
    'isa' => 'Str',
    'is' => 'ro',
    'required' => 1,
);

has 'username' => (
    'isa' => 'Str',
    'is' => 'ro',
    'required' => 1,
);

has 'password' => (
    'isa' => 'Str',
    'is' => 'ro',
    'required' => 1,
);

has 'signature' => (
    'isa' => 'Str',
    'is' => 'ro',
    'required' => 1,
);

has 'sandbox' => (
    'isa' => 'Num',
    'is' => 'ro',
    'required' => 1,
    'default' => 1,
);

sub validate{
    my ( $self, $params ) = @_;

    my $ua = LWPx::ParanoidAgent->new;
    $params->{'cmd'} = '_notify-validate';
    my $url = 'https://www';
    if ( $self->sandbox ){
        $url .= '.sandbox';
    }
    $url .= '.paypal.com/cgi-bin/webscr';
    my $res = $ua->post( $url, $params );
    if ( $res->is_error ){
        Exception::Simple->throw('http error');
    } elsif ( $res->content eq 'VERIFIED' ){
        if ( $params->{'payment_status'} ne 'Completed' ){
# check that $txn_id has not been previously processed
            Exception::Simple->throw('payment not completed');
        }
        if ( $params->{'receiver_email'} ne $self->email ){
            Exception::Simple->throw('not our receiver_email');
        }
        return;
    } elsif ($res->content eq 'INVALID') {
        Exception::Simple->throw("invalid");
    }
    
    Exception::Simple->throw("unkown error");
}

sub make_payment{
    my ( $self ) = @_;
}

__PACKAGE__->meta->make_immutable;
