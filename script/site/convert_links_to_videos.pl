use strict;
use warnings;

use TAN;
use Term::ProgressBar;

my $db = TAN->model('MySQL');
my $objects = $db->resultset('Object')->search( {
        'type' => 'link',
    },{
        'prefetch' => 'link',
} );

my $count = $objects->count;
my $loop = 0;
my $progress = Term::ProgressBar->new({
    'name' => 'Converting',
    'count' => $count,
});
$progress->minor(0);

my $embedder = TAN->model('Video');

while ( my $object = $objects->next ){
    my $url = $object->link->url;

    my $res = TAN->model('Video')->url_to_embed( $url );
    if ( $res ){
        my $link = $object->link;
        $object->update( {
            'type' => 'video',
        } );

        $db->resultset('Video')->create( {
            'video_id' => $link->id,
            'title' => $link->title,
            'description' => $link->description,
            'picture_id' => $link->picture_id,
            'url' => $link->url,
        } );
        $link->delete;
    }
    $progress->update( ++$loop );
}
