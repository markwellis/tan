my $submit = new_ok('TAN::Submit');
my ( $res, $c ) = ctx_request('/');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'link',
        'url' => 'http://thisaintnews.com',
        'title' => 'this is the title',
        'picture_id' => 1,
    })
} 'Exception::Simple';
is($@, 'description is required', 'no description');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'link',
        'url' => 'http://thisaintnews.com',
        'title' => 'this is the title',
        'description' => 'this is the description',
    })
} 'Exception::Simple';
is($@, 'picture_id is required', 'no picture_id');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'link',
        'picture_id' => 1,
        'title' => 'this is the title',
        'description' => 'this is the description',
    })
} 'Exception::Simple';
is($@, 'url is required', 'no url');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'link',
        'picture_id' => 1,
        'url' => 'http://thisaintnews.com',
        'description' => 'this is the description',
    })
} 'Exception::Simple';
is($@, 'title is required', 'no title');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'link',
        'picture_id' => 1,
        'url' => 'haha im an invalid url',
        'title' => 'this is the title',
        'description' => 'this is the description',
    })
} 'Exception::Simple';
is($@, 'invalid url', 'invalid url');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'link',
        'picture_id' => 1,
        'url' => 'http://thisaintnews.com',
        'title' => 'th',
        'description' => 'this is the description',
    })
} 'Exception::Simple';
is($@, 'title must be at least 3 characters', 'title too short');

throws_ok{
    my $error = $submit->validate_and_prepare($c, {
        'type' => 'link',
        'picture_id' => 1,
        'url' => 'http://thisaintnews.com',
        'title' => 'a'x256,
        'description' => 'this is the description',
    })
} 'Exception::Simple';
is($@, 'title must not exceed 255 characters', 'title too long');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'link',
        'picture_id' => 1,
        'url' => 'http://thisaintnews.com',
        'title' => 'this is the title',
        'description' => 'th',
    })
} 'Exception::Simple';
is($@, 'description must be at least 3 characters', 'description too short');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'link',
        'picture_id' => 1,
        'url' => 'http://thisaintnews.com',
        'title' => 'this is the title',
        'description' => 'a'x1001,
    })
} 'Exception::Simple';
is($@, 'description must not exceed 1000 characters', 'description too long');

throws_ok{
    $submit->validate_and_prepare( $c, {
        'type' => 'link',
        'picture_id' => 1,
        'url' => 'http://thisaintnes.com' . '/sdf'x400,
        'title' => 'th',
        'description' => 'this is the description',
    })
} 'Exception::Simple';
is($@, 'url must not exceed 400 characters', 'url too long');

throws_ok{
    $submit->validate_and_prepare( $c, {
        'type' => 'link',
        'picture_id' => 1,
        'url' => 'http://thisaintnews.com',
        'title' => 'this is the title',
        'description' => 'tghghhghghh',
    })
} 'Exception::Simple';
is($@, 'tags is required', 'no tags');

#data in and out are the same in this case :)
my $data = {
    'type' => 'link',
    'url' => 'http://thisaintnews.com',
    'title' => 'this is the title',
    'picture_id' => 1,
    'description' => 'tghghhghghh',
    'tags' => 'asdasd',
};
my $prepared = $submit->validate_and_prepare( $c, $data );

#remove coz we don't return this on prep
delete($data->{ 'type' });

is_deeply( $prepared, $data, "prepared data is correct");
