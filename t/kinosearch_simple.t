use strict;
use warnings;

use Test::More;
use KinoSearch::Simple;
use Data::Dumper;
use File::Temp;

#run main
main();

sub main{
    my $tempdir = File::Temp::tempdir( 'CLEANUP' => 1 );

    my $searcher = new_ok('KinoSearch::Simple' => [{
        'index_path' => $tempdir,
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
    }]);

    index_test_data($searcher);

    {
        my ( $objects, $pager ) = $searcher->search('title:bacon', 1);

        is(scalar(@{$objects}), 1, '"title:bacon" 1 result found');
        isa_ok($objects->[0], 'KinoSearch::Search::Result::Simple');
        is($objects->[0]->title, 'title filled with bacon', 'title matches');
    }

    {
        my ( $objects, $pager ) = $searcher->search('type:blog', 1);

        is(scalar(@{$objects}), 1, '"type:blog" 1 result found');
        isa_ok($objects->[0], 'KinoSearch::Search::Result::Simple');
        is($objects->[0]->title, 'this is a title', 'title matches');
    }

    {
        my ( $objects, $pager ) = $searcher->search('type:link', 1);

        is(scalar(@{$objects}), 2, '"type:link" 2 result found');
        isa_ok($objects->[0], 'KinoSearch::Search::Result::Simple');
        is($objects->[0]->title, 'title filled with bacon', 'link 1 title matches');
        is($objects->[1]->title, 'title for link 2', 'link 2 title matches');
    }

    {
        my ( $objects, $pager ) = $searcher->search('type:picture', 1);

        is(scalar(@{$objects}), 1, '"type:picture" 1 result found');
        isa_ok($objects->[0], 'KinoSearch::Search::Result::Simple');
        is($objects->[0]->title, 'pciture <-wrong not a link or a bg', 'title matches');
    }

    {
        my ( $object, $pager ) = $searcher->search( 'id:1' );
        ok($object, 'search reults');
        is( scalar(@{$object}), 1, '1 result');
        isa_ok($object->[0], 'KinoSearch::Search::Result::Simple');

        my ( $not_indexed ) = $searcher->search( 'id:9999' );
        is( $not_indexed, undef, " object id:9999 doesn't exist");
    }

    {
        my ( $object, $pager ) = $searcher->search( 'id:1' );
        ok($object, '"id:1" 1 result found');
        isa_ok($object->[0], 'KinoSearch::Search::Result::Simple');

        $searcher->delete( 'id' => 1);
        $searcher->commit;
        $object = $searcher->search( 'id:1' );
        is( $object, undef, "object id:1 doesn't exist (deleted)");
    }

    {
        my ( $object, $page ) = $searcher->search( 'id:2' );
        ok($object, 'reults found');
        isa_ok($object->[0], 'KinoSearch::Search::Result::Simple');
        is($object->[0]->title, 'title for link 2', 'title for link2 is as expected');
        my $old_title = $object->[0]->title;

        $searcher->update_or_create({
            'id' => $object->[0]->id,
            'nsfw' => $object->[0]->nsfw,
            'type' => $object->[0]->type,
            'title' => "updated ${old_title}",
            'description' => $object->[0]->description,
        });
        $searcher->commit;

        ( $object, $page ) = $searcher->search( 'id:2' );
        ok($object, "object id:2 exists");
        isa_ok($object->[0], 'KinoSearch::Search::Result::Simple');
        is($object->[0]->title, "updated ${old_title}", 'object updated');
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

        my ( $object, $pager ) = $searcher->search( 'id:99' );
        ok($object, 'object id:99 exists');
        isa_ok($object->[0], 'KinoSearch::Search::Result::Simple');
        is($object->[0]->title, 'update or create test', 'update or create test');
    }

    {
        $searcher->resultclass('KinoSearch::Simple::Result::Test'); 
        my ( $object, $pager ) = $searcher->search( 'id:99' );
        ok($object, 'search reults');
        is( scalar(@{$object}), 1, '1 result');
        isa_ok($object->[0], 'KinoSearch::Simple::Result::Test');
        is($object->[0]->{'message'}, 'using custom class', 'message from custom resultclass');
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

package KinoSearch::Simple::Result::Test;
use Moose;

sub BUILD{
    shift->{'message'} = 'using custom class';
}

1;
