use strict;
use warnings;

use Test::More;
use Fetch::Image;

main();
done_testing();

sub main{
    my $fetcher_config = {
        'max_filesize' => '2097152',
    };
    my $fetcher = new_ok('Fetch::Image' => [$fetcher_config], 'fetcher');
    my $base_url = 'http://thisaintnews.com';
    my $ua = $fetcher->setup_ua();
    isa_ok($ua, 'LWPx::ParanoidAgent', 'ua');

    
    my $head = $fetcher->head($ua, $base_url);
    isa_ok($head, 'HTTP::Response', 'head');

#this looks messy, because it is :(
#
# text fail
    $head = $fetcher->head($ua, $base_url . '/tmp/fetch_image/text');
    is($fetcher->validate_head($head), 0, 'not an image');

# large file
    $head = $fetcher->head($ua, $base_url . '/tmp/fetch_image/large');
    is($fetcher->validate_head($head), 0, 'file too large');

# 404
    $head = $fetcher->head($ua, $base_url . '/thisfiledoesntexist');
    is($fetcher->validate_head($head), 0, 'file doesnt exist');

# example.com
    $head = $fetcher->head($ua, 'http://example.com/thisfiledoesntexist');
    is($fetcher->validate_head($head), 0, 'invalid domain');

# allowed image
    $head = $fetcher->head($ua, 'http://thisaintnews.com/sys/images/logo.png');
    ok($fetcher->validate_head($head), 'proper image');

    # tmp_save
    # is_image
    #  pass
    #  fail
    # move_image


#real image
#invalid domain
#long delay
#invalid format
#many redirects
#http error
#save error
#tmp_file deleted
#save_file not deleted

}
