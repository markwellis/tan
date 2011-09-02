package TAN::Controller::Tag;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub clear_index_caches: 
    Event(object_created)
    Event(object_deleted)
    Event(object_updated)
    Event(mass_objects_deleted)
{
    my ( $self, $c ) = @_;

    $c->clear_cached_page('/tag.*');
}

sub index: Path Args(1){
    my ( $self, $c, $tag ) = @_;

    $c->cache_page( 600 );
#get list of things with $tag
#assemble index

    my $stem = $c->model('Stemmer')->stem( $tag );

    if ( $tag ne $stem ){
        $c->res->redirect("/tag/${stem}", 301);
        $c->detach;
    }

    my $tags_rs = $c->model('MySQL::Tags')->search({
        'stem' => $tag,
    })->first;

    if ( !defined($tags_rs) ){
        $c->forward('/default');
        $c->detach;
    }

    my $page = $c->req->param('page') || 1;
    my $order = $c->req->param('order') || 'created';

    my $key = $tag;
    $key =~ s/\W+/_/g;
    my ( $objects, $pager ) = $tags_rs->objects->index( 'all', $page, 1, {}, $order, $c->nsfw, "tag:${key}" );

    if ( $objects ){
        $c->stash(
            'index' => $c->model('Index')->indexinate($c, $objects, $pager),
            'order' => $order,
            'template' => 'index.tt',
            'page_title' => "${tag} - Tag",
        );
    } else {
        $c->forward('/default');
        $c->detach;
    }
}

__PACKAGE__->meta->make_immutable;
