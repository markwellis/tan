package TAN::View::RSS;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View';

use XML::Feed;
use XML::Feed::Entry;

sub process {
    my ( $self, $c ) = @_;

    return if !scalar(@{$c->stash->{'index'}->{'objects'}});

    my $page_title = $c->stash->{'page_title'};
    if ( $page_title ){
        $page_title = "TAN - ${page_title}";
    } else {
        $page_title = "This Aint News";
    }

    my $feed = XML::Feed->new('RSS');

    $feed->title( $page_title );
    $feed->link( $c->req->base . $c->req->path );
    $feed->description('Social News For Internet Pirates');

    my $object = $c->stash->{'index'}->{'objects'}->[0];
    my $date;
    if ( $object->can('_promoted') ){
        $date = $object->_promoted;
    }
    $date ||= $object->_created;
    $feed->modified( $date );

    foreach my $object ( @{$c->stash->{'index'}->{'objects'}} ){
        if ( ref( $object ) eq 'TAN::Model::DB::Object' ){
            my $type = $object->type;
            my $base = $c->req->base;
            $base =~ s|/$||;

            my $md = $object->$type->picture_id - ($object->$type->picture_id % 1000);
            my $image = qq|<img width="100" height="100" align="left" src="@{[ $base . $c->config->{'thumb_path'} ]}/${md}/@{[ $object->$type->picture_id ]}/100?rss=1" />|;

            my $entry = XML::Feed::Entry->new('RSS');
            $entry->id( $object->id );
            $entry->link( $base . $object->url );
            $entry->title( $object->$type->title . ( $object->nsfw ? ' - NSFW' : '' ) );
            $entry->summary( $image . $object->$type->description );
            $entry->issued( $object->_promoted || $object->_created );
            $feed->add_entry( $entry );
        } elsif ( ref( $object ) eq 'TAN::Model::DB::Comment' ){
            my $type = $object->object->type;
            my $base = $c->req->base;
            $base =~ s|/$||;

            my $entry = XML::Feed::Entry->new('RSS');
            $entry->id( "comment:" . $object->id );
            $entry->link( $base . $object->object->url . "#comment" . $object->id );
            $entry->title( "Comment on " . $object->object->$type->title . ( $object->object->nsfw ? ' - NSFW' : '' ) );
            $entry->summary( $object->comment );
            $entry->issued( $object->_created );
            $feed->add_entry( $entry );
        }
    }

    $c->response->content_type('application/rss+xml; charset=utf-8');
    $c->response->body( $feed->as_xml );
}

__PACKAGE__->meta->make_immutable;
