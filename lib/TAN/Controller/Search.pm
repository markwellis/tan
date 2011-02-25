package TAN::Controller::Search;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub add_to_index: Event(object_created) Event(object_updated){
    my ( $self, $c, $object ) = @_;

    my $type = $object->type;

    my $document = {
        'id' => $object->id,
        'type' => $object->type,
        'nsfw' => $object->nsfw,
        'title' => $object->$type->title,
        'description' => $object->$type->description,
    };

    $c->model('Gearman')->run( 'search_add_to_index', $document );
}

sub delete_from_index: Event(object_deleted){
    my ( $c, $object ) = @_;

    $c->model('Gearman')->run( 'search_delete_from_index', $object->id );
}

sub index: Path Args(0){
    my ( $self, $c ) = @_;

    my $q = $c->req->param('q');
    my $page = $c->req->param('page') || 1;

    #nsfw...
    if ( !$c->nsfw && ($q !~ m/nsfw\:?/) ){
        $q .= ' nsfw:n';
    }

    my $searcher = $c->model('Search');
    if ( my ( $objects, $pager ) = $searcher->search( $q, $page ) ){
        $c->stash->{'index'} = $c->model('Index')->indexinate($c, $objects, $pager);
    }

    $c->stash(
        'page_title' => $c->req->param('q') . " - Search",
        'template' => 'Index',
    );
}

__PACKAGE__->meta->make_immutable;
