use strict;
use warnings;

use App::Daemon;
use Gearman::Worker;

use KinoSearchX::Simple;
use Storable;

App::Daemon::daemonize();

my $worker = Gearman::Worker->new;
$worker->job_servers('127.0.0.1:4730');

my $search_config = {
    'index_path' => '/mnt/stuff/TAN/search_index',
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
        }
    ],
    'search_fields' => ['title', 'description'],
    'search_boolop' => 'AND',
    'entries_per_page' => 27,
};

$worker->register_function( 'search_add_to_index' => \&add_to_index );
sub add_to_index{
    my ( $job ) = @_;

    my $searcher = KinoSearchX::Simple->new( $search_config );

    $searcher->update_or_create( Storable::thaw( $job->arg ) );
    $searcher->commit;
}

$worker->register_function( 'search_delete_from_index' => \&delete_from_index );
sub delete_from_index{
    my ( $job ) = @_;

    my $searcher = KinoSearchX::Simple->new( $search_config );
    $searcher->delete( $job->arg );
    $searcher->commit;
}

$worker->work while 1;
