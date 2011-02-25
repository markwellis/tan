use strict;
use warnings;

use GearmanX::Simple::Worker;

use KinoSearchX::Simple;
use Storable;

use Config::Any;
use File::Basename;
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

    $searcher->update_or_create( Storable::thaw( $job->arg ) );
    $searcher->commit;
}

sub delete_from_index{
    my ( $job ) = @_;

    $searcher->delete( $job->arg );
    $searcher->commit;
}

my $worker = GearmanX::Simple::Worker->new( $config->{'job_servers'}, {
    'search_add_to_index' => \&add_to_index,
    'search_delete_from_index' => \&delete_from_index,
} );

$worker->work;
