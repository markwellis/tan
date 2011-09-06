package TAN::Model::MySQL;
use Moose;

extends 'Catalyst::Model::DBIC::Schema';

use TAN::DBProfiler;
 
__PACKAGE__->config(
    schema_class => 'TAN::Schema',
    connect_info => {
        'dsn' => 'dbi:mysql:tan;',
        'user' => 'thisaintnews',
        'password' => 'caBi2ieL',
        'mysql_enable_utf8' => 1,
    },
);

sub ACCEPT_CONTEXT{
    my $self = shift;
    my $c = shift;

    $self->schema->trigger_event( sub{ $c->trigger_event( @_ ) } );
    $self->schema->cache( $c->cache );
    
    return $self;
}

sub BUILD{
    my ( $self ) = @_;
    $self->storage->debugobj( TAN::DBProfiler->new() );

    my $debug = $ENV{'CATALYST_DEBUG'} ? 1 : 0;
    $self->storage->debug( $debug );
    return $self;
}

sub reset_count {
    my ($self) = @_;
    my $debugobj = $self->storage()->debugobj();

    if($debugobj) {
        $debugobj->{'_queries'} = 0;
        $debugobj->{'total_time'} = 0;
    }

    return 1;
}

sub get_query_count {
    my $self = shift;
    my $debugobj = $self->storage()->debugobj();

    if($debugobj) {
        return $debugobj->{'_queries'};
    }

    return;
}

__PACKAGE__->meta->make_immutable;
