use strict;
use warnings;

use Test::More;
use HTML::Video::Embed;

my $embeder = new HTML::Video::Embed;

#youtube
diag('youtube');
is( $embeder->url_to_embed(
    'http://www.youtube.com/watch?v=xExSdzkZZB0'),  

    '<object data="http://www.youtube.com/v/xExSdzkZZB0" '
        .'style="width: 450px; height: 370px;" type="application/x-shockwave-flash">'
        .'<param value="transparent" name="wmode" />'
        .'<param value="http://www.youtube.com/v/xExSdzkZZB0" name="movie" /></object>',

    'youtube embed works'
);

is( $embeder->url_to_embed('http://www.youtube.com/watch?v=xExxSdzkZZB0'), undef, 'invalid v=');
is( $embeder->url_to_embed('http://www.youtube.com/watch?h=xExxSdzkZZB0'), undef, 'no v=');
is( $embeder->url_to_embed('http://www.y0utube.com/watch?h=xExxSdzkZZB0'), undef, 'y0utube, not youtube');

#liveleak
diag('liveleak');
is( $embeder->url_to_embed(
    'http://www.liveleak.com/view?i=ffc_1272800490'),

    '<object width="450" height="370"><param name="movie" value="http://www.liveleak.com/e/ffc_1272800490" />'
        .'<param name="wmode" value="transparent" />'
        .'<embed src="http://www.liveleak.com/e/ffc_1272800490" type="application/x-shockwave-flash" '
        .'wmode="transparent" width="450" height="370"></embed></object>',

    'liveleak embed works'
);

is( $embeder->url_to_embed('http://www.liveleak.com/view?i=ffc_12728770049090'), undef, 'invalid i=');
is( $embeder->url_to_embed('http://www.liveleak.com/view?v=ffc_12728004900'), undef, 'no i=');
is( $embeder->url_to_embed('http://www.l1veleak.com/view?i=ffc_12728004900'), undef, 'l1veleak, not liveleak');

#google
diag('google');
is( $embeder->url_to_embed(
    'http://video.google.com/videoplay?docid=-2912878405399014351#'),

    '<embed id="VideoPlayback"'
        .' src="http://video.google.com/googleplayer.swf?'
        .'docid=-2912878405399014351' 
        .'&hl=en&fs=true" style="width:450px;height:370px"'
        .' allowFullScreen="true"'
        .' allowScriptAccess="always"'
        .' type="application/x-shockwave-flash">'
        .'</embed>'
    ,

    'google embed works'
);

is( $embeder->url_to_embed('http://video.google.com/videoplay?docid=-2928784053jj99014351#'), undef, 'invalid docid=');
is( $embeder->url_to_embed('http://video.google.com/videoplay?d0cid=-2912878405399014351#'), undef, 'no docid=');
is( $embeder->url_to_embed('http://video.g0ogle.com/videoplay?docid=-2912878405399014351#'), undef, 'g0ogle, not goolge');

#yahooo
diag('yahoo');
is( $embeder->url_to_embed(
    'http://uk.video.yahoo.com/watch/6421277/16650873'),

    '<object width="450" height="370"><param name="movie" value="http://d.yimg.com/static.video.yahoo.com/yep/YV_YEP.swf?ver=2.2.46" /><param name="allowFullScreen" value="true" /><param name="AllowScriptAccess" VALUE="always" /><param name="bgcolor" value="#000000" /><param name="flashVars" value="id=16650873&vid=6421277&lang=en-gb&intl=uk&embed=1" /><embed src="http://d.yimg.com/static.video.yahoo.com/yep/YV_YEP.swf?ver=2.2.46" type="application/x-shockwave-flash" width="450" height="370" allowFullScreen="true" AllowScriptAccess="always" bgcolor="#000000" flashVars="id=16650873&vid=6421277&lang=en-gb&intl=uk&embed=1" ></embed></object>',

    'yahoo embed works'
);

is( $embeder->url_to_embed('http://uk.video.yahoo.com/watch/6420873'), undef, 'invalid url');
is( $embeder->url_to_embed('http://uk.video.yahoo.com/watch//16650873'), undef, 'no seg 1');
is( $embeder->url_to_embed('http://uk.video.yah0o.com/watch/6421277/16650873'), undef, 'yah0o, not yahoo');
done_testing();
