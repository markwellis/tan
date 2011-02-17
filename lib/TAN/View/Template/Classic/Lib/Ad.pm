package TAN::View::Template::Classic::Lib::Ad;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $position ) = @_;

    my ( $ad_slot, $height, $width );
    if ( $position eq 'top' ){
    #leaderboard
        $ad_slot = "52129";
        $ad_type = 5;
    } elsif ( $position eq 'left' ){
    #skyscraper
        $ad_slot = "52130";
        $ad_type = 3;
    } elsif ( $position eq 'right1' ){
    #skyscraper
        $ad_slot = "52131";
        $ad_type = 3;
    } elsif ( $position eq 'right2' ){
    #skyscraper
        $ad_slot = "52132";
        $ad_type = 3;
    } elsif ( $position eq 'bottom' ){
# bottom
        $ad_slot = "52133";
        $ad_type = 5;
    }

    my $out = qq\<div class="TAN-${position}-ad">\;

    if ( !$c->stash->{'no_ads'} ){
        $out .= qq#
        <script type="text/javascript">//<![CDATA[
            var pw_d=document;
            pw_d.projectwonderful_adbox_id = "${ad_slot}";
            pw_d.projectwonderful_adbox_type = "${ad_type}";
            pw_d.projectwonderful_foreground_color = "";
            pw_d.projectwonderful_background_color = "";

            var timestamp = new Date().getTime();
            var url = "http://www.projectwonderful.com/nojs.php?id=${ad_slot}&type=${ad_type}&t=" + timestamp;
            var img = Asset.image( url, {
                "onload": function( img ){
                    var a = new Element( 'a', { 
                        "href" : "http://www.projectwonderful.com/out_nojs.php?r=0&c=0&id=${ad_slot}&type=${ad_type}",
                        "target": "_blank",
                        "rel": "nofollow"
                    } );

                    a.grab( img );
                    \$\$('.TAN-${position}-ad').grab( a );
                }
            } );
            //]]>
        </script>#;
    }

    $out .= '</div>';

    return $out;
}

1;
