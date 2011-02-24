use strict;
use warnings;

use App::Daemon;
use Gearman::Worker;

use Storable;

use WebService::Bitly;
use Net::Twitter;

use LWPx::ParanoidAgent;
use Exception::Simple;

App::Daemon::daemonize();

my $worker = Gearman::Worker->new;
$worker->job_servers('127.0.0.1:4730');

$worker->register_function( 'spam_twitter' => \&spam_twitter );
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

$worker->work while 1;
