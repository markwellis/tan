#!/usr/bin/perl
use strict;
use warnings;

use Plucene::Simple;
use TAN::Model::MySQL;

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

while (my $object = $objects->next){
    my $type = $object->type;
    if ( !$plucy->indexed($object->id) ){
        $plucy->add($object->id, {
            '_type' => $type,
            'date' => $object->get_column('iso_created'),
            '_nsfw' => $object->nsfw,
            'title' => $object->$type->title,
            'description' => $object->$type->description,
        });
    }
}

$plucy->optimize;
