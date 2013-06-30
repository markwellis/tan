use strict;
use warnings;

use Term::ProgressBar;

use TAN::Model::MySQL;
my $db = TAN::Model::MySQL->new;

my $objects = $db->resultset('Object')->search;

my $count = $objects->count;
my $loop = 0;
my $progress = Term::ProgressBar->new({
    'name' => 'Scoring',
    'count' => $count,
});
$progress->minor(0);
foreach my $object ( $objects->all ){
    eval{
        $object->update({
            'plus' => $object->plus_minus->search({'type' => 'plus'})->count,
            'minus' => $object->plus_minus->search({'type' => 'minus'})->count,
            'comments' => $object->comments->search({'deleted' => 0})->count,
        })->discard_changes;
    };

    my $score = $object->_calculate_score;
    my $args = {
        'score' => $score,
    };
    if (
        ( $score >= 100 )
        && !$object->promoted
    ){
        $args->{'promoted'} = \'NOW()';
    }
    $object->update( $args );
    $progress->update( ++$loop );
}
