package TAN::Controller::Cms;
use Moose;
use namespace::autoclean;

use URI::Escape::XS qw/uri_unescape/;

BEGIN { extends 'Catalyst::Controller'; }

sub clear_caches: Event('cms_update'){
    my ( $self, $c, $url ) = @_;
    
    $c->cache->remove("cms:menu_items");
    $c->cache->remove("cms:page:${url}");
    $c->cache->remove("cms:content:${url}");
}

sub cms: Private{
    my ( $self, $c ) = @_;

    my $cms_page = $c->model('MySql::Cms')->load( uri_unescape( $c->req->path ) );

    if ( defined( $cms_page ) ){
        $c->stash(
            'cms_page' => $cms_page,
            'template' => 'cms.tt',
            'page_title' => $cms_page->title,
        );

        if ( $cms_page->nowrapper ){
            $c->res->header('Content-Type' => 'text/plain');
            $c->stash->{'template'} = 'cms_nowrapper.tt',
            $c->forward('View::NoWrapper');
        }

        # make sure we detach if is a valid cms url
        # otherwise the 404 handler will kick in
        $c->detach;
    }
}

__PACKAGE__->meta->make_immutable;
