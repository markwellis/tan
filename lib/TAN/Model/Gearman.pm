package TAN::Model::Gearman;
use Moose;
use namespace::autoclean;

use Gearman::Client;
use Storable;

extends 'Catalyst::Model';

has 'job_servers' => (
    'is' => 'ro',
    'isa' => 'ArrayRef',
    'required' => 1,
);

has 'client' => (
    'is' => 'ro',
    'isa' => 'Gearman::Client',
    'init_arg' => undef,
    'builder' => '_build_client',
    'lazy' => 1,
);

sub _build_client{
    my ( $self ) = @_;

    my $client = Gearman::Client->new;
    $client->job_servers( @{$self->job_servers} );

    return $client;
}

sub run{
    my ( $self, $sub, $args ) = @_;

    my $tasks = $self->client->new_task_set;

    if ( ref( $args ) ){
        $args = Storable::freeze( $args );
    }

    my $handle = $tasks->add_task( $sub => $args );
}

__PACKAGE__->meta->make_immutable;
