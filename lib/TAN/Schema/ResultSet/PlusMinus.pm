package TAN::Schema::ResultSet::PlusMinus;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub add {
    my ( $self, $type, $user_id ) = @_;

    #the calling function is in a transaction
    my $existing_plus_minus = $self->find( {
            user_id     => $user_id,
        } );

    if ( $existing_plus_minus ){
    #found, delete
        my $old_type = $existing_plus_minus->type;
        $existing_plus_minus->delete;

        return undef if ( $old_type eq $type );
    }

    my $plus_minus = $self->create( {
            type    => $type,
            user_id => $user_id,
        } );

    return $type;
}

1;
