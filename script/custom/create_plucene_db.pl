#!/usr/bin/perl
use strict;
use warnings;

use Plucene::Simple;
use TAN::Model::MySQL;
use Term::ProgressBar;

my $index_path = '/mnt/stuff/TAN/plucene_index';
my $plucy = Plucene::Simple->open($index_path);

my $db = new TAN::Model::MySQL;

my $objects = $db->resultset('Object')->search({
        'type' => ['link', 'blog', 'picture'],
    },{
    '+select' => [
        \'DATE_FORMAT(created, GET_FORMAT(DATE,"ISO"))',
    ],
    '+as' => [
        'iso_created',
    ],
    'prefetch' => ['link', 'blog', 'picture'],
});

my $count = $objects->count;
my $loop = 0;
my $progress = Term::ProgressBar->new({
    'name' => 'Indexing',
    'count' => $count,
});

while (my $object = $objects->next){
    my $type = $object->type;

    $plucy->add($object->id, {
        'date' => $object->get_column('iso_created'),
        'title' => $object->$type->title,
        'description' => $object->$type->description,
    });

    $progress->update( ++$loop );

    if ( ($count % 100) == 0 ){
        $plucy->optimize;
    }
}

$plucy->optimize;
