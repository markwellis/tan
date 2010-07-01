#!/usr/bin/perl
use warnings;
use strict;

use LWP::Simple;
use CGI;

my @search_engine_ping_urls = (
    'http://submissions.ask.com/ping?sitemap=',
    'http://www.google.com/webmasters/sitemaps/ping?sitemap=',
    'http://search.yahooapis.com/SiteExplorerService/V1/updateNotification?appid=IRxERwfV34EV44V9LTrJsENRs0V4JlaxrmVCr93OXcpqgzdQqUVRjKIo0FrabG1g&url=',
    'http://webmaster.live.com/ping.aspx?siteMap=',
    'http://api.moreover.com/ping?u=',
);

foreach my $search_engine_ping_url (@search_engine_ping_urls) {
    get( $search_engine_ping_url . CGI::escape( 'http://thisaintnews.com/sitemap/' ) );
}
