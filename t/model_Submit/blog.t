my $submit = new_ok('TAN::Model::Submit');
my ( $res, $c ) = ctx_request('/');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'blog',
        'title' => 'this is the title',
        'picture_id' => 1,
        'details' => 'this is the blog details',
    })
} 'Exception::Simple';
is($@, 'description is required', 'no description');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'blog',
        'title' => 'this is the title',
        'details' => 'this is the blog details',
        'description' => 'this is the description',
    })
} 'Exception::Simple';
is($@, 'picture_id is required', 'no picture_id');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'blog',
        'title' => 'this is the title',
        'picture_id' => 1,
        'description' => 'this is the description',
    })
} 'Exception::Simple';
is($@, 'details is required', 'no details');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'blog',
        'picture_id' => 1,
        'details' => 'this is the blog details',
        'description' => 'this is the description',
    })
} 'Exception::Simple';
is($@, 'title is required', 'no title');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'blog',
        'picture_id' => 1,
        'title' => 'i am the title',
        'details' => 'im too short',
        'description' => 'this is the description',
    })
} 'Exception::Simple';
is($@, 'details must be at least 20 characters', 'details too short');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'blog',
        'picture_id' => 1,
        'details' => 'this is the blog details',
        'title' => 'th',
        'description' => 'this is the description',
    })
} 'Exception::Simple';
is($@, 'title must be at least 3 characters', 'title too short');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'blog',
        'picture_id' => 1,
        'details' => 'this is the blog details',
        'title' => 'a'x256,
        'description' => 'this is the description',
    })
} 'Exception::Simple';
is($@, 'title must not exceed 255 characters', 'title too long');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'blog',
        'picture_id' => 1,
        'details' => 'this is the blog details',
        'title' => 'this is the title',
        'description' => 'th',
    })
} 'Exception::Simple';
is($@, 'description must be at least 3 characters', 'description too short');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'blog',
        'picture_id' => 1,
        'details' => 'this is the blog details',
        'title' => 'this is the title',
        'description' => 'a'x1001,
    })
} 'Exception::Simple';
is($@, 'description must not exceed 1000 characters', 'description too long');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'blog',
        'picture_id' => 1,
        'details' => 'this is the blog details',
        'title' => 'this is the title',
        'description' => 'tghghhghghh',
    })
} 'Exception::Simple';
is($@, 'tags is required', 'no tags');

#data in and out are the same in this case :)
my $data = {
    'type' => 'blog',
    'details' => 'this is the blog details',
    'title' => 'this is the title',
    'picture_id' => 1,
    'description' => 'tghghhghghh',
    'tags' => 'asdasd',
};
my $prepared = $submit->validate_and_prepare( $c, $data );

#remove coz we don't return this on prep
delete($data->{ 'type' });

is_deeply( $prepared, $data, "prepared data is correct");
