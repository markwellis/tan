use 5.018;
use warnings;

use Gearman::Worker;

use LucyX::Simple;
use Storable;

use Config::Any;
use File::Basename;

say "Started: pid $$: " . scalar( localtime );

my $config_file = dirname(__FILE__) . '/config.json';

my $config = Config::Any->load_files( {
    'files' => [ $config_file ],
    'flatten_to_hash' => 1,
    'use_ext' => 1,
} );

$config = $config->{ $config_file };
my $searcher = LucyX::Simple->new( $config->{'search_args'} );

sub add_to_index{
    my ( $job ) = @_;

    my $document = Storable::thaw( $job->arg );
    say "adding " . $document->{'id'} . " to index" ;
    $searcher->update_or_create( $document );
    $searcher->commit(1);
    say "done";

    return 1;
}

sub delete_from_index{
    my ( $job ) = @_;

    my $ids = Storable::thaw( $job->arg );

    foreach my $id ( @{$ids} ){
        say "deleting " . $id . " from index" ;
        $searcher->delete( 'id', $id );
    }
    $searcher->commit(1);
    say "done";

    return 1;
}

my $worker = Gearman::Worker->new;
$worker->job_servers( @{ $config->{'job_servers'} } );
$worker->register_function( 'search_add_to_index' => \&add_to_index );
$worker->register_function( 'search_delete_from_index' => \&delete_from_index );

my $exit_trap = sub{
    $worker->unregister_function('search_add_to_index');
    $worker->unregister_function('search_delete_from_index');
    say "Ended: pid $$: " . scalar( localtime );
    exit;
};

$SIG{TERM} = $exit_trap;
$SIG{INT} = $exit_trap;

$worker->work while 1;
