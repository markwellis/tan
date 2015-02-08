package TAN::DBIx::Storage;
use strict;
use warnings;

use parent 'DBIx::Class::Storage::DBI::mysql';

use mro 'c3';

sub _gen_sql_bind {
    my ($self, $op, $ident, $args) = @_;

    my ( $sql, $bind ) = shift->next::method(@_);

    if (
        ( $op eq 'select' )
        && ( ref( $args )eq 'ARRAY')
        && ( ref( $args->[-2]) eq 'HASH')
        && ( ref( $ident )eq 'ARRAY')
        && ( ref( $ident->[0] ) eq 'HASH')

        && ( my $index = $args->[-2]->{use_index} )
        && ( my $alias = $ident->[0]->{'-alias'} )
        && ( my $name = $ident->[0]->{'-rsrc'}->name )
    ) {
        if ( defined $alias && defined $name ) {
            my $from = $self->sql_maker->_sqlcase('from');
            $alias = $self->sql_maker->_quote( $alias );
            $name = $self->sql_maker->_quote( $name );
            $index = $self->sql_maker->_quote( $index );

            my $part = join ' ', $from, $name, $alias;
            my $search = quotemeta( $part );
            my $replace = "$part USE INDEX($index)";

            $sql =~ s/$search/$replace/;
        }
    }

    return ( $sql, $bind );
}

1;
