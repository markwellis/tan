use strict;
use warnings;

use GearmanX::Simple::Worker;

use WebService::Bitly;
use Net::Twitter;
use Storable;

use LWPx::ParanoidAgent;

use Config::Any;
use File::Basename;

my $config_file = dirname(__FILE__) . '/config.json';
my $devel_config_file = dirname(__FILE__) . '/config_devel.json';

my @config_file = ( $config_file );
if ( $ENV{'DEBUG'} ){
    push( @config_file, dirname(__FILE__) . '/config_devel.json' );
}

my $raw_config = Config::Any->load_files( {
    'files' => \@config_file,
    'flatten_to_hash' => 1,
    'use_ext' => 1,
} );

my $config = {
    %{$raw_config->{ $config_file }},
};

if ( exists( $raw_config->{ $devel_config_file } ) ){
    $config = {
        %{$config},
        %{$raw_config->{ $devel_config_file }},
    }
}

sub spam_twitter{
    my ( $job ) = @_;

    my $args = Storable::thaw( $job->arg );

    my $bitly = WebService::Bitly->new(
        'user_name' => $config->{'bitly'}->{'user_name'},
        'user_api_key' => $config->{'bitly'}->{'user_api_key'},
        'domain' => $config->{'bitly'}->{'domain'},
        'ua' => LWPx::ParanoidAgent->new(
            timeout   => 5,
        ),
    );

    $args->{'url'} =~ s|(?<!http:)//|/|g; #remove duplicate // in url

    my $shorten = $bitly->shorten( $args->{'url'} );
    if ( $shorten->is_error ){
        return;
    }

    my $url = eval{
        return $shorten->short_url;
    };

    return 1 if $@;

    my $nt = Net::Twitter->new(
        traits   => [qw/OAuth API::REST/],
        consumer_key => $config->{'twitter'}->{'consumer_key'},
        consumer_secret => $config->{'twitter'}->{'consumer_secret'},
        access_token => $config->{'twitter'}->{'access_token'},
        access_token_secret => $config->{'twitter'}->{'access_token_secret'},
        useragent_class => 'LWPx::ParanoidAgent',
        useragent_args => {
            timeout   => 5,
        },
    );

    my $availble_length = 140;
    $availble_length -= length( $url ) + 1; #+1 is space
    $availble_length -= length( 'RT @' . $config->{'twitter'}->{'username'} . ' ' );

    my $nsfw = '';
    my $title = $args->{'title'};

    if ( $args->{'nsfw'} eq 'Y' ){
        $nsfw = ' #NSFW';
        $availble_length -= length( $nsfw );
    }

    if ( length( $title ) > $availble_length ){
        $title = substr( $title, 0, ( $availble_length ) );
    }

    eval{
        $nt->update( "${title}${nsfw} ${url}" );
    };

    return 1;
}

my $worker = GearmanX::Simple::Worker->new( $config->{'job_servers'}, {
    'twitter_spam' => \&spam_twitter,
} );

$worker->work;
