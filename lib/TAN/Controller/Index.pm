package TAN::Controller::Index;
use strict;
use warnings;

use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::Index

=head1 DESCRIPTION

Main index page

=head1 EXAMPLE

I</index/$location/$upcoming/$page/>

=over

$location => all|link|blog|picture 

$upcoming  => boolean

$page => page number

=back

=head1 METHODS

=cut

TAN->register_hook(['object_created', 'object_promoted', 'object_deleted'], '/index/clear_cache');

sub clear_cache: Private{
    my ( $self, $c, $object_rs ) = @_;

    $object_rs->clear_index_cache();
    $c->clear_cached_page('/index.*');
}

=head2 index: Path Args(2)

B<@args = ($location, $upcoming)>
B<@params = (order)>

=over

validates the params

gets the index items

loads index template

=back

=cut
my $int_reg = qr/\D+/;
sub index :Path Args(2) {
    my ( $self, $c, $location, $upcoming ) = @_;

    $c->cache_page( 60 );

    my $page = $c->req->param('page') || 1;

    $page =~ s/$int_reg//g;

    $upcoming ||= 0;

    #redirect to somewhere sensible if someone has made up some random url...
    if ('/' . $c->req->path() ne "/index/${location}/${upcoming}/" && '/' . $c->req->path() ne '/'){
        $c->res->redirect("/index/${location}/${upcoming}/", 301 );
        $c->detach();
    } 

    my $order = $c->req->param('order') || 'created';

    my $search = {};
    if ( $upcoming ){
        $search->{'promoted'} = \'= 0';
    } else {
        $search->{'promoted'} = \'!= 0';
    }
    my ( $objects, $pager ) = $c->model('MySQL::Object')->index( $location, $page, $upcoming, $search, $order, $c->nsfw, "index" );

    if ( $objects ){
        $c->stash(
            'index' => $c->model('Index')->indexinate($c, $objects, $pager),
            'location' => $location,
            'page' => $page,
            'upcoming' => $upcoming,
            'order' => $order,
            'page_title' => ($upcoming ? 'Upcoming ' : 'Promoted ') . ucfirst($location) . ($location ne 'all' ? 's' : '' ),
        );
    }

    if ( !$c->stash->{'index'} ){
        $c->forward('/default');
        $c->detach();
    }
    
    $c->stash->{'template'} = 'index.tt';
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
