package TAN::Model::Object;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

has 'public' => (
    'isa' => 'ArrayRef',
    'is' => 'ro',
    'lazy_build' => 1,
);
sub _build_public{
#build a list of public objects from submit model
    my $submit_model = TAN->model('Submit');

    my $menu = {};
    foreach my $key ( keys(%{$submit_model->modules}) ){
        $menu->{ $submit_model->modules->{ $key }->config->{'menu'}->{'position'} } = $key;
        if ( my $alias = $submit_model->modules->{ $key }->config->{'alias'} ){
            $menu->{ $alias->{'menu'}->{'position'} } = $alias->{'name'};
        }
    }

    my @items = map $menu->{$_}, sort(keys(%{$menu}));
    return \@items;
}

has 'private' => (
    'isa' => 'ArrayRef',
    'is' => 'ro',
    'lazy_build' => 1,
);
sub _build_private{
    return [qw/profile/];
}

sub valid_public_object{
    my ( $self, $type ) = @_;
    
    return grep( /^${type}$/, @{$self->public} );
}

__PACKAGE__->meta->make_immutable;
