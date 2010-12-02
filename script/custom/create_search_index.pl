#!/usr/bin/perl
use strict;
use warnings;

use KinoSearchX::Simple;

use TAN::Model::MySQL;
use Term::ProgressBar;

my $index_path = '/mnt/stuff/TAN/search_index';

my $searcher = KinoSearchX::Simple->new({
    'index_path' => '/mnt/stuff/TAN/search_index',
    'schema' => [
        {
            'name' => 'title', 
            'boost' => 3,
        },{
            'name' => 'description',
        },{
            'name' => 'id',
        },{
            'name' => 'type',
        },{
            'name' => 'nsfw',
        },
    ],
    'search_fields' => ['title', 'description'],
    'search_boolop' => 'AND',
});

my $db = new TAN::Model::MySQL;

my $objects = $db->resultset('Object')->search({
        'type' => ['link', 'blog', 'picture', 'poll'],
    },{
    'prefetch' => ['link', 'blog', 'picture', 'poll'],
});

my $count = $objects->count;
my $loop = 0;
my $progress = Term::ProgressBar->new({
    'name' => 'Indexing',
    'count' => $count,
});
$progress->minor(0);

#create index
$searcher->_indexer;

while (my $object = $objects->next){
    my $type = $object->type;

    if ( defined($object->$type) ){
        $searcher->update_or_create({
            'id' => $object->id,
            'type' => $type,
            'nsfw' => $object->nsfw,
            'title' => $object->$type->title,
            'description' => $object->$type->description,
        });
    }
    $progress->update( ++$loop );
}

$searcher->commit;
