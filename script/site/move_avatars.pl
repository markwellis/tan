use 5.014;

use File::Copy;
use File::Basename;
use TAN::Model::MySQL;
use File::Path qw/mkpath/;

my $db = new TAN::Model::MySQL;

foreach my $file ( <root/static/user/avatar/*> ){
    if ( $file =~ m/\.no_crop$/ ){
        unlink( $file );
        next;
    }
    my $id = basename( $file );
    my @stat = stat( $file );

    move( $file, "${file}.move" );
    mkpath( "root/static/user/avatar/${id}/" );
    move( "${file}.move", "root/static/user/avatar/${id}/" . $stat[9] );
    
    my $user = $db->resultset('User')->find( {
        'user_id' => $id,
    } )->update( {
        'avatar' => $stat[9],
    } );
}
