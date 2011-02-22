use strict;
use warnings;

use Net::Twitter;
use WebService::Bitly;
use LWPx::ParanoidAgent;

my $bitly = WebService::Bitly->new(
    'user_name' => 'thisaintnews',
    'user_api_key' => 'R_7807694590230e54641137576525b56e',
    'domain' => 'j.mp',
    'ua' => LWPx::ParanoidAgent->new(
        timeout   => 3,
    ),
);

my $shorten = $bitly->shorten('http://thisaintnews.com/view/picture/99788/Teacher-Should-Update-Vocab');
if ( $shorten->is_error ){
    die $shorten->status_code . ': ' . $shorten->status_txt;
}

my $short_url = $shorten->short_url;

my $nt = Net::Twitter->new(
    traits   => [qw/OAuth API::REST/],
    consumer_key        => 'blkIhk157s6OsvelvSR7g',
    consumer_secret     => '4IoQyndU51tdQUAFR8saSQGzR6lKKt3wkzs27NlMnk',
    access_token        => '182075761-gghyAjZlKKEE8OAR1IRpL3JiHfKIKSqKDwBJDks',
    access_token_secret => 'gv58yzNJa9CnyQpiDqxcSjowQ0EKjANC5XP2o',
    useragent_class => 'LWPx::ParanoidAgent',
    useragent_args => {
        timeout   => 3,
    },
);

my $availble_length = 140;
my $tweet;
$availble_length -= length( $short_url );

my $rt_msg = 'RT @thisaintnews ';
$availble_length -= length( $rt_msg );

warn $availble_length;

#TODO
#make avil length from title length (shorten) and short url
#assemble string
#leave room for "RT @thisaintnews "
#make twitter table store rt message so front end can just look it up if
#save data in table
#pull data out in promoted templates for tweet button

#my $result = $nt->update( $tweet );
