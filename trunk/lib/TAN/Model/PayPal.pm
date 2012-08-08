package TAN::Model::PayPal;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use LWPx::ParanoidAgent;
use Exception::Simple;
use URI;

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

has 'url' => (
    'isa' => 'URI',
    'is' => 'ro',
    'init_arg' => undef,
    'lazy_build' => 1,
);

sub _build_url{
    my ( $self ) = @_;

    my $uri = URI->new( 
        'https://www' 
        . ( $self->sandbox ? '.sandbox' : '' ) 
        . '.paypal.com/cgi-bin/webscr'
    );
    
    return $uri;
}

sub button{
    my ( $self, $params ) = @_;

    $params->{'cmd'} = '_xclick';
    $params->{'business'} = $self->email;

    my $uri = $self->url->clone;
    $uri->query_form( $params );

    return $uri;
}

sub validate{
    my ( $self, $params ) = @_;

    my $ua = LWPx::ParanoidAgent->new;
    $params->{'cmd'} = '_notify-validate';
    my $res = $ua->post( $self->url->as_string, $params );
    if ( $res->is_error ){
        Exception::Simple->throw('http error');
    } elsif ( $res->content eq 'VERIFIED' ){
        if ( $params->{'payment_status'} ne 'Completed' ){
            Exception::Simple->throw('payment not completed');
        }
        if ( $params->{'receiver_email'} ne $self->email ){
            Exception::Simple->throw('not our receiver_email');
        }
        return;
    } elsif ( $res->content eq 'INVALID' ){
        Exception::Simple->throw("invalid");
    }
    
    Exception::Simple->throw("unkown error");
}

sub make_payment{
    my ( $self ) = @_;
}

__PACKAGE__->meta->make_immutable;
