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

    my $count = $self->search({
        'object_id' => $object_id,
        'type' => $type,
    })->count;
    return $count;
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
