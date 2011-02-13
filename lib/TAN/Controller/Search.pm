package TAN::Controller::Search;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Time::HiRes qw/time/;
use Data::Page;

sub add_to_index: Event(object_created) Event(object_updated){
    my ( $self, $c, $object ) = @_;

    eval{
        my $type = $object->type;

        $c->model('Search')->update_or_create({
            'id' => $object->id,
            'type' => $object->type,
            'nsfw' => $object->nsfw,
            'title' => $object->$type->title,
            'description' => $object->$type->description,
        });

        $c->model('Search')->commit;
    };
}

sub delete_from_index: Event(object_deleted){
    my ( $c, $object ) = @_;

    eval{
        $c->model('Search')->delete( $object->id );
        $c->model('Search')->commit;
    };
}

sub index: Path Args(0){
    my ( $self, $c ) = @_;

    my $q = $c->req->param('q');
    my $page = $c->req->param('page') || 1;

    #nsfw...
    if ( !$c->nsfw && ($q !~ m/nsfw\:?/) ){
        $q .= ' nsfw:n';
    }
    if ( my ( $objects, $pager ) = $c->model('Search')->search( $q, $page ) ){
        $c->stash->{'index'} = $c->model('Index')->indexinate($c, $objects, $pager);
    }

    $c->model('Search')->commit;

    $c->stash(
        'page_title' => $c->req->param('q') . " - Search",
        'template' => 'Index',
    );
}

__PACKAGE__->meta->make_immutable;
