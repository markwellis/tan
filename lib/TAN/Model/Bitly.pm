package TAN::Model::Bitly;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use WebService::Bitly;
use LWPx::ParanoidAgent;
use Exception::Simple;

has 'user_name' => (
    'is' => 'ro',
    'isa' => 'Str',
    'required' => 1,
);

has 'user_api_key' => (
    'is' => 'ro',
    'isa' => 'Str',
    'required' => 1,
);

has 'domain' => (
    'is' => 'ro',
    'isa' => 'Str',
    'required' => 1,
);

sub shorten{
    my ( $self, $url ) = @_;

    my $bitly = WebService::Bitly->new(
        'user_name' => $self->user_name,
        'user_api_key' => $self->user_api_key,
        'domain' => $self->domain,
        'ua' => LWPx::ParanoidAgent->new(
            timeout   => 3,
        ),
    );

    my $shorten = $bitly->shorten( $url );
    if ( $shorten->is_error ){
        Exception::Simple->throw( $shorten->status_code . ': ' . $shorten->status_txt );
    }

    return $shorten->short_url;
}

__PACKAGE__->meta->make_immutable;
