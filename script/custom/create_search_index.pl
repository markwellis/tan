#!/usr/bin/perl
use strict;
use warnings;

use KinoSearch::TAN;

use TAN::Model::MySQL;
use Term::ProgressBar;

my $index_path = '/mnt/stuff/TAN/search_index';

my $searcher = KinoSearch::TAN->new({
    'index_path' => '/mnt/stuff/TAN/search_index',
});

my $db = new TAN::Model::MySQL;

my $objects = $db->resultset('Object')->search({
        'type' => ['link', 'blog', 'picture'],
    },{
    'prefetch' => ['link', 'blog', 'picture'],
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
        $searcher->add({
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
