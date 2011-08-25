package TAN::Controller::Cms;
use Moose;
use namespace::autoclean;

use URI::Encode qw/uri_decode/;

BEGIN { extends 'Catalyst::Controller'; }

sub cms: Private{
    my ( $self, $c ) = @_;

#do caching of somekind
    my $cms = $c->model('MySql::Cms')->load( uri_decode( $c->req->path ) );

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
