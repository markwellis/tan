package TAN::Controller::Cms;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub cms: Private{
    my ( $self, $c ) = @_;

#do caching of somekind
    my $cms = $c->model('MySql::Cms')->search( {
        'url' => $c->req->path,
    } )->first;

    if ( defined( $cms ) ){
        $c->stash(
            'cms' => $cms,
            'template' => 'cms.tt',
            'page_title' => $cms->title,
        );

        # make sure we detach if is a valid cms url
        # otherwise the 404 handler will kick in
        $c->detach;
    }
}

__PACKAGE__->meta->make_immutable;
