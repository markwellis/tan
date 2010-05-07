package HTML::Video::Embed;
use strict;
use warnings;

use URI;
use URI::QueryParam;
use URI::Escape::XS;

use Data::Validate::URI qw/ is_uri /;
use LWPx::ParanoidAgent;

my $int_reg = qr/\d+/;
sub new{
    my ( $invocant, $config ) = @_;

    my $class = ref($invocant) || $invocant;
    my $self = { };
    bless($self, $class);

    $self->{'width'} = $config->{'width'} || 450;
    $self->{'height'} = $config->{'height'} || 370;
    
    $self->{'supported'} = {
        'youtube' => {
            'domain_reg' => qr/youtube\.com/,
            'validate_reg' => qr/^[a-zA-Z0-9-_]{11}$/,
            'embed' => sub{
                my ( $validate_reg, $uri ) = @_;
                my $youtube_id;

                if ( ($youtube_id = $uri->query_param('v')) && ($youtube_id =~ m/$validate_reg/) ){
                    return '<object data="http://www.youtube.com/v/' . $youtube_id . '" '
                        .'style="width: ' . $self->{'width'} . 'px; height: ' . $self->{'height'} . 'px;" type="application/x-shockwave-flash">'
                        .'<param value="transparent" name="wmode" />'
                        .'<param value="http://www.youtube.com/v/' . $youtube_id . '" name="movie" /></object>';
                }

                return undef;
            }
        },
        'liveleak' => {
            'domain_reg' => qr/liveleak\.com/,
            'validate_reg' => qr/^\w{3}_\w{10}$/,
            'embed' => sub{
                my ( $validate_reg, $uri ) = @_;
                my $leak_id;

                if ( ($leak_id = $uri->query_param('i')) && ($leak_id =~ m/$validate_reg/) ){
                    return '<object width="' . $self->{'width'} . '/" height="' . $self->{'height'} . '">'
                        .'<param name="movie" value="http://www.liveleak.com/e/' . $leak_id . '" />'
                        .'<param name="wmode" value="transparent" />'
                        .'<embed src="http://www.liveleak.com/e/' . $leak_id . '" type="application/x-shockwave-flash"'
                        .' wmode="transparent" width="' . $self->{'width'} . '" height="' . $self->{'height'} . '">'
                        .'</embed></object>';
                }

                return undef;
            }
        },
        'google' => {
            'domain_reg' => qr/google\.com/,
            'validate_reg' => qr/^-\w{19}$/,
            'embed' => sub{
                my ( $validate_reg, $uri ) = @_;
                my $google_id;

                if ( ($google_id = $uri->query_param('docid')) && ($google_id =~ m/$validate_reg/) ){
                    return '<embed id="VideoPlayback"'
                        .' src="http://video.google.com/googleplayer.swf?'
                        .'docid=' . $google_id 
                        .'&hl=en&fs=true" style="width:' . $self->{'width'} . 'px;height:' . $self->{'height'} . 'px"'
                        .' allowFullScreen="true"'
                        .' type="application/x-shockwave-flash">'
                        .'</embed>';
                }

                return undef;
            }
        },
        'yahoo' => {
            'domain_reg' => qr/video\.yahoo\.com/,
            'validate_reg' => qr/^\/watch\/(\d+)\/(\d+)/,
            'embed' => sub{
                my ( $validate_reg, $uri ) = @_;

                if ( my ($vid, $id) = $uri->path =~ m/$validate_reg/ ){

                    if ( (!$vid) || (!$id) ){
                        return undef;
                    }

                    return '<object width="' . $self->{'width'} . '" height="' . $self->{'height'} . '">'
                        .'<param name="movie" value="http://d.yimg.com/static.video.yahoo.com/yep/YV_YEP.swf?ver=2.2.46" />'
                       .'<param name="allowFullScreen" value="true" />'
                        .'<param name="bgcolor" value="#000000" /><param name="flashVars" '
                        .'value="id=' . $id . '&vid=' . $vid 
                        .'&lang=en-gb&intl=uk&embed=1" />'
                        .'<embed src="http://d.yimg.com/static.video.yahoo.com/yep/YV_YEP.swf?ver=2.2.46" '
                        .'type="application/x-shockwave-flash" width="' . $self->{'width'} . '" height="' . $self->{'height'} . '" allowFullScreen="true" '
                        .'bgcolor="#000000" '
                        .'flashVars="id=' . $id . '&vid=' . $vid 
                        .'&lang=en-gb&intl=uk&embed=1" ></embed></object>';
                }
                
                return undef;
            }
        },
        'spikedhumor' => {
            'domain_reg' => qr/spikedhumor\.com/,
            'validate_reg' => qr/^\/articles\/(\d+)\/.*$/,
            'embed' => sub{
                my ( $validate_reg, $uri ) = @_;

                if ( my ($vid) = $uri->path =~ m/$validate_reg/ ){
                    if ( (!$vid) ){
                        return undef;
                    }

                    return '<embed src="http://www.spikedhumor.com/player/vcplayer.swf?file=http://www.spikedhumor.com/videocodes/'
                        . $vid . '/data.xml&auto_play=false" quality="high" '
                        .'scale="noscale" bgcolor="#000000" width="' . $self->{'width'} . '" '
                        .'height="' . $self->{'height'} . '" align="middle" '
                        .'type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />';
                }
                
                return undef;
            }
        },
        'colleghumor' => {
            'domain_reg' => qr/collegehumor\.com/,
            'validate_reg' => qr/^\/video:(\d+)/,
            'embed' => sub{
                my ( $validate_reg, $uri ) = @_;

                if ( my ($vid) = $uri->path =~ m/$validate_reg/ ){
                    if ( (!$vid) ){
                        return undef;
                    }

                    return '<object type="application/x-shockwave-flash" '
                        .'data="http://www.collegehumor.com/moogaloop/moogaloop.swf?clip_id=' . $vid . '&fullscreen=1" '
                        .'width="' . $self->{'width'} . '" height="' . $self->{'height'} . '" ><param name="allowfullscreen" value="true"/>'
                        .'<param name="wmode" value="transparent"/>'
                        .'<param name="movie" quality="best" value="http://www.collegehumor.com/moogaloop/moogaloop.swf?clip_id='
                        . $vid . '&fullscreen=1"/>'
                        .'<embed src="http://www.collegehumor.com/moogaloop/moogaloop.swf?clip_id=' . $vid . '&fullscreen=1" '
                        .'type="application/x-shockwave-flash" wmode="transparent" width="' . $self->{'width'} . '" height="' . $self->{'height'} . '"></embed></object>';
                }
                
                return undef;
            }
        },
        'funnyordie' => {
            'domain_reg' => qr/funnyordie\.com/,
            'validate_reg' => qr/^\/videos\/(\w+)\/.*/,
            'embed' => sub{
                my ( $validate_reg, $uri ) = @_;

                if ( my ($vid) = $uri->path =~ m/$validate_reg/ ){
                    if ( (!$vid) ){
                        return undef;
                    }

                    return '<object width="' . $self->{'width'} . '" height="' . $self->{'height'} . '" id="ordie_player_' . $vid . '">'
                        .'<param name="movie" value="http://player.ordienetworks.com/flash/fodplayer.swf" />'
                        .'<param name="flashvars" value="key=' . $vid . '" />'
                        .'<param name="allowfullscreen" value="true" />'
                        .'<embed width="' . $self->{'width'} . '" height="' . $self->{'height'} . '" flashvars="key=' . $vid . '" allowfullscreen="true" '
                        .'quality="high" src="http://player.ordienetworks.com/flash/fodplayer.swf" '
                        .'name="ordie_player_' . $vid . '" type="application/x-shockwave-flash"></embed></object>';
                }
                
                return undef;
            }
        },
        'metacafe' => {
            'domain_reg' => qr/metacafe\.com/,
            'validate_reg' => qr/^\/watch\/(\d+)\/.*/,
            'embed' => sub{
                my ( $validate_reg, $uri ) = @_;

                if ( my ($vid) = $uri->path =~ m/$validate_reg/ ){
                    if ( (!$vid) ){
                        return undef;
                    }

                    return '<embed src="http://www.metacafe.com/fplayer/' . $vid . '/unimportant_info_i_hope.swf" width="' . $self->{'width'} . '" '
                        .'height="' . $self->{'height'} . '" wmode="transparent" pluginspage="http://www.macromedia.com/go/getflashplayer" '
                        .'type="application/x-shockwave-flash" allowFullScreen="true" name="Metacafe_' . $vid . '"></embed>';
                }
                
                return undef;
            }
        },
        'dailymotion' => {
            'domain_reg' => qr/dailymotion\.com/,
            'validate_reg' => qr/^\/video\/(\w+)_.*/,
            'embed' => sub{
                my ( $validate_reg, $uri ) = @_;

                if ( my ($vid) = $uri->path =~ m/$validate_reg/ ){
                    if ( (!$vid) ){
                        return undef;
                    }

                    return '<object width="' . $self->{'width'} . '" height="' . $self->{'height'} . '">'
                        .'<param name="movie" value="http://www.dailymotion.com/swf/video/' . $vid . '" />'
                        .'<param name="allowFullScreen" value="true" />'
                        .'<embed type="application/x-shockwave-flash" '
                        .'src="http://www.dailymotion.com/swf/video/' . $vid . '" width="' . $self->{'width'} . '" '
                        .'height="' . $self->{'height'} . '" allowfullscreen="true"></embed></object>';
                }
                
                return undef;
            }
        },
    };
    return $self;
}

sub url_to_embed{
    my ( $self, $url ) = @_;

    return undef if ( !is_uri($url) );

#un uri encode url here!
    my $uri = URI->new( URI::Escape::XS::uri_unescape($url) );

    foreach my $domain ( keys(%{ $self->{'supported'} }) ){
#figure out if url is supported
        my $domain_reg = $self->{'supported'}->{ $domain }->{'domain_reg'};
        if ( $uri->host =~ m/$domain_reg/ ){
            return $self->{'supported'}->{ $domain }->{'embed'}->( $self->{'supported'}->{ $domain }->{'validate_reg'}, $uri );
        }
    }

    return undef;
}

1;
