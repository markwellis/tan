package TAN::View::Template::Classic::Lib::Ad;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $position ) = @_;

    my ( $ad_slot, $height, $width );
    if ( $position eq 'top' ){
    #leaderboard
        $ad_slot = "52129";
    } elsif ( $position eq 'left' ){
    #skyscraper
        $ad_slot = "52130";
    } elsif ( $position eq 'right1' ){
    #skyscraper
        $ad_slot = "52131";
    } elsif ( $position eq 'right2' ){
    #skyscraper
        $ad_slot = "52132";
    } elsif ( $position eq 'bottom' ){
# bottom
        $ad_slot = "52133";
    }

    my $out = qq\<div class="TAN-${position}-ad">\;

    if ( !$c->stash->{'no_ads'} ){
        $out .= qq\
        <script type="text/javascript">//<![CDATA[
            var pw_d=document;
            pw_d.projectwonderful_adbox_id = "${ad_slot}";
            pw_d.projectwonderful_adbox_type = "5";
            pw_d.projectwonderful_foreground_color = "";
            pw_d.projectwonderful_background_color = "";
            //]]>
        </script>
        <script type="text/javascript" src="http://www.projectwonderful.com/ad_display.js"></script>\;
    }

    $out .= '</div>';

    return $out;
}

1;
