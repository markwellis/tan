package TAN::Schema::ResultSet::PlusMinus;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

TAN::Schema::ResultSet::PlusMinus

=head1 DESCRIPTION

PlusMinus ResultSet

=head1 METHODS

=cut

=head2 add

B<@args = $type, $object_id, $user_id>

=over

if !existing

=over

adds $type(plus, minus) to $object_id for $user_id

=back

else

=over

removes $type(plus, minus) on $object_id for $user_id

=back

=back

=cut
sub add{
    my ( $self, $type, $object_id, $user_id ) = @_;

    if ( !defined($type) || !defined($object_id) || !defined($user_id) ){
    #return if things aint defined
        return undef;
    }

#transaction
# prevents race condition (apparently....)
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

    #if count > promotion cut off, then promote
    my $count = $plusminus_rs->count;
    my $object_rs = $plusminus_rs->first->object;

    #HACK - this probably isnt that nice!!
    # not impotant coz will be gone when #53 is complete
    if ( 
        ($object_rs->promoted eq '0000-00-00 00:00:00') 
        && ($count >= TAN->config->{'promotion_cutoff'})
    ){
        $object_rs->promote;
    }

    return $count;
}

=head2 meplus_minus

B<@args = $user_id, $id>

=over

gets meplus or meminus for self, id or array of ids

=back

=cut
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


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
