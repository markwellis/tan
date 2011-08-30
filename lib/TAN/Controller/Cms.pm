package TAN::Controller::Cms;
use Moose;
use namespace::autoclean;

use URI::Escape::XS qw/uri_unescape/;

BEGIN { extends 'Catalyst::Controller'; }

sub clear_caches: Event('cms_update'){
    my ( $self, $c, $url ) = @_;
    
    $c->cache->remove("cms:menu_items");
    $c->cache->remove("cms:page:${url}");
}

sub cms: Private{
    my ( $self, $c ) = @_;

    my $cms = $c->model('MySql::Cms')->load( uri_unescape( $c->req->path ) );

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
