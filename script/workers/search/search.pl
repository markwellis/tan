use strict;
use warnings;

use GearmanX::Simple::Worker;

use KinoSearchX::Simple;
use Storable;

use Config::Any;
use File::Basename;
use Log::Log4perl qw/:easy/;

my $config_file = dirname(__FILE__) . '/config.json';

my $config = Config::Any->load_files( {
    'files' => [ $config_file ],
    'flatten_to_hash' => 1,
    'use_ext' => 1,
} );

$config = $config->{ $config_file };
my $searcher = KinoSearchX::Simple->new( $config->{'search_args'} );

sub add_to_index{
    my ( $job ) = @_;

    my $document = Storable::thaw( $job->arg );
    ERROR "adding " . $document->{'id'} . " to index" ;
    $searcher->update_or_create( $document );
    $searcher->commit;

    return 1;
}

sub delete_from_index{
    my ( $job ) = @_;

    ERROR "deleting " . $job->arg . " from index" ;

    $searcher->delete( 'id', $job->arg );
    $searcher->commit;

    return 1;
}

my $worker = GearmanX::Simple::Worker->new( $config->{'job_servers'}, {
    'search_add_to_index' => \&add_to_index,
    'search_delete_from_index' => \&delete_from_index,
} );

$worker->work;
