use strict;
use warnings;

use Test::More;
use Test::Exception;

use Fetch::Image;

my $fetcher_config = {
    'max_filesize' => '51200',
    'user_agent' => 'mozilla firefox yo',
};

my $fetcher = new_ok('Fetch::Image' => [$fetcher_config], 'fetcher');

# text file
throws_ok{
    $fetcher->fetch( 'http://www.ietf.org/rfc/rfc3751.txt' );
} qr/invalid content-type/, 'not an image';

# large file (50k+)
throws_ok{
    $fetcher->fetch( 'http://i.zdnet.com/blogs/nasa-small.bmp' );
} qr/filesize exceeded/, 'file too large';

# invalid url
throws_ok{
    $fetcher->fetch( 'something un urlish' );
} qr/invalid url/, 'invalid url';

# 404
throws_ok{
    $fetcher->fetch( 'http://thisaintnews.com/thisfileisntreal56332421' );
} qr/transfer error/, 'error 404';

# invalid domain
throws_ok{
    $fetcher->fetch( 'http://example.com/thisfileisntreal56332421' );
} qr/transfer error/, 'invalid domain';

# proper image
{
    my $image_info;
    lives_ok { $image_info = $fetcher->fetch( 'http://thisaintnews.com/static/images/logo.png' ) } 'proper image';
    isa_ok( $image_info->{'temp_file'}, 'File::Temp', 'image isa tempfile' );
    is( $image_info->{'file_ext'}, 'png', 'correct filetype' );
}

# save fake temp (should never happen)
{
    my $ua = $fetcher->setup_ua('http://thisaintnews.com/robots.txt');
    throws_ok{
        ok( $fetcher->save($ua, 'http://thisaintnews.com/robots.txt'), 'download to Temp::File');
    } qr/not an image/, 'not an image';
}

# test allowed_types
{
    my $fetcher_config = {
        'allowed_types' => {
            'image/jpeg' => 1,
        },
    };
    my $fetcher = new_ok('Fetch::Image' => [$fetcher_config], 'fetcher');
    throws_ok{
        $fetcher->fetch('http://thisaintnews.com/static/images/logo.png');
    } qr/invalid content-type/, 'invalid content-type';
}

done_testing;
