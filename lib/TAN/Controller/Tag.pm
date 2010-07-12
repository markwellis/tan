package TAN::Controller::Tag;
use strict;
use warnings;

use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::Tag

=head1 DESCRIPTION

Tag Controller

=head1 EXAMPLE

I</tag/$tag>

=over

lists things with this tag

=back

=head1 METHODS

=cut

sub clear_index_caches: Event(object_created) Event(object_deleted) Event(object_updated){
    my ( $self, $c, $object ) = @_;

    $c->clear_cached_page('/tag.*');
}

=head2 index: Path Args(1) 

B<@args = ($tag)>

=over

loads things with $tag

=back

=cut
sub index: Path Args(1){
    my ( $self, $c, $tag ) = @_;

    $c->cache_page( 600 );
#get list of things with $tag
#assemble index

    my $tags_rs = $c->model('MySQL::Tags')->search({
        'tag' => $tag,
    })->first;

    if ( !defined($tags_rs) ){
        $c->forward('/default');
        $c->detach;
    }

    my $page = $c->req->param('page') || 1;
    my $order = $c->req->param('order') || 'created';

    my $key = $tag;
    $key =~ s/\W+/_/g;
    my ( $objects, $pager ) = $tags_rs->objects->index( 'all', $page, 1, {}, $order, $c->nsfw, "tag:${key}" );

    if ( $objects ){
        $c->stash(
            'index' => $c->model('Index')->indexinate($c, $objects, $pager),
            'order' => $order,
            'template' => 'tag.tt',
            'page_title' => "${tag} - Tag",
        );
    } else {
        $c->forward('/default');
        $c->detach;
    }
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
