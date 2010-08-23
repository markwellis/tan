package TAN::View::Template::RSS::Lib::Object;

use base 'Catalyst::View::Perl::Template';
use DateTime::Format::Mail;

sub process{
    my ( $self, $c, $object ) = @_;

    $object ||= $c->stash->{'object'};
    my $type = $object->type;

    my $is_video;
    if ( $type eq 'link' ){
        if ( $c->view->is_video($object->link->url) ){
            $is_video = 'video';
        }
    }

    my $base = $c->req->base;
    $base =~ s|/$||;

    my $md = $object->$type->picture_id - ($object->$type->picture_id % 1000);
    my $image = qq|<img width="100" height="100" align="left" src="@{[ $base . $c->config->{'thumb_path'} ]}/${md}/@{[ $object->$type->picture_id ]}/100?rss=1" />|;

    return qq\
        <item>
            <title>@{[ $c->view->xml($object->$type->title) ]}@{[ $object->nsfw eq "Y" ? ' - NSFW' : '' ]} [@{[ $is_video || $type ]}][@{[ $object->get_column('comments') ]}]</title>
            <link>@{[ $c->view->xml($base . $object->url) ]}</link>
            <pubDate>@{[ DateTime::Format::Mail->format_datetime( $object->_promoted || $object->_created ) ]}</pubDate>
            <description>@{[ $c->view->xml($image . $object->$type->description) ]}</description>
        </item>\;
}

1;
