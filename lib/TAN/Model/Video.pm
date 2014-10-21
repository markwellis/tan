package TAN::Model::Video;
use Moose;

extends 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'HTML::Video::Embed' );

sub prepare_arguments {
    my ($self, $app) = @_; # $app sometimes written as $c

    return $app->config->{'Model::Video'}->{args};
}

__PACKAGE__->meta->make_immutable;
