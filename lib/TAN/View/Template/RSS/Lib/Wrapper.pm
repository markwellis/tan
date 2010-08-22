package TAN::View::Template::RSS::Lib::Wrapper;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $content ) = @_;

    #wrapper goes here
    my $page_title = $c->view->xml($c->stash->{'page_title'});
    if ( $page_title ){
        $page_title = "TAN - ${page_title}";
    } else {
        $page_title = "This Aint News";
    }

    return 
qq\<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0">
    <channel>
        <title>${page_title}</title>
        <link>@{[ $c->view->xml( $c->req->base . $c->req->path ) ]}</link>
        <description>@{[ $c->view->xml($c->stash->{'page_meta_description'}) ]}</description>
        <lastBuildDate>@{[ $c->stash->{'build_date'} ]}</lastBuildDate>
        ${content}
    </channel>
</rss>\;
}

1;
