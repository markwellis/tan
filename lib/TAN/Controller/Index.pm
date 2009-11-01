package TAN::Controller::Index;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head2 index

=cut

sub index :Path :Args(3) {
    my ( $self, $c, $location, $upcoming, $page ) = @_;

    $c->cache_page( 120 );

    if ($location !~ m/^(all|link|blog|picture)$/){
        $location = 'all';
    }

    $upcoming =~ s/\D+//g;
    $page =~ s/\D+//g;

    $upcoming ||= 0;
    $page ||= 1;
    
    
    my $order = $c->req->param('order') || 'date';
    if ($order !~ m/^(date|promoted|plus|minus|views|comments)$/){
        $order = 'date';
    }

    #redirect to somewhere sensible if someone has made up some random url...
    if ('/' . $c->req->path() ne "/index/${location}/${upcoming}/${page}/" && '/' . $c->req->path() ne '/'){
        $c->res->redirect("/index/${location}/${upcoming}/${page}/", 301 );
        $c->detach();
    }

    $c->stash->{'location'} = $location;
    $c->stash->{'page'} = $page;
    $c->stash->{'upcoming'} = $upcoming;
    
    my $index_objects = $c->model('MySQL::ObjectDetails')->index($location, $page, $upcoming, $order);
    my @index = $index_objects->all;

    $c->stash->{'index_objects'} = {
        'objects' => \@index,
        'pager' => $index_objects->pager,
    };

    if ( !$c->stash->{'index_objects'}->{'objects'} ){
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
