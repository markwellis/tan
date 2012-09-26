my $submit = new_ok('TAN::Model::Submit');
my ( $res, $c ) = ctx_request('/');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'poll',
    })
} 'Exception::Simple';
is($@, 'end_date is required', 'no end_date');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'poll',
        'end_date' => 3,
    })
} 'Exception::Simple';
is($@, 'title is required', 'no title');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'poll',
        'end_date' => "i am not a number",
    })
} 'Exception::Simple';
is($@, 'invalid end date', 'invalid end date');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'poll',
        'end_date' => 3,
    })
} 'Exception::Simple';
is($@, 'title is required', 'title is required');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'poll',
        'end_date' => 3,
        'title' => 'asdsad',
    })
} 'Exception::Simple';
is($@, 'picture_id is required', 'picture_id is required');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'poll',
        'end_date' => 3,
        'title' => 'asdsad',
        'picture_id' => 1,
    })
} 'Exception::Simple';
is($@, 'description is required', 'description is required');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'poll',
        'end_date' => 3,
        'title' => 'asdsad',
        'picture_id' => 1,
        'description' => 'foobar',
    })
} 'Exception::Simple';
is($@, 'tags is required', 'tags is required');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'poll',
        'end_date' => 3,
        'title' => 'asdsad',
        'picture_id' => 1,
        'tags' => 'asdasd',
        'description' => 'foobar',
        'answers' => 'lol not an array',
    })
} 'Exception::Simple';
is($@, 'answers not an array', 'answers not an array');

throws_ok{
    $submit->validate_and_prepare($c, {
        'type' => 'poll',
        'end_date' => 3,
        'title' => 'asdsad',
        'picture_id' => 1,
        'tags' => 'asdasd',
        'description' => 'foobar',
        'answers' => [
            'lol not an array',
        ]
    })
} 'Exception::Simple';
is($@, 'not enough answers provided', 'not enough answers provided');

#data in and out are the same in this case :)
my $data = {
    'type' => 'poll',
    'end_date' => '5',
    'picture_id' => 1,
    'description' => 'tghghhghghh',
    'tags' => 'asdasd',
    'title' => 'asdsad',
    'answers' => [
        1,
        2,
        '',
        0,
    ],
};
my $prepared = $submit->validate_and_prepare( $c, $data );

#edit $data to look like what $prepared *should* be...
$data->{'answers'} = [
    {
        'answer' => 1,
    },
    {
        'answer' => 2,
    },
    {
        'answer' => 0,
    },
];

#date format
$data->{'end_date'} = "DATE_ADD(NOW(), INTERVAL 5 DAY)";
#deref this coz we can't test it otherwise :!
$prepared->{'end_date'} = ${$prepared->{'end_date'}};

#remove coz we don't return this on prep
delete($data->{ 'type' });

is_deeply( $prepared, $data, "prepared data is correct");
