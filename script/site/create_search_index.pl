#!/usr/bin/perl
use strict;
use warnings;

use LucyX::Simple;

use TAN::Model::DB;
use Term::ProgressBar;

use HTML::FormatText;

use File::Basename;
use Config::JFDI;

sub strip_tags{
    return HTML::FormatText->format_string(
        shift,
        'leftmargin' => 0,
        'rightmargin' => 72,
    );
}

my $tan_config = Config::JFDI->new(name => "TAN", path => dirname(__FILE__) . "/../../")->get;
my $search_config = $tan_config->{'Model::Search'}->{args};

my $searcher = LucyX::Simple->new( $search_config );

my $db = TAN::Model::DB->new( $tan_config->{'Model::DB'} );

my $objects = $db->resultset('Object')->search({
        'me.deleted' => 0,
        'type' =>[qw/link blog picture poll video forum/],
    },{
    'prefetch' => [qw/link blog picture poll video forum user/],
});

my $comments = $db->resultset('Comment')->search({ 'me.deleted' => 0 },{'prefetch' => [qw/user object/],});

my $count = $objects->count + $comments->count;
my $loop = 0;
my $progress = Term::ProgressBar->new({
    'name' => 'Indexing',
    'count' => $count,
});
$progress->minor(0);

while ( my $object = $objects->next ){
    my $type = $object->type;

    if ( defined($object->$type) ){
        my $create = {
            'id' => $object->id,
            'type' => $type,
            'nsfw' => $object->nsfw,
            'title' => $object->$type->title,
            'description' => $object->$type->description,
            'date' => $object->_created->epoch,
            'username' => $object->user->username,
            'tag' =>  join( ' ', map( $_->tag, $object->tags->all ) ),
        };

        if (
            ( $type eq 'blog' )
            || ( $type eq 'forum' )
        ){
            $create->{'content'} = strip_tags( $object->$type->_details );
        }

        if ( $type eq 'poll' ){
            $create->{'content'} = join( ' ', map( $_->answer, $object->poll->answers->all ) );
        }
        $searcher->create( $create );
    }
    $progress->update( ++$loop );
}

while (my $comment = $comments->next){
    my $create = {
        'id' => "comment-" . $comment->id,
        'type' => 'comment',
        'nsfw' => $comment->object->nsfw,
        'title' => '',
        'description' => '',
        'date' => $comment->_created->epoch,
        'username' => $comment->user->username,
        'tag' => '',
        'content' => strip_tags( $comment->_comment ),
    };

    $searcher->create( $create );
    $progress->update( ++$loop );
}

$searcher->commit(1);
