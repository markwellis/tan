use 5.018;
use warnings;

use Gearman::Worker;

use LWP::Simple;
use CGI;

use Config::Any;
use File::Basename;

say "Started: pid $$: " . scalar( localtime );

my $config_file = dirname(__FILE__) . '/config.json';

my $config = Config::Any->load_files( {
    'files' => [ $config_file ],
    'flatten_to_hash' => 1,
    'use_ext' => 1,
} );

$config = $config->{ $config_file };

my $lastrun; #used to make sure we don't run more than every 10 mins

sub sitemap_ping{
    my ( $job ) = @_;

    if ( !$lastrun || (time - $lastrun) > 600 ){
    #10 min limit
        foreach my $search_engine_ping_url ( @{$config->{'search_engine_ping_urls'}} ) {
            say "pinging $search_engine_ping_url";
            get( $search_engine_ping_url . CGI::escape( $config->{'sitemap_url'} ) );
        }
        $lastrun = time;
    }

    return 1;
}

my $worker = Gearman::Worker->new;
$worker->job_servers( @{ $config->{'job_servers'} } );
$worker->register_function( 'sitemap_ping' => \&sitemap_ping );

my $exit_trap = sub{
    $worker->unregister_function('sitemap_ping');
    say "Ended: pid $$: " . scalar( localtime );
    exit;
};

$SIG{TERM} = $exit_trap;
$SIG{INT} = $exit_trap;

$worker->work while 1;
