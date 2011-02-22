package TAN::View::Template::Classic::Lib::Ad;
use Moose;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $position ) = @_;

    my ( $ad_slot, $ad_type );
    if ( $position eq 'top' ){
    #leaderboard
        $ad_slot = "52129";
        $ad_type = 5;
    } elsif ( $position eq 'left' ){
    #skyscraper
        $ad_slot = "52130";
        $ad_type = 3;
    }

    my $out = qq\<div class="TAN-${position}-ad">\;

    if ( !$c->stash->{'no_ads'} ){
        $out .= qq#
        <!--
            <div>
                <script type="text/javascript">//<![CDATA[
                    var pw_d=document;
                    pw_d.projectwonderful_adbox_id = "${ad_slot}";
                    pw_d.projectwonderful_adbox_type = "${ad_type}";
                    //]]>
                </script>
                <script type="text/javascript" src="http://www.projectwonderful.com/ad_display.js"></script>
            </div>
        -->

        <script type="text/javascript">//<![CDATA[
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

__PACKAGE__->meta->make_immutable;
