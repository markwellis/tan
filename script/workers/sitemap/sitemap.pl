use strict;
use warnings;

use GearmanX::Simple::Worker;

use LWP::Simple;
use CGI;

use Config::Any;
use File::Basename;
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
            get( $search_engine_ping_url . CGI::escape( $config->{'sitemap_url'} ) );
        }
        $lastrun = time;
    }
}

my $worker = GearmanX::Simple::Worker->new( $config->{'job_servers'}, {
    'sitemap_ping' => \&sitemap_ping,
} );

$worker->work;
