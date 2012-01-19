package TAN::Model::Index;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

sub indexinate{
    my ( $self, $c, $objects, $pager ) = @_;

    my @index;
    foreach my $object ( @{$objects} ){
        if ( $object->can('type') && ( $object->type eq 'comment' ) ){
            my $id = $object->id;
            $id =~ s/\D//g;
            push( @index, $c->model('MySQL::Comments')->find( $id ) );
        } else {
            push(@index, $c->model('MySQL::Object')->get( $object->id, $object->type ));
        }
    }

    if ( !scalar(@index) ){
        return undef;
    }

    if ( $c->user_exists ){
        if ( scalar(@index) ){
            my @ids = map(defined($_) && ( ref($_) eq 'TAN::Model::MySQL::Object') ? $_->id : undef, @index);
            my $meplus_minus = $c->model('MySQL::PlusMinus')->meplus_minus($c->user->user_id, \@ids);

            foreach my $object ( @index ){
                next if !$object || ( ref( $object ) ne 'TAN::Model::MySQL::Object' );
                if ( defined($meplus_minus->{ $object->object_id }->{'plus'}) ){
                    $object->{'meplus'} = 1;
                } 
                if ( defined($meplus_minus->{ $object->object_id }->{'minus'}) ){
                    $object->{'meminus'} = 1;  
                }
            }
        }
    }

    use Data::Page::Navigation;
    # this uses some crazy inject to rape Data::Page's namespace :(

    return {
        'objects' => \@index,
        'pager' => $pager,
    };
}

__PACKAGE__->meta->make_immutable;
