package TAN::Controller::Sitemap;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use POSIX qw/ceil/;
use Try::Tiny;

sub ping_sitemap: Event(object_created) Event(object_updated) Event(object_deleted){
    my ( $self, $c ) = @_;

    $c->clear_cached_page('/sitemap.*');

#trigger monitor to ping google and em
    try{
        $c->model('Gearman')->run( 'sitemap_ping', 0 );
    };
}

sub index: Private{
    my ( $self, $c ) = @_;

    if ( $c->req->path eq 'sitemap/' ){
        $c->res->redirect( '/sitemap', 301 );
        $c->detach;
    }

    $c->cache_page(3600);

    my $sitemap_count = $c->model('MySQL::Object')->search({
        'type' => TAN->model('Object')->public,
        'deleted' => 'N',
    })->count;
    $sitemap_count = ceil($sitemap_count / 1000);

    my @sitemaps;
    foreach my $count ( 1..$sitemap_count ){
        push(@sitemaps, "<sitemap><loc>" . $c->uri_for('xml', (sprintf("%06d", $count))) . "</loc></sitemap>");
    }

    my $output = '<?xml version="1.0" encoding="UTF-8"?>'
        . '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
        . join(' ', @sitemaps)
        . '</sitemapindex>';

    $c->res->output( $output );
    $c->detach();
}

sub xml: Path('xml') Args(1){
    my ( $self, $c, $page ) = @_;

    $c->cache_page(3600);
    $page = int($page); #convert into a real number
    if ( !defined($page) ){
        $c->forward('/default');
        $c->detach();
    }

    my $object_rs = $c->model('MySQL::Object')->search({
            'type' => TAN->model('Object')->public,
            'deleted' => 'N',
        }, {
        '+select' => \"DATE_FORMAT(created, '%Y-%m-%dT%H:%i:%S')",
        '+as' => 'W3Cdate',
        'order_by' => 'created',
        'rows' => 1000,
        'page' => $page,
        'prefetch' => TAN->model('Object')->public,
    });

    my @objects = $object_rs->all;

    if ( !scalar(@objects) ){
        $c->forward('/default');
        $c->detach();
    }

    my @locs;
    foreach my $object ( @objects ){
        my $loc = '<url>'
            .'<loc>http://thisaintnews.com' . $object->url . '</loc>'
            .'<lastmod>' . $object->get_column('W3Cdate') . '+00:00</lastmod>'
            .'<changefreq>daily</changefreq>'
            .'</url>';
        push(@locs, $loc);
    }

    my $output = '<?xml version="1.0" encoding="UTF-8"?>'
        . '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
        . join(' ', @locs)
        . '</urlset>';

    $c->res->output( $output );
    $c->detach();
}

__PACKAGE__->meta->make_immutable;
