package TAN::Model::Index;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

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
        if ( scalar(@index) ){
            my @ids = map(defined($_) ? $_->id : undef, @index);
            my $meplus_minus = $c->model('MySQL::PlusMinus')->meplus_minus($c->user->user_id, \@ids);

            foreach my $object ( @index ){
                next if !$object;
                if ( defined($meplus_minus->{ $object->object_id }->{'plus'}) ){
                    $object->{'meplus'} = 1;
                } 
                if ( defined($meplus_minus->{ $object->object_id }->{'minus'}) ){
                    $object->{'meminus'} = 1;  
                }
            }
        }
    }

    return {
        'objects' => \@index,
        'pager' => $pager,
    };
}

__PACKAGE__->meta->make_immutable;
