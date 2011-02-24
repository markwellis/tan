use strict;
use warnings;

use App::Daemon;
use Gearman::Worker;

use LWP::Simple;
use CGI;

my @search_engine_ping_urls = (
    'http://submissions.ask.com/ping?sitemap=',
    'http://www.google.com/webmasters/sitemaps/ping?sitemap=',
    'http://search.yahooapis.com/SiteExplorerService/V1/updateNotification?appid=IRxERwfV34EV44V9LTrJsENRs0V4JlaxrmVCr93OXcpqgzdQqUVRjKIo0FrabG1g&url=',
    'http://webmaster.live.com/ping.aspx?siteMap=',
    'http://api.moreover.com/ping?u=',
);

App::Daemon::daemonize();

my $worker = Gearman::Worker->new;
$worker->job_servers('127.0.0.1:4730');

$worker->register_function( 'sitemap_ping' => \&sitemap_ping );

my $lastrun; #used to make sure we don't run more than every 10 mins

sub sitemap_ping{
    my ( $job ) = @_;

    if ( !$lastrun || (time - $lastrun) > 600 ){
    #10 min limit
        foreach my $search_engine_ping_url (@search_engine_ping_urls) {
            warn "get(" . $search_engine_ping_url . CGI::escape( 'http://thisaintnews.com/sitemap' ) . ")";
        }
        $lastrun = time;
    }
}

$worker->work while 1;
