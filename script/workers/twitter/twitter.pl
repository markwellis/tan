use 5.018;
use warnings;

use Gearman::Worker;

use WebService::Bitly;
use Net::Twitter;
use Storable;

use LWPx::ParanoidAgent;

use Config::Any;
use File::Basename;

say "Started: pid $$: " . scalar( localtime );

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
        say $shorten->status_code . ': ' . $shorten->status_txt . "\n";

        return 1;
    }

    my $url = $shorten->short_url;

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
    my @tags = @{ $args->{'tags'} };

    foreach my $tag ( @tags ){
        $title =~ s/($tag)/#$1/i;
    }

    #remove duplicate #
    $title =~ s/#+/#/g;

    if ( $args->{'nsfw'} ){
        $nsfw = ' #NSFW';
        $availble_length -= length( $nsfw );
    }

    if ( length( $title ) > $availble_length ){
        $title = substr( $title, 0, ( $availble_length ) );
    }

    say "status: ${title}${nsfw} ${url}\n";
    eval{
        $nt->update( "${title}${nsfw} ${url}" );
    };

    say "${@}\n" if $@;

    return 1;
}

my $worker = Gearman::Worker->new;
$worker->job_servers( @{ $config->{'job_servers'} } );
$worker->register_function( 'twitter_spam' => \&spam_twitter );

my $exit_trap = sub{
    $worker->unregister_function('twitter_spam');
    say "Ended: pid $$: " . scalar( localtime );
    exit;
};

$SIG{TERM} = $exit_trap;
$SIG{INT} = $exit_trap;

$worker->work while 1;
