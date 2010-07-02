package TAN::Controller::Sitemap;
use strict;
use warnings;

use parent 'Catalyst::Controller';
use POSIX qw/ceil/;

=head1 NAME

TAN::Controller::Sitemap

=head1 DESCRIPTION

Sitemap stuff

=head1 EXAMPLE

I</googledc796c4dad406173.html>
I</y_key_242ef28969a04b9c.html>

=over

search engine sitemap

=back

=head1 METHODS

=cut

TAN->register_hook(['object_new', 'object_updated', 'object_deleted'], '/sitemap/clear_cache');

sub clear_cache: Private{
    my ( $self, $c ) = @_;

    $c->clear_cached_page('/sitemap.*');

#trigger monitor to ping google and em
    `touch /tmp/tan_control/sitemap_ping`;
}

=head2 index: Private

B<@args = undef>

=over

sitemap index page

=back

=cut
sub index: Private{
    my ( $self, $c ) = @_;

    if ( $c->req->path eq 'sitemap/' ){
        $c->res->redirect( '/sitemap', 301 );
        $c->detach;
    }

    $c->cache_page(3600);

    my $sitemap_count = $c->model('MySQL::Object')->search({
        'type' => ['link', 'blog', 'picture'],
    })->count;
    $sitemap_count = ceil($sitemap_count / 1000);

    my @sitemaps;
    foreach my $count ( 0..$sitemap_count ){
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

    if ( !defined($page) ){
        $c->forward('/default');
        $c->detach();
    }

    my $object_rs = $c->model('MySQL::Object')->search({
            'type' => ['link', 'blog', 'picture'],
        }, {
        '+select' => \"DATE_FORMAT(created, '%Y-%m-%dT%H:%i:%S')",
        '+as' => 'W3Cdate',
        'order_by' => 'created',
        'rows' => 1000,
        'page' => $page,
        'prefetch' => ['link', 'blog', 'picture'],
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

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
