use strict;
use warnings;

use Lingua::Stem::Snowball;
use Term::ProgressBar;

use TAN::Model::MySQL;
my $db = TAN::Model::MySQL->new;

my $stemmer = Lingua::Stem::Snowball->new( lang => 'en' );

my $stemmed_tags = {};

my $tags = $db->resultset('Tags')->search;

my $count = $tags->count;
my $loop = 0;
my $progress = Term::ProgressBar->new({
    'name' => 'Adding stems',
    'count' => $count,
});
$progress->minor(0);
foreach my $tag_row ( $tags->all ){
    $tag_row->update( {
        'stem' => $stemmer->stem( $tag_row->tag ),
    } );
    $progress->update( ++$loop );
}
