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
    $object->update( {
        'score' => $object->_calculate_score,
    } );
    $progress->update( ++$loop );
}
