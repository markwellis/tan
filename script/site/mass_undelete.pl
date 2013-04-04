use 5.14.0;
use TAN::Model::MySQL;
use JSON;

my $admin_log_id = $ARGV[0];
die "need admin_log.id to continue" if !$admin_log_id;

my $db = TAN::Model::MySQL->new;
my $admin_log = $db->resultset('AdminLog')->find( {
    'log_id' => $admin_log_id
} );

die 'no admin_log.bulk' if !$admin_log->bulk;
my $bulk = from_json( $admin_log->bulk );

say "undo " . $admin_log->action;
if ( $admin_log->action eq 'mass_delete_comments' ){
    my $comments = $db->resultset('Comments')->search( {
        'comment_id' => $bulk,
    } )->update( {
        'deleted' => 0,
    } );
} elsif ( $admin_log->action eq 'mass_delete_objects' ){
    my $objects = $db->resultset('Object')->search( {
        'object_id' => $bulk,
    } )->update( {
        'deleted' => 0,
    } );
}
