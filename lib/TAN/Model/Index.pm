package TAN::Model::Index;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use Data::Page::Navigation;

sub indexinate{
    my ( $self, $c, $objects, $pager ) = @_;

    my @index;
    foreach my $object ( @{$objects} ){
        if ( $object->can('type') && ( $object->type eq 'comment' ) ){
            my $id = $object->id;
            $id =~ s/\D//g;
            push( @index, $c->model('DB::Comment')->find( $id ) );
        } elsif( ref($object) eq 'TAN::Model::DB::Comment' ){
            push( @index, $object );
        } else {
            push(@index, $c->model('DB::Object')->get( $object->id, $object->type ));
        }
    }

    if ( !scalar(@index) ){
        return undef;
    }

    return {
        objects     => \@index,
        pager       => $pager,
    };
}

__PACKAGE__->meta->make_immutable;
