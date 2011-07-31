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

    my $public = {};
    foreach my $key ( keys(%{$submit_model->modules}) ){
        if ( my $alias = $submit_model->modules->{ $key }->config->{'alias'} ){
        #ignore aliases here so we can add them in the proper place
            next if ( $alias->{'name'} eq $key );
        }
        $public->{ $submit_model->modules->{ $key }->config->{'menu'}->{'position'} } = $key;
        if ( my $alias = $submit_model->modules->{ $key }->config->{'alias'} ){
            $public->{ $alias->{'menu'}->{'position'} } = $alias->{'name'};
        }
    }

    my @items = map $public->{$_}, sort(keys(%{$public}));
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
