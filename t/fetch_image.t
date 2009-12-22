use strict;
use warnings;

use Test::More;
use Fetch::Image;

my $fetcher_config = {
    'max_filesize' => '2097152',
    'user_agent' => 'mozilla firefox yo',
};

my $fetcher = new_ok('Fetch::Image' => [$fetcher_config], 'fetcher');
my $base_url = 'http://thisaintnews.com';
my $ua = $fetcher->setup_ua();
isa_ok($ua, 'LWPx::ParanoidAgent', 'ua');

# this looks messy, because it is :(
# but it tests each part of the object speratly
# then tests the fetch routine
# also, tmtowtdi

{
    my $head = $fetcher->head($ua, $base_url);
    isa_ok($head, 'HTTP::Response', 'head');
}

{ # text fail
    my $head = $fetcher->head($ua, $base_url . '/tmp/fetch_image/text');
    is($fetcher->validate_head($head), 0, 'not an image');
    is($fetcher->{'error'}, 'Invalid content-type', 'Invalid content-type');
}

{ # large file
    my $head = $fetcher->head($ua, $base_url . '/tmp/fetch_image/large');
    is($fetcher->validate_head($head), 0, 'file too large');
    is($fetcher->{'error'}, 'Filesize exceeded', 'Filesize exceeded');
}

{ # 404
    my $head = $fetcher->head($ua, $base_url . '/thisfiledoesntexist');
    is($fetcher->validate_head($head), 0, 'file doesnt exist');
    is($fetcher->{'error'}, 'Transfer error', 'Transfer error');
}

{ # example.com
    my $head = $fetcher->head($ua, 'http://example.com/thisfiledoesntexist');
    is($fetcher->validate_head($head), 0, 'invalid domain');
    is($fetcher->{'error'}, 'Transfer error', 'Transfer error');
}

{ # allowed image
    my $head = $fetcher->head($ua, 'http://thisaintnews.com/sys/images/logo.png');
    ok($fetcher->validate_head($head), 'proper image');
}

{ # save temp
    ok(my $temp_file = $fetcher->save_tmp($ua, 'http://thisaintnews.com/sys/images/logo.png'), 'download to Temp::File');
    ok(-f $temp_file->filename, 'Temp::File ' . $temp_file->filename . ' exists');

    my $format = $fetcher->is_image($temp_file);
    ok($format, "Temp::File is a ${format}");
}

{ # save fake temp (should never happen)
    ok(my $temp_file = $fetcher->save_tmp($ua, 'http://thisaintnews.com/robots.txt'), 'download to Temp::File');

    #store filename so can check if its been unlinked
    my $temp_filename = $temp_file->filename;
    ok(-f $temp_filename, 'Temp::File ' . $temp_filename . ' exists');

    # check if is image, and temp::file is removed
    is($fetcher->is_image($temp_file), 0, "file isnt an image");
    is($fetcher->{'error'}, 'Not an image', 'Not an image');
    is(-f $temp_filename, undef, 'Temp::File no longer exists');
}

{ # move temp file to location
    # move_image
    ok(my $temp_file = $fetcher->save_tmp($ua, 'http://thisaintnews.com/sys/images/logo.png'), 'download to Temp::File');
    ok(-f $temp_file->filename, 'Temp::File ' . $temp_file->filename . ' exists');

    my $temp_filename = $temp_file->filename;

    my $format = $fetcher->is_image($temp_file);
    ok($format, "Temp::File is a ${format}");

    ok ($fetcher->save_file($temp_file, "/tmp/tmp.${format}"), 'file saved' );
    ok (-f "/tmp/tmp.${format}", 'save file exists');
    is (-f $temp_filename , undef, 'temp file doesnt exist');
    unlink("/tmp/tmp.${format}");
    is( -f "/tmp/tmp.${format}", undef, 'test save file unlinked');
}

{ # fetch failed (text file)
    is(my $filename = $fetcher->fetch($base_url, "${base_url}/tmp/fetch_image/text"), 0, "text file rejected");
    is($fetcher->{'error'}, 'Invalid content-type', 'Invalid content-type');
    is( -f $filename, undef, 'save file doesnt exist');
}

{ # fetch failed (large file)
    is(my $filename = $fetcher->fetch("${base_url}/tmp/fetch_image/large", '/tmp/file'), 0, "large file rejected");
    is($fetcher->{'error'}, 'Filesize exceeded', 'Filesize exceeded');
    is( -f $filename, undef, 'save file doesnt exist');
}

{ # 404
    is(my $filename = $fetcher->fetch("${base_url}/thisfiledoesntexist", '/tmp/file'), 0, "404 file rejected");
    is($fetcher->{'error'}, 'Transfer error', 'Transfer error');
    is( -f $filename, undef, 'save file doesnt exist');
}

{ # example.com
    is(my $filename = $fetcher->fetch('http://example.com/thisfiledoesntexist', '/tmp/file'), 0, "dns error rejected");
    is($fetcher->{'error'}, 'Transfer error', 'Transfer error');
    is( -f $filename, undef, 'save file doesnt exist');
}

{ # allowed image
    ok(my $filename = $fetcher->fetch('http://thisaintnews.com/sys/images/logo.png', '/tmp/file'), "image accepted");
    ok( -f $filename, 'save file exists');
    unlink($filename);
    is( -f $filename, undef, 'test save file unlinked');

}

{ # test defaults
    my $fetcher = new_ok('Fetch::Image' => [], 'fetcher');
    my $base_url = 'http://thisaintnews.com';
    my $ua = $fetcher->setup_ua();
    isa_ok($ua, 'LWPx::ParanoidAgent', 'ua');

    ok(my $filename = $fetcher->fetch('http://www.google.co.uk/images/firefox/sprite2.png', '/srv/http/TAN/root/static/user/pics/wibble'), "image accepted");
    ok( -f $filename, 'save file exists');
    unlink($filename);
    is( -f $filename, undef, 'test save file unlinked');
}

{ # test allowed_types
    my $fetcher_config = {
        'allowed_types' => {
            'image/jpeg' => 1,
        },
    };
    my $fetcher = new_ok('Fetch::Image' => [$fetcher_config], 'fetcher');
    my $base_url = 'http://thisaintnews.com';
    my $ua = $fetcher->setup_ua();
    isa_ok($ua, 'LWPx::ParanoidAgent', 'ua');

    is(my $filename = $fetcher->fetch('http://thisaintnews.com/sys/images/logo.png', '/tmp/file'), 0, "image type rejected");
    is($fetcher->{'error'}, 'Invalid content-type', 'Invalid content-type');
    is( -f $filename, undef, 'save deoesnt exist');
}

{ # test misc
    my $fetcher = new_ok('Fetch::Image' => [$fetcher_config], 'fetcher');
    my $base_url = 'http://thisaintnews.com';
    my $ua = $fetcher->setup_ua();
    isa_ok($ua, 'LWPx::ParanoidAgent', 'ua');

    is($fetcher->fetch('http://thisaintnews.com/sys/images/logo.png'), 0, "no savefile");
    is($fetcher->fetch(undef, '/tmp/tmpfile'), 0, "no url");
    is( -f '/tmp/tmpfile.png', undef, 'save doesnt exist');
}

{ # itunes fail
    my $fetcher = new_ok('Fetch::Image' => [$fetcher_config], 'fetcher');
    my $ua = $fetcher->setup_ua();
    isa_ok($ua, 'LWPx::ParanoidAgent', 'ua');

    is($fetcher->fetch('http://appldnld.apple.com.edgesuite.net/content.info.apple.com/iTunes8/061-6664.20090608.dfrtg/iTunesSetup.exe', '/tmp/itunes'), 0, "itunes.exe rejected");
    is($fetcher->{'error'}, 'Invalid content-type', 'Invalid content-type');
    is( -f '/tmp/itunes*', undef, 'save doesnt exist');
}

done_testing();
