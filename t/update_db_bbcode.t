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
        qq|[youtube]<a href="https://www.youtube.com/watch?v=VDss8V2OME4">best video ever, derp</a>[/youtube]<div class="foobar"><span>bacon</span>asdasd</div>|,
        qq|[video]<a href="https://www.youtube.com/watch?v=VDss8V2OME4">best video ever, derp</a>[/video]<div class="foobar"><span>bacon</span>asdasd</div>|,
        "bbcode: [youtube]hyperlink to [video]hyperlink",
    ],
    [
        qq|<div class="quote_holder"><span class="quoted_username">user1 wrote:</span><div class="quote"><div class="foo">bacon</div></div></div>|,
        qq|[quote user=user1]<div class="foo">bacon</div>[/quote]|,
        "quote: quote to bbcode",
    ],
    [
        qq|&lt;sdfsdf&gt;<div class="quote_holder"><span class="quoted_username">user1 wrote:</span><div class="quote">[video]https://www.youtube.com/watch?v=VDss8V2OME4[/video]</div></div>|,
        "&lt;sdfsdf&gt;[quote user=user1][video]https://www.youtube.com/watch?v=VDss8V2OME4[/video][/quote]",
        "quote: quote video to bbcode",
    ],
    [
        qq|<div class="quote_holder"><span class="quoted_username">user1 wrote:</span><div class="quote">quote 1<br /><div class="quote_holder"><span class="quoted_username">user2 wrote:</span><div class="quote">quote 2</div></div></div></div><div class="quote_holder"><span class="quoted_username">user3 wrote:</span><div class="quote">quote 3</div></div>|,
        "[quote user=user1]quote 1<br />[quote user=user2]quote 2[/quote][/quote][quote user=user3]quote 3[/quote]",
        'quote: nested quotes followed by single quote to bbcode',
    ],
    [
        qq|<p>bacon face</p><div class="cheese">sdssdsdfsdf</div><ul><li>sdfsdf</li><li>gfhgfh</li><li>qweqwe</li></ul>|,
        qq|<p>bacon face</p><div class="cheese">sdssdsdfsdf</div><ul><li>sdfsdf</li><li>gfhgfh</li><li>qweqwe</li></ul>|,
        'normal html is untouched'
    ],
    [
        qq|[quote user="psidust42
            <div class="quote_holder">
            <div class="quote"><br />
            Mr Wizard was a 1950's show where a man called Mr. Wizard (Don Herbert to be exact) did science for all the viewers out there in TV land. As for Tooter Turtle, well we don't need no Mortimer Snerd wannabees hangin 'round this here thread.</div>
            </div>
            �<br /><br /><br />
            [/quote] <br /><br />
            Yeah I know who the black and white Mr Wizard was.� You said "simon" which made me think of Sherman, then Mr Peabody, Then the other Mr Wizard and then the turtle then Rocky and Bullwinkle then Mechanical Metal Munching Mice from the Moon then how hot Natasha Fatale was ....Now I'm thinking about Tennessee� Tuxedo, You know how that goes. What time is it?<br />|,
        qq|[quote user="psidust42 [quote user=] Mr Wizard was a 1950's show where a man called Mr. Wizard (Don Herbert to be exact) did science for all the viewers out there in TV land. As for Tooter Turtle, well we don't need no Mortimer Snerd wannabees hangin 'round this here thread.[/quote] �<br /><br /><br /> [/quote] <br /><br /> Yeah I know who the black and white Mr Wizard was.� You said "simon" which made me think of Sherman, then Mr Peabody, Then the other Mr Wizard and then the turtle then Rocky and Bullwinkle then Mechanical Metal Munching Mice from the Moon then how hot Natasha Fatale was ....Now I'm thinking about Tennessee� Tuxedo, You know how that goes. What time is it?<br />|,
        'quote: invalid quote',
    ],
    [
        qq|[youtube]&lt;object width="425" height="344"&gt;&lt;param name="movie" value="<a href="http://www.youtube.com/v/KrapC2a_3Xg&amp;hl=en&amp;fs=1&amp;">http://www.youtube.com/v/KrapC2a_3Xg&amp;hl=en&amp;fs=1&amp;"&gt;&lt;/param&gt;&lt;param</a> name="allowFullScreen" value="true"&gt;&lt;/param&gt;&lt;param name="allowscriptaccess" value="always"&gt;&lt;/param&gt;&lt;embed src="<a href="http://www.youtube.com/v/KrapC2a_3Xg&amp;hl=en&amp;fs=1">http://www.youtube.com/v/KrapC2a_3Xg&amp;hl=en&amp;fs=1</a>&amp;" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"&gt;&lt;/embed&gt;&lt;/object&gt;[/youtube]|,
        qq|[video]&lt;object width="425" height="344"&gt;&lt;param name="movie" value="<a href="http://www.youtube.com/v/KrapC2a_3Xg&amp;hl=en&amp;fs=1&amp;">http://www.youtube.com/v/KrapC2a_3Xg&amp;hl=en&amp;fs=1&amp;&quot;&gt;&lt;/param&gt;&lt;param</a> name="allowFullScreen" value="true"&gt;&lt;/param&gt;&lt;param name="allowscriptaccess" value="always"&gt;&lt;/param&gt;&lt;embed src="<a href="http://www.youtube.com/v/KrapC2a_3Xg&amp;hl=en&amp;fs=1">http://www.youtube.com/v/KrapC2a_3Xg&amp;hl=en&amp;fs=1</a>&amp;" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"&gt;&lt;/embed&gt;&lt;/object&gt;[/video]|,
        qq|youtube: retarded input|,
    ]
];

foreach my $test ( @{ $tests } ){
    cmp_ok( $converter->parse($test->[0]), 'eq', $test->[1], $test->[2] );
}

done_testing;
