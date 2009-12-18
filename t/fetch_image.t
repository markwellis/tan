use strict;
use warnings;

use Test::More;
use Fetch::Image;

main();
done_testing();

sub main{
# add in a config hash here
# with things like max filesize
# ???
# profit
    my $fetcher = new_ok('Fetch::Image' => [], 'fetcher');

    my $url = 'http://thisaintnews.com/sys/images/logo.png';

    my $ua = $fetcher->setup_ua();
    isa_ok($ua, 'LWPx::ParanoidAgent', 'ua');
    my $head = $fetcher->head($ua, $url);

    isa_ok($head, 'HTTP::Response', 'head');

    ok($fetcher->validate_head($head), 'validate_head passed');

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
