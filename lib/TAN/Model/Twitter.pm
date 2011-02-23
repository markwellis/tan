package TAN::Model::Twitter;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use Net::Twitter;
use LWPx::ParanoidAgent;
use Exception::Simple;

has 'consumer_key' => (
    'is' => 'ro',
    'isa' => 'Str',
    'required' => 1,
);

has 'consumer_secret' => (
    'is' => 'ro',
    'isa' => 'Str',
    'required' => 1,
);

has 'access_token' => (
    'is' => 'ro',
    'isa' => 'Str',
    'required' => 1,
);

has 'access_token_secret' => (
    'is' => 'ro',
    'isa' => 'Str',
    'required' => 1,
);

has 'username' => (
    'is' => 'ro',
    'isa' => 'Str',
    'required' => 1,
);

sub spam{
    my ( $self, $title, $url ) = @_;

    my $nt = Net::Twitter->new(
        traits   => [qw/OAuth API::REST/],
        consumer_key => $self->consumer_key,
        consumer_secret => $self->consumer_secret,
        access_token => $self->access_token,
        access_token_secret => $self->access_token_secret,
        useragent_class => 'LWPx::ParanoidAgent',
        useragent_args => {
            timeout   => 3,
        },
    );

    my $availble_length = 140;
    $availble_length -= length( $url ) + 1; #+1 is space
    $availble_length -= length( 'RT @' . $self->username . ' ' );

    if ( length( $title ) > $availble_length ){
        $title = substr( $title, 0, ( $availble_length ) );
    }

    return $nt->update( "${title} ${url}" );
}

__PACKAGE__->meta->make_immutable;
