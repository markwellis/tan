use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'TAN::Model::ParseHTML' };
my $model = new_ok('TAN::Model::ParseHTML');

my @tests = (
    {
        'name' => 'bbcode: quote',
        'input' => '[quote user=username]some quoted <br /> text[/quote] <br />',
        'expected' => '<div class="quote_holder"><span class="quoted_username">username wrote:</span><div class="quote">some quoted <br /> text</div></div> <br />',
    },
    {
        'name' => 'bbcode: 2 quotes',
        'input' => '[quote user=username1]text1[/quote] <br />[quote user=username2]text2[/quote]',
        'expected' => '<div class="quote_holder"><span class="quoted_username">username1 wrote:</span><div class="quote">text1</div></div> <br />'
            .'<div class="quote_holder"><span class="quoted_username">username2 wrote:</span><div class="quote">text2</div></div>',
    },
    {
        'name' => 'bbcode: invalid',
        'input' => '[i]not italic[/i] [b]not bold[/b] [url=http://google.com]not a url[/url] <br />',
        'expected' => '[i]not italic[/i] [b]not bold[/b] [url=http://google.com]not a url[/url] <br />',
    },
    {
        'name' => 'bbcode: unclosed',
        'input' => '[video]not italic yo momma eats cheese <br />',
        'expected' => '[video]not italic yo momma eats cheese <br />',
    },
    {
        'name' => 'bbcode: linebreak test',
        'input' => "[quote user=Tagtha] I'm not sure why but this may be the best\n picture ever <br /> [/quote] <br />\nbacon",
        'expected' => qq|<div class="quote_holder"><span class="quoted_username">Tagtha wrote:</span><div class="quote"> I&#39;m not sure why but this may be the best\n picture ever <br /> </div></div> <br />\nbacon|
    },
    {
        'name' => 'bbcode: nested quotes',
        'input' => "[quote user=user1]quote 1<br />[quote username=user2]quote 2[/quote][/quote]",
        'expected' => qq|<div class="quote_holder"><span class="quoted_username">user1 wrote:</span><div class="quote">quote 1<br /><div class="quote_holder"><span class="quoted_username">user2 wrote:</span><div class="quote">quote 2</div></div></div></div>|
    },
    {
        'name' => 'bbcode: video',
        'input' => "[video]https://www.youtube.com/watch?v=VDss8V2OME4[/video]",
        'expected' => qq|<iframe title="YouTube video player" width="450" height="370" src="http://www.youtube.com/embed/VDss8V2OME4" frameborder="0" allowfullscreen="1"></iframe>|
    },
    {
        'name' => 'bbcode: video invalid',
        'input' => qq|[video]herp de derp what is this?[/video]|,
        'expected' => qq|[video]herp de derp what is this?[/video]|,
    },
    {
        'name' => 'bbcode: video hyperlink',
        'input' => qq|[video]<a href="https://www.youtube.com/watch?v=VDss8V2OME4">best video ever, derp</a>[/video]|,
        'expected' => qq|<iframe title="YouTube video player" width="450" height="370" src="http://www.youtube.com/embed/VDss8V2OME4" frameborder="0" allowfullscreen="1"></iframe>|
    },
    {
        'name' => 'hss: rel="external nofollow" injection',
        'input' => qq|<a href="http://google.com">google</a>|,
        'expected' => qq|<a href="http://google.com" rel="external nofollow">google</a>|,
    },
    {
        'name' => 'hss: script tag removal',
        'input' => qq|<script>alert('hello');</script>bacon|,
        'expected' => qq|<!--filtered--><!--filtered-->bacon|,
    },
    {
        'name' => 'hss: onclick attr removal',
        'input' => qq|<a onclick="alert('bacon')" href="http://google.com">google</a>|,
        'expected' => qq|<a href="http://google.com" rel="external nofollow">google</a>|,
    },
    {
        'name' => 'hss: href javascript removal',
        'input' => qq|<a href="javascript:alert('bacon')">google</a>|,
        'expected' => qq|<a rel="external nofollow">google</a>|,
    },
    {
        'name' => 'hss: href invald uri',
        'input' => qq|<a href="file:///etc/passwd">google</a>|,
        'expected' => qq|<a rel="external nofollow">google</a>|,
    },
    {
        'name' => 'hss: href relative url',
        'input' => qq|<a href="/etc/passwd">google</a>|,
        'expected' => qq|<a href="/etc/passwd" rel="external nofollow">google</a>|,
    },
);

foreach my $test ( @tests ){
    cmp_ok( $model->parse($test->{'input'}), 'eq', $test->{'expected'}, $test->{'name'} );
}

done_testing;
