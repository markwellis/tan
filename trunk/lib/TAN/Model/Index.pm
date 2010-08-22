package TAN::Model::Index;

use strict;
use warnings;
use parent 'Catalyst::Model';

=head1 NAME

TAN::Model::Index

=head1 DESCRIPTION

Makes an index

=head1 METHODS

=cut

=head2 indexinate

B<@args = ($c, $index_rs)>

=over

converts $index_rs into an index, or returns undef

=back

=cut
sub indexinate{
    my ( $self, $c, $objects, $pager ) = @_;

    my @index;
    foreach my $object ( @{$objects} ){
        push(@index, $c->model('MySQL::Object')->get( $object->id, $object->type ));
    }

    if ( !scalar(@index) ){
        return undef;
    }

    if ( $c->user_exists ){
        my @ids = map($_->id, @index);
        my $meplus_minus = $c->model('MySQL::PlusMinus')->meplus_minus($c->user->user_id, \@ids);

        foreach my $object ( @index ){
            if ( defined($meplus_minus->{ $object->object_id }->{'plus'}) ){
                $object->{'meplus'} = 1;
            } 
            if ( defined($meplus_minus->{ $object->object_id }->{'minus'}) ){
                $object->{'meminus'} = 1;  
            }
        }
    }

    return {
        'objects' => \@index,
        'pager' => $pager,
    };
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
