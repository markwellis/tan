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

    $searcher->add({
        'id' => 1,
        'type' => 'link',
        'title' => 'title filled with bacon',
        'description' => 'pork free description',
        'nsfw' => 'N',
    });

    $searcher->add({
        'id' => 2,
        'type' => 'link',
        'title' => 'title for link 2',
        'description' => 'i likes bacon',
        'nsfw' => 'N',
    });

    $searcher->add({
        'id' => 3,
        'type' => 'blog',
        'title' => 'this is a title',
        'description' => 'omg this is awesome check it out yo!',
        'nsfw' => 'N',
    });

    $searcher->add({
        'id' => 4,
        'type' => 'picture',
        'title' => 'pciture <-wrong not a link or a blog',
        'description' => 'mighty baconation',
        'nsfw' => 'N',
    });

    $searcher->optimise;

    my ( $objects, $pager ) = $searcher->search('title:bacon', 1);

    is(scalar(@{$objects}), 1, '"title:bacon" 1 result found');
    isa_ok($objects->[0], 'KinoSearch::Search::Result::TAN');
    is($objects->[0]->title, 'title filled with bacon', 'title matches');
}

done_testing();
