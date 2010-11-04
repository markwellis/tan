package TAN::View::Template::Classic::Lib::Ad;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $position ) = @_;

    my ( $ad_slot, $height, $width );
    if ( $position eq 'top' ){
        $ad_slot = "5056038012";
        $height = 90;
        $width = 728;
    } elsif ( $position eq 'left' ){
# left
        $ad_slot = "0470978238";
        $height = 600;
        $width = 160;
    } elsif ( $position eq 'right1' ){
# right1
        $ad_slot = "9701017441";
        $height = 600;
        $width = 120;
    }

    my $out = qq\<div class="TAN-${position}-ad">\;

    if ( !$c->stash->{'no_ads'} ){
        $out .= qq\
            <script type="text/javascript">//<![CDATA[
                google_ad_client = "@{[ $c->config->{'google_adcode'} ]}";
                google_ad_slot = "${ad_slot}";
                google_ad_width = ${width};
                google_ad_height = ${height};
            //]]></script>
            <script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script>\;
    }

    $out .= '</div>';

    return $out;
}

1;
