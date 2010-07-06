use strict;
use warnings;

use Test::More;
use KinoSearch::TAN;
use Data::Dumper;
use File::Temp;

#run main
main();

sub main{
    my $tempdir = File::Temp::tempdir( 'CLEANUP' => 1 );

    my $searcher = new_ok('KinoSearch::TAN' => [{
        'index_path' => $tempdir,
    }]);

    index_test_data($searcher);

    {
        my ( $objects, $pager ) = $searcher->search('title:bacon', 1);

        is(scalar(@{$objects}), 1, '"title:bacon" 1 result found');
        isa_ok($objects->[0], 'KinoSearch::Search::Result::TAN');
        is($objects->[0]->title, 'title filled with bacon', 'title matches');
    }

    {
        my ( $objects, $pager ) = $searcher->search('type:blog', 1);

        is(scalar(@{$objects}), 1, '"type:blog" 1 result found');
        isa_ok($objects->[0], 'KinoSearch::Search::Result::TAN');
        is($objects->[0]->title, 'this is a title', 'title matches');
    }

    {
        my ( $objects, $pager ) = $searcher->search('type:link', 1);

        is(scalar(@{$objects}), 2, '"type:link" 2 result found');
        isa_ok($objects->[0], 'KinoSearch::Search::Result::TAN');
        is($objects->[0]->title, 'title filled with bacon', 'link 1 title matches');
        is($objects->[1]->title, 'title for link 2', 'link 2 title matches');
    }

    {
        my ( $objects, $pager ) = $searcher->search('type:picture', 1);

        is(scalar(@{$objects}), 1, '"type:picture" 1 result found');
        isa_ok($objects->[0], 'KinoSearch::Search::Result::TAN');
        is($objects->[0]->title, 'pciture <-wrong not a link or a bg', 'title matches');
    }

    {
        my ( $object ) = $searcher->by_id(1);
        ok($object, 'object id:1 exists');
        isa_ok($object, 'KinoSearch::Search::Result::TAN');

        my ( $not_indexed ) = $searcher->by_id(9999);
        ok(!$not_indexed, "object id:9999 doesn't exist");
    }

    {
        my $object;
        $object = $searcher->by_id(1);
        ok($object, 'object id:1 exists');
        isa_ok($object, 'KinoSearch::Search::Result::TAN');

        $searcher->delete(1);
        $searcher->commit;
        $object = $searcher->by_id(1);
        ok(!$object, "object id:1 doesn't exist (deleted)");
    }

    {
        my $object;
        $object = $searcher->by_id(2);
        is($object->title, 'title for link 2', 'title for link2 is as expected');
        isa_ok($object, 'KinoSearch::Search::Result::TAN');
        my $old_title = $object->title;

        $searcher->update_or_create({
            'id' => $object->id,
            'nsfw' => $object->nsfw,
            'type' => $object->type,
            'title' => "updated ${old_title}",
            'description' => $object->description,
        });
        $searcher->commit;

        $object = $searcher->by_id(2);
        ok($object, "object id:2 exists");
        isa_ok($object, 'KinoSearch::Search::Result::TAN');
        is($object->title, "updated ${old_title}", 'object updated');
    }

    {
        $searcher->update_or_create({
            'id' => 99,
            'type' => 'link',
            'title' => 'update or create test',
            'description' => 'description',
            'nsfw' => 'Y',
        });
        $searcher->commit;

        my $object = $searcher->by_id(99);
        is($object->title, 'update or create test', 'update or create test');
        isa_ok($object, 'KinoSearch::Search::Result::TAN');
    }
}

sub index_test_data{
    my ( $searcher ) = @_;

    $searcher->create({
        'id' => 1,
        'type' => 'link',
        'title' => 'title filled with bacon',
        'description' => 'pork free description',
        'nsfw' => 'N',
    });

    $searcher->create({
        'id' => 2,
        'type' => 'link',
        'title' => 'title for link 2',
        'description' => 'i likes bacon',
        'nsfw' => 'N',
    });

    $searcher->create({
        'id' => 3,
        'type' => 'blog',
        'title' => 'this is a title',
        'description' => 'omg this is awesome check it out yo!',
        'nsfw' => 'N',
    });

    $searcher->create({
        'id' => 4,
        'type' => 'picture',
        'title' => 'pciture <-wrong not a link or a bg',
        'description' => 'mighty baconation',
        'nsfw' => 'N',
    });

    $searcher->commit;
}

done_testing();
