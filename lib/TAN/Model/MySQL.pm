package TAN::Model::MySQL;
use strict;
use warnings;

use TAN::DBProfiler;
use base 'Catalyst::Model::DBIC::Schema';
 
__PACKAGE__->config(
    schema_class => 'TAN::Schema',
    connect_info => {
        'dsn' => 'dbi:mysql:tan;',
        'user' => 'thisaintnews',
        'password' => 'caBi2ieL',
        'mysql_enable_utf8' => 1,
    },
);

sub COMPONENT {
    my $self = shift;
    my $c = shift;

    my $new = $self->next::method($c, @_);
   
    #hack so we can access the catalyst cache in the resultsets. 
    $new->schema->cache( $c->cache ) if $c;

    return $new;
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

1;
