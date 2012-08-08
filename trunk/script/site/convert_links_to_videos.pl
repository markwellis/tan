use strict;
use warnings;

use HTML::Video::Embed;
use TAN::Model::MySQL;
use Term::ProgressBar;

my $db = TAN::Model::MySQL->new;
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

my $embedder = HTML::Video::Embed->new;

while ( my $object = $objects->next ){
    my $url = $object->link->url;

    my ( $domain, $uri ) = $embedder->_is_video( $url );
    if ( defined( $domain ) ){
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
