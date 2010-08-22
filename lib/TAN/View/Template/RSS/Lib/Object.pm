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

    print qq\
        <item>
            <title>@{[ $c->view->xml($object->$type->title) ]}@{[ $object->nsfw eq "Y" ? ' - NSFW' : '' ]} [@{[ $is_video || $type ]}][@{[ $object->get_column('comments') ]}]@{[ $object->_promoted ? '*' : '' ]}</title>
            <link>@{[ $c->view->xml($base . $object->url) ]}</link>
            <pubDate>@{[ DateTime::Format::Mail->format_datetime( $object->_promoted || $object->_created ) ]}</pubDate>
            <description>@{[ $c->view->xml($object->$type->description) ]}</description>
        </item>\;
}

1;
