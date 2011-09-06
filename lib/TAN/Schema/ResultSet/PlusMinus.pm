package TAN::Schema::ResultSet::PlusMinus;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub add{
    my ( $self, $type, $object_id, $user_id ) = @_;

    if ( !defined($type) || !defined($object_id) || !defined($user_id) ){
    #return if things aint defined
        return undef;
    }

    my $deleted = 0;
#transaction
# prevents race condition
    eval{
        $self->result_source->schema->txn_do(sub{
            my $plusminus_rs = $self->find({
                'type' => $type,
                'object_id' => $object_id,
                'user_id' => $user_id,
            });

            if ( defined($plusminus_rs) ){
            #found, delete
                $plusminus_rs->delete;
                $deleted = 1;
            } else {
            #not found, create
                $plusminus_rs = $self->create({
                    'type' => $type,
                    'object_id' => $object_id,
                    'user_id' => $user_id,
                });
            }
        });
    };
#end txn

    my $plusminus_rs = $self->search({
        'object_id' => $object_id,
        'type' => $type,
    });

    return ( $plusminus_rs->count, $deleted );
}

sub meplus_minus{
    my ( $self, $user_id, $id ) = @_;

    return undef if ( !defined($user_id) );

    my $search_params = {
        'user_id' => $user_id,
    };

    # if id is defined
    if ( defined($id) ) {
        $search_params->{'object_id'} = $id;
    }
    my $meplus_minus_rs = $self->search( $search_params );

    my $ret_meplus_minus = {};

    foreach my $meplus_minus ( $meplus_minus_rs->all ){
        $ret_meplus_minus->{ $meplus_minus->object_id }->{ $meplus_minus->type } = 1;
    }
    return $ret_meplus_minus;
}

1;
