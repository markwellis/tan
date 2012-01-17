#!/usr/bin/perl
use strict;
use warnings;

use LucyX::Simple;

use TAN::Model::MySQL;
use Term::ProgressBar;

use HTML::TreeBuilder;
use HTML::FormatText;

sub strip_tags{
    my $tree = HTML::TreeBuilder->new;
    $tree->parse(shift);
    $tree->eof;

    my $text;
    if ($tree) {
        $text = $tree->as_text();
        $tree = $tree->delete;
    }

    return $text;
}

my $searcher = LucyX::Simple->new({
    'index_path' => '/mnt/stuff/TAN/search_index',
    'schema' => [
        {
            'name' => 'id',
            'type' => 'string',
        },{
            'name' => 'title', 
            'boost' => 3,
            'stored' => 0,
        },{
            'name' => 'description',
            'stored' => 0,
        },{
            'name' => 'content',
            'stored' => 0,
        },{
            'name' => 'type',
            'stored' => 0,
        },{
            'name' => 'nsfw',
            'stored' => 0,
        },{
            'name' => 'date',
            'type' => 'int32',
            'indexed' => 0,
            'stored' => 0,
            'sortable' => 1,
        },{
            'name' => 'username',
            'stored' => 0,
        },{
            'name' => 'tag',
            'stored' => 0,
        },
    ],
    'search_fields' => ['title', 'description', 'tag'],
    'search_boolop' => 'AND',
});

my $db = new TAN::Model::MySQL;

my $objects = $db->resultset('Object')->search({
        'type' =>[qw/link blog picture poll video forum/],
    },{
    'prefetch' => ['link', 'blog', 'picture', {'poll' => 'answers'}, 'video', 'forum', 'user'],
});

my $count = $objects->count;
my $loop = 0;
my $progress = Term::ProgressBar->new({
    'name' => 'Indexing',
    'count' => $count,
});
$progress->minor(0);

while (my $object = $objects->next){
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

#add in comments here

$searcher->commit;
