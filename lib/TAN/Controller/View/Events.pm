package TAN::Controller::View::Events;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Try::Tiny;

sub spam_twitter: Event('object_promoted'){
    my ( $self, $c, $object ) = @_;

    my $type = $object->type;
    my $title = $object->$type->title;

    try{
        my $url = $object->url;
        $url =~ s|^/||;

        my @tags = map( $_->stem, $object->tags->all );
        $c->model('Gearman')->run( 'twitter_spam', {
            'title' => $title,
            'nsfw' => $object->nsfw,
            'url' => $c->req->base . $url,
            'tags' => \@tags,
        } );
    }
}

sub update_score: 
    Event(comment_created) 
    Event(comment_updated)
    Event(object_plusminus)
    Event(mass_comments_deleted)
{
    my ( $self, $c, $object ) = @_;

    my $objects = [];
    if ( ref( $object ) ne 'ARRAY' ){
        push( @{$objects}, $object );
    } else {
        $objects = $object;
    }

    foreach my $object_to_update ( @{$objects} ){
        if ( ref($object_to_update) ne 'TAN::Model::MySQL::Object' ){
        #$object_rs probably something else with a ->object relationship
            $object_to_update = $object_to_update->object;
        }

        $object_to_update->update_score;
    }
}

sub remove_blog_cache: Event(object_updated){
    my ( $self, $c, $object ) = @_;

    my $type = $object->type;
    if ( 
        ( $type eq 'blog' )
        || ( $type eq 'forum' )
    ){
        $c->cache->remove("${type}.0:" . $object->id);
        $c->cache->remove("${type}.1:" . $object->id);
    }
}

sub remove_comment_cache: 
    Event(comment_created) 
    Event(comment_deleted) 
    Event(comment_updated) 
    Event(object_updated) 
    Event(object_deleted)
    Event(mass_objects_deleted)
    Event(mass_comments_deleted)
{
    my ( $self, $c, $comments ) = @_;

    #clear recent_comments
    $c->cache->remove("recent_comments");

    #clear comment cache
    return if !defined( $comments );
    if ( ref( $comments ) ne 'ARRAY' ){
        $comments = [ $comments ];
    }

    foreach my $comment ( @{$comments} ){
        if ( ref($comment) eq 'TAN::Model::MySQL::Comments' ){
            $c->cache->remove("comment.0:" . $comment->id);
            $c->cache->remove("comment.1:" . $comment->id);
        }
    }
}

sub remove_object_cache: 
    Event(object_deleted)
    Event(object_updated)
    Event(object_plusminus)
    Event(object_promoted)
    Event(comment_created)
    Event(comment_deleted)
    Event(comment_updated)
    Event(poll_vote)
    Event(mass_objects_deleted)
    Event(mass_comments_deleted)
{
    my ( $self, $c, $objects ) = @_;
    return if ( !defined($objects) );

    if ( ref( $objects ) ne 'ARRAY' ){
        $objects = [ $objects ];
    }

    foreach my $object ( @{$objects} ){
        if ( ref($object) ne 'TAN::Model::MySQL::Object' ){
        #$object_rs probably something else with a ->object relationship
            $object = $object->object;
        }

        $c->cache->remove("object:" . $object->id);
        $c->clear_cached_page( $object->url . '.*' );
    }
}

__PACKAGE__->meta->make_immutable;
