use strict;
use warnings;
use Test::More;
use TAN;

my $model = TAN->model('ParseHTML');

my $embedder = TAN->model('Video');
my $youtube_embed_code = $embedder->url_to_embed('https://www.youtube.com/watch?v=VDss8V2OME4');

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
        'input' => '[i]not italic[/i] [b]not bold[/b] [url=http://google.com] not a url[/url] <br />',
        'expected' => '[i]not italic[/i] [b]not bold[/b] [url=http://google.com] not a url[/url] <br />',
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
        'name' => 'bbcode: nested quotes followed by single quote',
        'input' => "[quote user=user1]quote 1<br />[quote username=user2]quote 2[/quote][/quote][quote user=user3]quote 3[/quote]",
        'expected' => qq|<div class="quote_holder"><span class="quoted_username">user1 wrote:</span><div class="quote">quote 1<br /><div class="quote_holder"><span class="quoted_username">user2 wrote:</span><div class="quote">quote 2</div></div></div></div><div class="quote_holder"><span class="quoted_username">user3 wrote:</span><div class="quote">quote 3</div></div>|
    },
    {
        'name' => 'bbcode: quote video',
        'input' => "[quote user=user1][video]https://www.youtube.com/watch?v=VDss8V2OME4[/video][/quote]",
        'expected' => qq|<div class="quote_holder"><span class="quoted_username">user1 wrote:</span><div class="quote">${youtube_embed_code}</div></div>|,
    },
    {
        'name' => 'bbcode: quote html',
        'input' => qq|[quote user=user1]<div class="foo">bacon</div>[/quote]|,
        'expected' => qq|<div class="quote_holder"><span class="quoted_username">user1 wrote:</span><div class="quote"><div class="foo">bacon</div></div></div>|,
    },
    {
        'name' => 'bbcode: quote "username"',
        'input' => qq|[quote user="user1"]<div class="foo">bacon</div>[/quote]|,
        'expected' => qq|<div class="quote_holder"><span class="quoted_username">user1 wrote:</span><div class="quote"><div class="foo">bacon</div></div></div>|,
    },
    {
        'name' => 'bbcode: video',
        'input' => "[video]https://www.youtube.com/watch?v=VDss8V2OME4[/video]",
        'expected' => qq|${youtube_embed_code}|
    },
    {
        'name' => 'bbcode: video invalid',
        'input' => qq|[video]herp de derp what is this?[/video]|,
        'expected' => qq|[video]herp de derp what is this?[/video]|,
    },
    {
        'name' => 'bbcode: video hyperlink',
        'input' => qq|[video]<a href="https://www.youtube.com/watch?v=VDss8V2OME4">best video ever, derp</a>[/video]|,
        'expected' => qq|${youtube_embed_code}|
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
        'input' => qq|<a href="/etc/passwd?foo=goo&p=t&amp;r=q#beer">google</a>|,
        'expected' => qq|<a href="/etc/passwd?foo=goo&amp;p=t&amp;r=q#beer" rel="external nofollow">google</a>|,
    },
    {
        'name' => 'hss: entities',
        'input' => qq|'"&|,
        'expected' => qq|&#39;&quot;&amp;|,
    },
    {
        'name' => 'img src left alone',
        'input' => qq|<img src="http://thisaintnews.com" />|,
        'expected' => qq|<img src="http://thisaintnews.com" />|,
    },
    {
        'name' => 'text url to hyperlink',
        'input' => qq|http://thisaintnews.com?foo=bar&t=f#g|,
        'expected' => qq|<a href="http://thisaintnews.com?foo=bar&amp;t=f#g" rel="external nofollow">http://thisaintnews.com?foo=bar&amp;t=f#g</a>|,
    },
    {
        'name' => 'text video url to video (not in [video] block)',
        'input' => qq|https://www.youtube.com/watch?v=VDss8V2OME4|,
        'expected' => qq|${youtube_embed_code}|,
    },
    {
        'name' => 'hyperlink video url to video (not in [video] block)',
        'input' => qq|<a href="http://www.youtube.com/watch?v=VDss8V2OME4">video</a>|,
        'expected' => qq|${youtube_embed_code}|,
    },
    {
        'name' => 'javascript plain text url not converted to hyperlink',
        'input' => qq|javascript:alert('foo');|,
        'expected' => qq|javascript:alert(&#39;foo&#39;);|,
    },
    {
        'name' => 'smilies to images',
        'input' => qq|:) ;)<br/>;-)<br /> :\|<br />:beer :bacooooon :* B) :'(|,
        'expected' => qq{<img src="/static/smilies/smile.png" alt=":)" /> <img src="/static/smilies/wink.png" alt=";)" /><br /><img src="/static/smilies/wink.png" alt=";-)" /><br /> <img src="/static/smilies/neutral.png" alt=":|" /><br /><img src="/static/smilies/beer.png" alt=":beer" /> :bacooooon <img src="/static/smilies/kiss.png" alt=":*" /> <img src="/static/smilies/glasses-cool.png" alt="B)" /> <img src="/static/smilies/crying.png" alt=":&#39;(" />},
    },
    {
        'name' => 'don\'t double output with a html link',
        'input' => qq|Ah. Paul Watson. <a href="http://thisaintnews.com/view/link/120270/Olympics-2012-Conspiracies---The-BBC---VIDEO-#comment328306" rel="external nofollow">This Paul Watson</a>. Everything makes sense now.<br /><br />He's a bit of a barrel scraper.|,
        'expected' => qq{Ah. Paul Watson. <a href="http://thisaintnews.com/view/link/120270/Olympics-2012-Conspiracies---The-BBC---VIDEO-#comment328306" rel="external nofollow">This Paul Watson</a>. Everything makes sense now.<br /><br />He&#39;s a bit of a barrel scraper.},
    },
    {
        'name' => 'smilie with &#160; instead of space',
        'input' => qq|^ What makes it worse is the retailer is CarPhoneWarehouse, the possibility of having to send it back&#160; :suicide<br /><br />[quote user=DigitalAntichrist]<br />lol.&#160; Y'mean, it's many fragmented pieces are coming with Yodel...&#160; to a somewhat similar address... eventually...[/quote]<br /><br />lol, the Yodel guy may end up going back in fragmented pieces if this is the case&#160;&#160;:terror|,
        'expected' => qq|^ What makes it worse is the retailer is CarPhoneWarehouse, the possibility of having to send it back&#160; <img src="/static/smilies/suicide.gif" alt=":suicide" /><br /><br /><div class="quote_holder"><span class="quoted_username">DigitalAntichrist wrote:</span><div class="quote"><br />lol.&#160; Y&#39;mean, it&#39;s many fragmented pieces are coming with Yodel...&#160; to a somewhat similar address... eventually...</div></div><br /><br />lol, the Yodel guy may end up going back in fragmented pieces if this is the case&#160;&#160;<img src="/static/smilies/terror.png" alt=":terror" />|,
    },
    {
        'name' => 'smilie with &nbsp; instead of space',
        'input' => qq|^ What makes it worse is the retailer is CarPhoneWarehouse, the possibility of having to send it back&#160; :suicide<br /><br />[quote user=DigitalAntichrist]<br />lol.&#160; Y'mean, it's many fragmented pieces are coming with Yodel...&#160; to a somewhat similar address... eventually...[/quote]<br /><br />lol, the Yodel guy may end up going back in fragmented pieces if this is the case&#160;&nbsp;:terror|,
        'expected' => qq|^ What makes it worse is the retailer is CarPhoneWarehouse, the possibility of having to send it back&#160; <img src="/static/smilies/suicide.gif" alt=":suicide" /><br /><br /><div class="quote_holder"><span class="quoted_username">DigitalAntichrist wrote:</span><div class="quote"><br />lol.&#160; Y&#39;mean, it&#39;s many fragmented pieces are coming with Yodel...&#160; to a somewhat similar address... eventually...</div></div><br /><br />lol, the Yodel guy may end up going back in fragmented pieces if this is the case&#160;&nbsp;<img src="/static/smilies/terror.png" alt=":terror" />|,
    },
    {
        'name' => 'check url finder regex isnt being greedy',
        'input' => qq|<br />http://www.youtube.com/watch?v=VDss8V2OME4<br /><img src="http://venustodaymag.files.wordpress.com/2011/12/breasts-in-art2-cropped.jpg" />|,
        'expected' => qq|<br />${youtube_embed_code}<br /><img src="http://venustodaymag.files.wordpress.com/2011/12/breasts-in-art2-cropped.jpg" />|,
    },
    {
        'name' => 'check url finder isn\'t breaking img with alt same as src',
        'input' => qq|<br /><img alt="http://s2.postimg.org/isc0q4cp5/Lucy_Pinder_Superman.jpg" src="http://s2.postimg.org/isc0q4cp5/Lucy_Pinder_Superman.jpg" />|,
        'expected' => qq|<br /><img alt="http://s2.postimg.org/isc0q4cp5/Lucy_Pinder_Superman.jpg" src="http://s2.postimg.org/isc0q4cp5/Lucy_Pinder_Superman.jpg" />|,
    },
);

foreach my $test ( @tests ){
    cmp_ok( $model->parse($test->{'input'}), 'eq', $test->{'expected'}, $test->{'name'} );
}

done_testing;
