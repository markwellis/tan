package HTML::Video::Embed;
use strict;
use warnings;

use URI;
use URI::QueryParam;
use Data::Validate::URI qw/ is_uri /;

sub new{
    my ( $invocant ) = @_;

    my $class = ref($invocant) || $invocant;
    my $self = { };
    bless($self, $class);
    
    return $self;
}

my $supported = {
    'youtube' => {
        'domain_reg' => qr/youtube\.com/,
        'validate_reg' => qr/^[a-zA-Z0-9-_]{11}$/,
        'embed' => sub{
            my ( $validate_reg, $uri ) = @_;
            my $youtube_id;

            if ( ($youtube_id = $uri->query_param('v')) && ($youtube_id =~ m/$validate_reg/) ){
                return '<object data="http://www.youtube.com/v/' . $youtube_id . '" '
                    .'style="width: 450px; height: 370px;" type="application/x-shockwave-flash">'
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
                return '<object width="450" height="370">'
                    .'<param name="movie" value="http://www.liveleak.com/e/' . $leak_id . '" />'
                    .'<param name="wmode" value="transparent" />'
                    .'<embed src="http://www.liveleak.com/e/' . $leak_id . '" type="application/x-shockwave-flash"'
                    .' wmode="transparent" width="450" height="370">'
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
                    .'&hl=en&fs=true" style="width:450px;height:370px"'
                    .' allowFullScreen="true"'
                    .' allowScriptAccess="always"'
                    .' type="application/x-shockwave-flash">'
                    .'</embed>';
            }

            return undef;
        }
    },
};

sub url_to_embed{
    my ( $self, $url ) = @_;

    return undef if ( !is_uri($url) );

    my $uri = URI->new( $url );

    foreach my $domain ( keys(%{ $supported }) ){
#figure out if url is supported
        my $domain_reg = $supported->{ $domain }->{'domain_reg'};
        if ( $uri->host =~ m/$domain_reg/ ){
            return $supported->{ $domain }->{'embed'}->( $supported->{ $domain }->{'validate_reg'}, $uri );
        }
    }

    return undef;
}

1;
