use 5.014;
use Test::More;

BEGIN { use_ok 'TAN::BBcode::Converter' };
my $converter = new_ok('TAN::BBcode::Converter');

my $tests = [
    [
        "[youtube]VDss8V2OME4[/youtube]",
        "[video]http://www.youtube.com/watch?v=VDss8V2OME4[/video]",
        "bbcode: [youtube]id to [video]url",
    ],
    [
        "[youtube]https://www.youtube.com/watch?v=VDss8V2OME4[/youtube]",
        "[video]https://www.youtube.com/watch?v=VDss8V2OME4[/video]",
        "bbcode: [youtube]url to [video]url",
    ],
    [
        "blah blah blah [youtube]https://www.youtube.com/watch?v=VDss8V2OME4[/youtube] boo boo boo",
        "blah blah blah [video]https://www.youtube.com/watch?v=VDss8V2OME4[/video] boo boo boo",
        "bbcode: [youtube]url to [video]url",
    ],
    [
        qq|[youtube]<a href="https://www.youtube.com/watch?v=VDss8V2OME4">best video ever, derp</a>[/youtube]|,
        qq|[video]<a href="https://www.youtube.com/watch?v=VDss8V2OME4">best video ever, derp</a>[/video]|,
        "bbcode: [youtube]hyperlink to [video]hyperlink",
    ],
];

foreach my $test ( @{ $tests } ){
    cmp_ok( $converter->parse($test->[0]), 'eq', $test->[1], $test->[2] );
}

done_testing;
