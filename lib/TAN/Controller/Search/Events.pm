package TAN::Controller::Search::Events;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Try::Tiny;

sub add_object_to_index: Event(object_created) Event(object_updated){
    my ( $self, $c, $object ) = @_;

    my $type = $object->type;
    my $document = {
        'id' => $object->id,
        'type' => $type,
        'nsfw' => $object->nsfw,
        'title' => $object->$type->title,
        'description' => $object->$type->description,
        'date' => ref( $object->_created ) ne 'SCALAR' ? $object->_created->epoch : time,
        'username' => $object->user->username,
        'tag' =>  join( ' ', map( $_->tag, $object->tags->all ) ),
    };

    if ( 
        ( $type eq 'blog' )
        || ( $type eq 'forum' )
    ){
        $document->{'content'} = TAN::View::TT::strip_tags( $object->$type->_details );
    }

    if ( $type eq 'poll' ){
        $document->{'content'} = join( ' ', map( $_->answer, $object->poll->answers->all ) );
    }

    try{
        $c->model('Gearman')->run( 'search_add_to_index', $document );
    };
}

sub delete_object_from_index: Event(object_deleted) Event(mass_objects_deleted){
    my ( $self, $c, $objects ) = @_;

    if ( ref( $objects ) ne 'ARRAY' ){
        $objects = [$objects];
    }

    my @ids_to_delete;
    foreach my $object ( @{$objects} ){
        push( @ids_to_delete, $object->id );
    }
    
    try{
        $c->model('Gearman')->run( 'search_delete_from_index', \@ids_to_delete );
    };
}

sub add_comment_to_index: Event(comment_created) Event(comment_updated){
    my ( $self, $c, $comment ) = @_;

    my $document = {
        'id' => "comment-" . $comment->id,
        'type' => 'comment',
        'nsfw' => $comment->object->nsfw,
        'title' => '',
        'description' => '',
        'date' => ref( $comment->_created ) ne 'SCALAR' ? $comment->_created->epoch : time,
        'username' => $comment->user->username,
        'tag' => '',
        'content' => TAN::View::TT::strip_tags( $comment->_comment ),
    };

    try{
        $c->model('Gearman')->run( 'search_add_to_index', $document );
    };
}

sub delete_comment_from_index: Event(comment_deleted) Event(mass_comments_deleted){
    my ( $self, $c, $comments ) = @_;

    if ( ref( $comments ) ne 'ARRAY' ){
        $comments = [$comments];
    }

    my @ids_to_delete;
    foreach my $comment ( @{$comments} ){
        push( @ids_to_delete, "comment-" . $comment->id );
    }
    
    try{
        $c->model('Gearman')->run( 'search_delete_from_index', \@ids_to_delete );
    };
}

__PACKAGE__->meta->make_immutable;
