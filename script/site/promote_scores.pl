use strict;
use warnings;

use Term::ProgressBar;

use TAN::Model::MySQL;
my $db = TAN::Model::MySQL->new;

my $objects = $db->resultset('Object')->search;

my $count = $objects->count;
my $loop = 0;
my $progress = Term::ProgressBar->new({
    'name' => 'Promoting',
    'count' => $count,
});
$progress->minor(0);
foreach my $object ( $objects->all ){
    if ( $object->score > 1 ){
        $object->update({
            'promoted' => \'NOW()',
        });
    }
    $progress->update( ++$loop );
}
