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
        qq|[youtube]<a href="https://www.youtube.com/watch?v=VDss8V2OME4">best video ever, derp</a>[/youtube]<div class="foobar"><span>bacon</span><p>asdasd</p><br />|,
        qq|[video]<a href="https://www.youtube.com/watch?v=VDss8V2OME4">best video ever, derp</a>[/video]<div class="foobar"><span>bacon</span><p>asdasd</p><br />|,
        "bbcode: [youtube]hyperlink to [video]hyperlink",
    ],
    [
        qq|<div><div class="quote_holder"><span class="quoted_username">user1 wrote:</span><div class="quote"><div class="foo">bacon</div></div></div>|,
        qq|[quote user=user1]<div class="foo">bacon</div>[/quote]|,
        "quote: quote to bbcode",
    ],
    [
        qq|<div class="quote_holder"><span class="quoted_username">user1 wrote:</span><div class="quote">[video]https://www.youtube.com/watch?v=VDss8V2OME4[/video]</div></div>|,
        "[quote user=user1][video]https://www.youtube.com/watch?v=VDss8V2OME4[/video][/quote]",
        "quote: quote video to bbcode",
    ],
    [
        qq|<div class="quote_holder"><span class="quoted_username">user1 wrote:</span><div class="quote">quote 1<br /><div class="quote_holder"><span class="quoted_username">user2 wrote:</span><div class="quote">quote 2</div></div></div></div><div class="quote_holder"><span class="quoted_username">user3 wrote:</span><div class="quote">quote 3</div></div>|,
        "[quote user=user1]quote 1<br />[quote username=user2]quote 2[/quote][/quote][quote user=user3]quote 3[/quote]",
        'quote: nested quotes followed by single quote to bbcode',
    ],
];

foreach my $test ( @{ $tests } ){
    cmp_ok( $converter->parse($test->[0]), 'eq', $test->[1], $test->[2] );
}

done_testing;
