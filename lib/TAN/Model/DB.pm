package TAN::Model::DB;
use Moose;

extends 'Catalyst::Model::DBIC::Schema';

sub ACCEPT_CONTEXT{
    my $self = shift;
    my $c = shift;

    $self->schema->trigger_event( sub{ $c->trigger_event( @_ ) } );
    $self->schema->cache( $c->cache );

    return $self;
}

__PACKAGE__->meta->make_immutable;
