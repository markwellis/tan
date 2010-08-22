use strict;
use warnings;

use Test::More;
use HTML::Video::Embed;

my $embeder = new HTML::Video::Embed({
    'width' => 450,
    'height' => 370,
});

#youtube
diag('youtube');
is( $embeder->url_to_embed('http://www.youtube.com/watch?v=xExSdzkZZB0'),  

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
is( $embeder->url_to_embed('http://www.liveleak.com/view?i=ffc_1272800490'),

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
is( $embeder->url_to_embed('http://video.google.com/videoplay?docid=-2912878405399014351#'),

    '<embed id="VideoPlayback"'
        .' src="http://video.google.com/googleplayer.swf?'
        .'docid=-2912878405399014351' 
        .'&hl=en&fs=true" style="width:450px;height:370px"'
        .' allowFullScreen="true"'
        .' type="application/x-shockwave-flash">'
        .'</embed>'
    ,

    'google embed works'
);

is( $embeder->url_to_embed('http://video.google.com/videoplay?docid=*()#'), undef, 'invalid docid=');
is( $embeder->url_to_embed('http://video.google.com/videoplay?d0cid=-2912878405399014351#'), undef, 'no docid=');
is( $embeder->url_to_embed('http://video.g0ogle.com/videoplay?docid=-2912878405399014351#'), undef, 'g0ogle, not goolge');

#yahooo
diag('yahoo');
is( $embeder->url_to_embed('http://uk.video.yahoo.com/watch/6421277/16650873'),

    '<object width="450" height="370"><param name="movie" value="http://d.yimg.com/static.video.yahoo.com/yep/YV_YEP.swf?ver=2.2.46" /><param name="allowFullScreen" value="true" /><param name="bgcolor" value="#000000" /><param name="flashVars" value="id=16650873&vid=6421277&lang=en-gb&intl=uk&embed=1" /><embed src="http://d.yimg.com/static.video.yahoo.com/yep/YV_YEP.swf?ver=2.2.46" type="application/x-shockwave-flash" width="450" height="370" allowFullScreen="true" bgcolor="#000000" flashVars="id=16650873&vid=6421277&lang=en-gb&intl=uk&embed=1" ></embed></object>',

    'yahoo embed works'
);

is( $embeder->url_to_embed('http://uk.video.yahoo.com/watch/6420873'), undef, 'invalid url');
is( $embeder->url_to_embed('http://uk.video.yahoo.com/watch//16650873'), undef, 'no seg 1');
is( $embeder->url_to_embed('http://uk.video.yah0o.com/watch/6421277/16650873'), undef, 'yah0o, not yahoo');

#spiked
diag('spikedhumor');
is( $embeder->url_to_embed('http://www.spikedhumor.com/articles/204009/Maher-You-Don-t-Care-About-the-Debt.html'),

    '<embed src="http://www.spikedhumor.com/player/vcplayer.swf?file=http://www.spikedhumor.com/videocodes/204009/data.xml&auto_play=false" quality="high" scale="noscale" bgcolor="#000000" width="450" height="370" align="middle" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />',

    'spikedhumor embed works'
);

is( $embeder->url_to_embed('http://www.spikedhumor.com/watch/6420873'), undef, 'invalid url');
is( $embeder->url_to_embed('http://www.sp1kedhumor.com/articles//Maher-You-Don-t-Care-About-the-Debt.html'), undef, 'no video id');
is( $embeder->url_to_embed('http://www.sp1kedhumor.com/articles/204009/Maher-You-Don-t-Care-About-the-Debt.html'), undef, 'sp1kedhumor, not spikedhumor');

#college
diag('collegehumor');
is( $embeder->url_to_embed('http://www.collegehumor.com/video:1930495'),

    '<object type="application/x-shockwave-flash" data="http://www.collegehumor.com/moogaloop/moogaloop.swf?clip_id=1930495&fullscreen=1" width="450" height="370" ><param name="allowfullscreen" value="true"/><param name="wmode" value="transparent"/><param name="movie" quality="best" value="http://www.collegehumor.com/moogaloop/moogaloop.swf?clip_id=1930495&fullscreen=1"/><embed src="http://www.collegehumor.com/moogaloop/moogaloop.swf?clip_id=1930495&fullscreen=1" type="application/x-shockwave-flash" wmode="transparent" width="450" height="370"></embed></object>',

    'collegehumor embed works'
);

is( $embeder->url_to_embed('http://www.collegehumor.com/vdeo:1930495'), undef, 'invalid url');
is( $embeder->url_to_embed('http://www.collegehumor.com/video:'), undef, 'no video id');
is( $embeder->url_to_embed('http://www.c0llegehumor.com/video:1930495'), undef, 'c0llegehumor, not c0llegehumor');

#funnyordie
diag('funnyordie');
is( $embeder->url_to_embed('http://www.funnyordie.com/videos/1ab8850305/spook-hunters'),

    '<object width="450" height="370" id="ordie_player_1ab8850305"><param name="movie" value="http://player.ordienetworks.com/flash/fodplayer.swf" /><param name="flashvars" value="key=1ab8850305" /><param name="allowfullscreen" value="true" /><embed width="450" height="370" flashvars="key=1ab8850305" allowfullscreen="true" quality="high" src="http://player.ordienetworks.com/flash/fodplayer.swf" name="ordie_player_1ab8850305" type="application/x-shockwave-flash"></embed></object>',

    'funnyordie embed works'
);

is( $embeder->url_to_embed('http://www.funnyordie.com/video/1ab8850305/spook-hunters'), undef, 'invalid url');
is( $embeder->url_to_embed('http://www.funnyordie.com/videos//spook-hunters'), undef, 'no video id');
is( $embeder->url_to_embed('http://www.funny0rdie.com/videos/1ab8850305/spook-hunters'), undef, 'funny0rdie, not funnyordie');

#metacafe
diag('metacafe');
is( $embeder->url_to_embed('http://www.metacafe.com/watch/4515418/nuts_celebrity_mistaken_identity_craig_t_squirrel_cart/'),

    '<embed src="http://www.metacafe.com/fplayer/4515418/unimportant_info_i_hope.swf" width="450" '
        .'height="370" wmode="transparent" pluginspage="http://www.macromedia.com/go/getflashplayer" '
        .'type="application/x-shockwave-flash" allowFullScreen="true" name="Metacafe_4515418"></embed>',

    'metacafe embed works'
);

is( $embeder->url_to_embed('http://www.metacafe.com/watch/"£$sdf/nuts_celebrity_mistaken_identity_craig_t_squirrel_cart/'), undef, 'invalid url');
is( $embeder->url_to_embed('http://www.metacafe.com/watch//nuts_celebrity_mistaken_identity_craig_t_squirrel_cart/'), undef, 'no video id');
is( $embeder->url_to_embed('http://www.m3tacafe.com/watch/4515418/nuts_celebrity_mistaken_identity_craig_t_squirrel_cart/'), undef, 'm3tacafe, not metacafe');

#dailymotion
diag('dailymotion');
is( $embeder->url_to_embed('http://www.dailymotion.com/video/xbrozz_the-worst-5-things-to-say-policemen_fun'),

    '<object width="450" height="370"><param name="movie" value="http://www.dailymotion.com/swf/video/xbrozz" /><param name="allowFullScreen" value="true" /><embed type="application/x-shockwave-flash" src="http://www.dailymotion.com/swf/video/xbrozz" width="450" height="370" allowfullscreen="true"></embed></object>',

    'dailymotion embed works'
);

is( $embeder->url_to_embed('http://www.dailymotion.com/videoxbrozz_the-worst-5-things-to-say-policemen_fun'), undef, 'invalid url');
is( $embeder->url_to_embed('http://www.dailymotion.com/video/_the-worst-5-things-to-say-policemen_fun'), undef, 'no video id');
is( $embeder->url_to_embed('http://www.da1lymotion.com/video/xbrozz_the-worst-5-things-to-say-policemen_fun'), undef, 'da1lymotion, not dailymotion');

#vimeo
diag('vimeo');
is( $embeder->url_to_embed('http://vimeo.com/12279924'),

    '<object width="450" height="370"><param name="allowfullscreen" value="true" /><param name="movie" value="http://vimeo.com/moogaloop.swf?clip_id=12279924&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" /><embed src="http://vimeo.com/moogaloop.swf?clip_id=12279924&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" width="450" height="370"></embed></object>',

    'vimeo embed works'
);

is( $embeder->url_to_embed('http://vimeo.com/fhfhgfhgfh'), undef, 'invalid url');
is( $embeder->url_to_embed('http://vimeo.com/'), undef, 'no video id');
is( $embeder->url_to_embed('http://v1meo.com/12279924'), undef, 'v1meo, not vimeo');

#megavideo
diag('megavideo');
is( $embeder->url_to_embed('http://www.megavideo.com/?v=0BILAIF2'),

    '<object width="450" height="370"><param name="movie" value="http://www.megavideo.com/v/0BILAIF2" /><param name="allowFullScreen" value="true" /><embed src="http://www.megavideo.com/v/0BILAIF2" type="application/x-shockwave-flash" allowfullscreen="true" width="450" height="370"></embed></object>',

    'megavideo embed works'
);

is( $embeder->url_to_embed('http://www.megavideo.com/?c=6JACS1RB'), undef, 'invalid url');
is( $embeder->url_to_embed('http://www.megavideo.com'), undef, 'no video id');
is( $embeder->url_to_embed('http://www.m3gavideo.com/?v=6JACS1RB'), undef, 'm3gavideo, not megavideo');

#kontraband
diag('kontraband');
is( $embeder->url_to_embed('http://www.kontraband.com/videos/23299/I-Kissed-A-Nerd/'),

    '<embed height="370" width="450" flashvars="file=http://208.116.9.205/10/content/23299/450.flv" usefullscreen="true" allowfullscreen="true" quality="high" name="kbvideo" id="kbvideo" src="http://www.kontraband.com/show/4.5.swf" type="application/x-shockwave-flash"/>',

    'kontraband embed works'
);

is( $embeder->url_to_embed('http://www.kontraband.com/videos/fgh23299/I-Kissed-A-Nerd/'), undef, 'invalid url');
is( $embeder->url_to_embed('http://www.kontraband.com/videos/'), undef, 'no video id');
is( $embeder->url_to_embed('http://www.kuntraband.com/videos/23299/I-Kissed-A-Nerd/'), undef, 'kuntraband, not kontraband');

done_testing();
