package TAN::Model::MySQL;
use strict;

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

=head1 NAME

TAN::Model::MySQL

=head1 DESCRIPTION

MySQL connection

=head1 METHODS

=cut

sub COMPONENT {
    my $self = shift;
    my $c = shift;

    my $new = $self->next::method($c, @_);
   
    #hack so we can access the catalyst cache in the resultsets. 
    $new->schema->cache( $c->cache ) if $c;

    return $new;
}

=head2 BUILD

B<@args = undef>

=over

sets debugobj to new TAN::DBProfiler

=back

=cut
sub BUILD{
    my ( $self ) = @_;
    $self->storage->debugobj( TAN::DBProfiler->new() );

    my $debug = $ENV{'CATALYST_DEBUG'} ? 1 : 0;
    $self->storage->debug( $debug );
    return $self;
}

=head2 reset_count

B<@args = undef>

=over

resets sql query count to 0

=back

=cut
sub reset_count {
    my ($self) = @_;
    my $debugobj = $self->storage()->debugobj();

    if($debugobj) {
        $debugobj->{'_queries'} = 0;
        $debugobj->{'total_time'} = 0;
    }

    return 1;
}

=head2 get_query_count

B<@args = undef>

=over

returns sql query count

=back

=cut
sub get_query_count {
    my $self = shift;
    my $debugobj = $self->storage()->debugobj();

    if($debugobj) {
        return $debugobj->{'_queries'};
    }

    return;
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
