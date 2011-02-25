use strict;
use warnings;

use GearmanX::Simple::Worker;

use WebService::Bitly;
use Net::Twitter;
use Storable;

use LWPx::ParanoidAgent;
use Exception::Simple;

use Config::Any;
use File::Basename;
my $config_file = dirname(__FILE__) . '/config.json';

my $config = Config::Any->load_files( {
    'files' => [ $config_file ],
    'flatten_to_hash' => 1,
    'use_ext' => 1,
} );

$config = $config->{ $config_file };

sub spam_twitter{
    my ( $job ) = @_;

    my $args = Storable::thaw( $job->arg );

    my $bitly = WebService::Bitly->new(
        'user_name' => $self->user_name,
        'user_api_key' => $self->user_api_key,
        'domain' => $self->domain,
        'ua' => LWPx::ParanoidAgent->new(
            timeout   => 3,
        ),
    );

    my $shorten = $bitly->shorten( $args->{'url'} );
    if ( $shorten->is_error ){
        return;
    }

    my $url = $shorten->short_url;

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
    $availble_length -= length( 'RT @' . $self->username . ' ' ); #TODO

    my $nsfw = '';
    my $title = $args->{'title'};

    if ( $args->{'is_nsfw'} eq 'Y' ){
        $nsfw = ' #NSFW';
        $availble_length -= length( $nsfw );
    }

    if ( length( $title ) > $availble_length ){
        $title = substr( $title, 0, ( $availble_length ) );
    }

    $nt->update( "${title}${nsfw} ${url}" );
}

my $worker = GearmanX::Simple::Worker->new( $config->{'job_servers'}, {
    'spam_twitter' => \&spam_twitter,
} );

$worker->work;
