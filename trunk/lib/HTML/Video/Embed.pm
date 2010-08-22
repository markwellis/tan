package HTML::Video::Embed;
use Moose;

use URI;
use URI::QueryParam;
use URI::Escape::XS;

use Data::Validate::URI qw/is_uri/;
use LWPx::ParanoidAgent;

has 'width' => (
    'is' => 'rw',
    'isa' => 'Num',
    'default' => '450',
);

has 'height' => (
    'is' => 'rw',
    'isa' => 'Num',
    'default' => '370',
);

has '_videos' => (
    'is' => 'ro',
    'isa' => 'HashRef[HashRef]',
    'lazy_build' => 1,
    'init_arg' => undef,
);

sub _build__videos{
    return {
        '_youtube' => {
            'domain_reg' => qr/youtube\.com/,
            'validate_reg' => qr|^[a-zA-Z0-9-_]{11}$|,
        },
        '_liveleak' => {
            'domain_reg' => qr/liveleak\.com/,
            'validate_reg' => qr|^\w{3}_\w{10}$|,
        },
        '_google' => {
            'domain_reg' => qr/google\.com/,
            'validate_reg' => qr|^-?\w+$|,
        },
        '_yahoo' => {
            'domain_reg' => qr/video\.yahoo\.com/,
            'validate_reg' => qr|^/watch/(\d+)/(\d+)|,
        },
        '_spikedhumor' => {
            'domain_reg' => qr/spikedhumor\.com/,
            'validate_reg' => qr|^/articles/(\d+)/.*$|,
        },
        '_collegehumor' => {
            'domain_reg' => qr/collegehumor\.com/,
            'validate_reg' => qr|^/video:(\d+)|,
        },
        '_funnyordie' => {
            'domain_reg' => qr/funnyordie\.com/,
            'validate_reg' => qr|^/videos/(\w+)/.*|,
        },
        '_metacafe' => {
            'domain_reg' => qr/metacafe\.com/,
            'validate_reg' => qr|^/watch/(\d+)/.*|,
        },
        '_dailymotion' => {
            'domain_reg' => qr/dailymotion\.com/,
            'validate_reg' => qr|^/video/(\w+)_.*|,
        },
        '_vimeo' => {
            'domain_reg' => qr/vimeo\.com/,
            'validate_reg' => qr|^/(\d+).*|,
        },
        '_megavideo' => {
            'domain_reg' => qr/megavideo\.com/,
            'validate_reg' => qr|^\w+$|,
        },
        '_kontraband' => {
            'domain_reg' => qr/kontraband\.com/,
            'validate_reg' => qr|^/videos/(\d+)/.*|,
        },
    };
}

no Moose;

#=== videos ===#

sub _youtube{
    my ( $self, $validate_reg, $uri ) = @_;
    my $youtube_id;

    if ( ($youtube_id = $uri->query_param('v')) && ($youtube_id =~ m/$validate_reg/) ){
        return '<object data="http://www.youtube.com/v/' . $youtube_id . '" '
            .'style="width: ' . $self->width . 'px; height: ' . $self->height . 'px;" type="application/x-shockwave-flash">'
            .'<param value="transparent" name="wmode" />'
            .'<param value="http://www.youtube.com/v/' . $youtube_id . '" name="movie" /></object>';
    }

    return undef;
}

sub _liveleak{
    my ( $self, $validate_reg, $uri ) = @_;
    my $leak_id;

    if ( ($leak_id = $uri->query_param('i')) && ($leak_id =~ m/$validate_reg/) ){
        return '<object width="' . $self->width . '" height="' . $self->height . '">'
            .'<param name="movie" value="http://www.liveleak.com/e/' . $leak_id . '" />'
            .'<param name="wmode" value="transparent" />'
            .'<embed src="http://www.liveleak.com/e/' . $leak_id . '" type="application/x-shockwave-flash"'
            .' wmode="transparent" width="' . $self->width . '" height="' . $self->height . '">'
            .'</embed></object>';
    }

    return undef;
}

sub _google{
    my ( $self, $validate_reg, $uri ) = @_;
    my $google_id;

    if ( ($google_id = $uri->query_param('docid')) && ($google_id =~ m/$validate_reg/) ){
        return '<embed id="VideoPlayback"'
            .' src="http://video.google.com/googleplayer.swf?'
            .'docid=' . $google_id 
            .'&hl=en&fs=true" style="width:' . $self->width . 'px;height:' . $self->height . 'px"'
            .' allowFullScreen="true"'
            .' type="application/x-shockwave-flash">'
            .'</embed>';
    }

    return undef;
}

sub _yahoo{
    my ( $self, $validate_reg, $uri ) = @_;

    if ( my ($vid, $id) = $uri->path =~ m/$validate_reg/ ){

        if ( (!$vid) || (!$id) ){
            return undef;
        }

        return '<object width="' . $self->width . '" height="' . $self->height . '">'
            .'<param name="movie" value="http://d.yimg.com/static.video.yahoo.com/yep/YV_YEP.swf?ver=2.2.46" />'
           .'<param name="allowFullScreen" value="true" />'
            .'<param name="bgcolor" value="#000000" /><param name="flashVars" '
            .'value="id=' . $id . '&vid=' . $vid 
            .'&lang=en-gb&intl=uk&embed=1" />'
            .'<embed src="http://d.yimg.com/static.video.yahoo.com/yep/YV_YEP.swf?ver=2.2.46" '
            .'type="application/x-shockwave-flash" width="' . $self->width . '" height="' . $self->height . '" allowFullScreen="true" '
            .'bgcolor="#000000" '
            .'flashVars="id=' . $id . '&vid=' . $vid 
            .'&lang=en-gb&intl=uk&embed=1" ></embed></object>';
    }
    
    return undef;
}

sub _spikedhumor{
    my ( $self, $validate_reg, $uri ) = @_;

    if ( my ($vid) = $uri->path =~ m/$validate_reg/ ){
        if ( (!$vid) ){
            return undef;
        }

        return '<embed src="http://www.spikedhumor.com/player/vcplayer.swf?file=http://www.spikedhumor.com/videocodes/'
            . $vid . '/data.xml&auto_play=false" quality="high" '
            .'scale="noscale" bgcolor="#000000" width="' . $self->width . '" '
            .'height="' . $self->height . '" align="middle" '
            .'type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />';
    }
    
    return undef;
}

sub _collegehumor{
    my ( $self, $validate_reg, $uri ) = @_;

    if ( my ($vid) = $uri->path =~ m/$validate_reg/ ){
        if ( (!$vid) ){
            return undef;
        }

        return '<object type="application/x-shockwave-flash" '
            .'data="http://www.collegehumor.com/moogaloop/moogaloop.swf?clip_id=' . $vid . '&fullscreen=1" '
            .'width="' . $self->width . '" height="' . $self->height . '" ><param name="allowfullscreen" value="true"/>'
            .'<param name="wmode" value="transparent"/>'
            .'<param name="movie" quality="best" value="http://www.collegehumor.com/moogaloop/moogaloop.swf?clip_id='
            . $vid . '&fullscreen=1"/>'
            .'<embed src="http://www.collegehumor.com/moogaloop/moogaloop.swf?clip_id=' . $vid . '&fullscreen=1" '
            .'type="application/x-shockwave-flash" wmode="transparent" width="' . $self->width . '" height="' . $self->height . '"></embed></object>';
    }
    
    return undef;
}

sub _funnyordie{
    my ( $self, $validate_reg, $uri ) = @_;

    if ( my ($vid) = $uri->path =~ m/$validate_reg/ ){
        if ( (!$vid) ){
            return undef;
        }

        return '<object width="' . $self->width . '" height="' . $self->height . '" id="ordie_player_' . $vid . '">'
            .'<param name="movie" value="http://player.ordienetworks.com/flash/fodplayer.swf" />'
            .'<param name="flashvars" value="key=' . $vid . '" />'
            .'<param name="allowfullscreen" value="true" />'
            .'<embed width="' . $self->width . '" height="' . $self->height . '" flashvars="key=' . $vid . '" allowfullscreen="true" '
            .'quality="high" src="http://player.ordienetworks.com/flash/fodplayer.swf" '
            .'name="ordie_player_' . $vid . '" type="application/x-shockwave-flash"></embed></object>';
    }
    
    return undef;
}

sub _metacafe{
    my ( $self, $validate_reg, $uri ) = @_;

    if ( my ($vid) = $uri->path =~ m/$validate_reg/ ){
        if ( (!$vid) ){
            return undef;
        }

        return '<embed src="http://www.metacafe.com/fplayer/' . $vid . '/unimportant_info_i_hope.swf" width="' . $self->width . '" '
            .'height="' . $self->height . '" wmode="transparent" pluginspage="http://www.macromedia.com/go/getflashplayer" '
            .'type="application/x-shockwave-flash" allowFullScreen="true" name="Metacafe_' . $vid . '"></embed>';
    }
    
    return undef;
}

sub _dailymotion{
    my ( $self, $validate_reg, $uri ) = @_;

    if ( my ($vid) = $uri->path =~ m/$validate_reg/ ){
        if ( (!$vid) ){
            return undef;
        }

        return '<object width="' . $self->width . '" height="' . $self->height . '">'
            .'<param name="movie" value="http://www.dailymotion.com/swf/video/' . $vid . '" />'
            .'<param name="allowFullScreen" value="true" />'
            .'<embed type="application/x-shockwave-flash" '
            .'src="http://www.dailymotion.com/swf/video/' . $vid . '" width="' . $self->width . '" '
            .'height="' . $self->height . '" allowfullscreen="true"></embed></object>';
    }
    
    return undef;
}

sub _vimeo{
    my ( $self, $validate_reg, $uri ) = @_;

    if ( my ($vid) = $uri->path =~ m/$validate_reg/ ){
        if ( (!$vid) ){
            return undef;
        }
        return '<object width="' . $self->width . '" height="' . $self->height . '">'
            .'<param name="allowfullscreen" value="true" />'
            .'<param name="movie" value="'
            .'http://vimeo.com/moogaloop.swf?clip_id=' . $vid . '&amp;'
            .'server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" />'
            .'<embed src="http://vimeo.com/moogaloop.swf?clip_id=' . $vid . '&amp;'
            .'server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" '
            .'type="application/x-shockwave-flash" allowfullscreen="true" '
            .'width="' . $self->width . '" height="' . $self->height . '"></embed></object>';
    }
    
    return undef;
}

sub _megavideo{
    my ( $self, $validate_reg, $uri ) = @_;
    my $megavideo_id;

    if ( ($megavideo_id = $uri->query_param('v')) && ($megavideo_id =~ m/$validate_reg/) ){
        return '<object width="' . $self->width . '" height="' . $self->height . '">'
            .'<param name="movie" value="http://www.megavideo.com/v/' . $megavideo_id . '" />'
            .'<param name="allowFullScreen" value="true" />'
            .'<embed src="http://www.megavideo.com/v/' . $megavideo_id . '" type="application/x-shockwave-flash" '
            .'allowfullscreen="true" width="' . $self->width . '" height="' . $self->height . '"></embed></object>';
    }

    return undef;
}

sub _kontraband{
    my ( $self, $validate_reg, $uri ) = @_;

    if ( my ($vid) = $uri->path =~ m/$validate_reg/ ){
        if ( (!$vid) ){
            return undef;
        }
        return '<embed height="' . $self->height . '" width="' . $self->width . '" '
            .'flashvars="file=http://208.116.9.205/10/content/' . $vid . '/450.flv" '
            .'usefullscreen="true" allowfullscreen="true" quality="high" '
            .'name="kbvideo" id="kbvideo" src="http://www.kontraband.com/show/4.5.swf" '
            .'type="application/x-shockwave-flash"/>';
    }
    
    return undef;
}

#=== control ===#

sub url_to_embed{
    my ( $self, $url ) = @_;

    my ($domain, $uri) = $self->is_video($url);
    if ( defined($domain) ){
        return $self->$domain( $self->_videos->{ $domain }->{'validate_reg'}, $uri );
    }

    return undef;
}

sub is_video{
    my ( $self, $url ) = @_;

    return undef if ( !is_uri($url) );

    my $uri = URI->new( URI::Escape::XS::uri_unescape($url) );

    foreach my $domain ( keys(%{ $self->_videos }) ){
#figure out if url is supported
        my $domain_reg = $self->_videos->{ $domain }->{'domain_reg'};
        if ( $uri->host =~ m/$domain_reg/ ){
            return ( $domain, $uri );
        }
    }

    return undef;
}

__PACKAGE__->meta->make_immutable;

1;
