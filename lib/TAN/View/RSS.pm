package TAN::View::RSS;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View';

use XML::Feed;
use XML::Feed::Entry;

sub process {
    my ( $self, $c ) = @_;

    return if !$c->stash->{'index'}->{'objects'};

    my $object = $c->stash->{'index'}->{'objects'}->[0];
    $c->stash->{'build_date'} = DateTime::Format::Mail->format_datetime( $object->_promoted || $object->_created );

    my $feed = XML::Feed->new('RSS');

    my $page_title = $c->stash->{'page_title'};
    if ( $page_title ){
        $page_title = "TAN - ${page_title}";
    } else {
        $page_title = "This Aint News";
    }

    $feed->title( $page_title );
    $feed->link( $c->req->base . $c->req->path );
    $feed->description('Social News For Internet Pirates');
    $feed->modified( $object->_promoted || $object->_created );
    
    foreach my $object ( @{$c->stash->{'index'}->{'objects'}} ){
        my $type = $object->type;
        my $base = $c->req->base;
        $base =~ s|/$||;

        my $md = $object->$type->picture_id - ($object->$type->picture_id % 1000);
        my $image = qq|<img width="100" height="100" align="left" src="@{[ $base . $c->config->{'thumb_path'} ]}/${md}/@{[ $object->$type->picture_id ]}/100?rss=1" />|;

        my $entry = XML::Feed::Entry->new('RSS');
        $entry->id( $object->id );
        $entry->link( $base . $object->url );
        $entry->title( $object->$type->title . ( $object->nsfw eq "Y" ? ' - NSFW' : '' ) );
        $entry->summary( $image . $object->$type->description );
        $entry->issued( $object->_promoted || $object->_created );
        $feed->add_entry( $entry );
        
    }
    
    $c->response->content_type('application/rss+xml; charset=utf-8');
    $c->response->body( $feed->as_xml );
}

__PACKAGE__->meta->make_immutable;
