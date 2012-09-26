my $submit = new_ok('TAN::Model::Submit');
my ( $res, $c ) = ctx_request('/');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'picture',
    })
} 'Exception::Simple';
is($@, 'either upload or remote must be provided', 'no upload or remote');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'picture',
        'remote' => 'http://thisaintnews.com/static/images/logo.png',
    })
} 'Exception::Simple';
is($@, 'title is required', 'no title');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'picture',
        'remote' => 'http://thisaintnews.com/static/images/logo.png',
        'title' => 'title',
    })
} 'Exception::Simple';
is($@, 'tags is required', 'no tags');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'picture',
        'remote' => 'http://thisaintnews.com/static/images/logo.png',
        'title' => 'title',
    })
} 'Exception::Simple';
is($@, 'tags is required', 'no tags');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'picture',
        'remote' => 'htp://.com/static/images/logo.png',
        'title' => 'title',
    })
} 'Exception::Simple';
is($@, 'invalid url', 'invalid url');

{
    my $prepared = $submit->validate_and_prepare($c, {
        'type' => 'picture',
        'remote' => 'http://thisaintnews.com/static/images/logo.png',
        'title' => 'title',
        'tags' => 'tags',
    });

    #this isnt v nice coz we're not testing filename, however the time its made at is un predictable
    delete($prepared->{'filename'});
    is_deeply( $prepared, {
          'sha512sum' => 'd5d82356c38e8f8137e0b72fd4618ab07dba1e8f867716c994524c9159aae6cbb81ce04626cc78e0f0da757c5d9bc1b654c629c92e3306438633722fde430b14',
          'x' => 400,
          'description' => undef,
          'size' => '39.2568359375',
          'tags' => 'tags',
          'y' => 75,
          'title' => 'title',
        },
        "prepared data is correct",
    );
}
