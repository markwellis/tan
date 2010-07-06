package TAN::Controller::Search;
use strict;
use warnings;

use parent 'Catalyst::Controller';
use Time::HiRes qw/time/;
use Data::Page;


TAN->register_hook(['object_created', 'object_updated'], '/search/add_to_index');
sub add_to_index: Private{
    my ( $self, $c, $object ) = @_;

    my $type = $object->type;
    $c->model('Search')->update_or_create({
        'id' => $object->id,
        'type' => $object->type,
        'nsfw' => $object->nsfw,
        'title' => $object->$type->title,
        'description' => $object->$type->description,
    });

    $c->model('Search')->commit;
}

TAN->register_hook(['object_deleted'], '/search/delete_from_index');
sub delete_from_index: Private{
    my ( $self, $c, $object ) = @_;

    $c->model('Search')->delete( $object->id );
    $c->model('Search')->commit;
}

=head1 NAME

TAN::Controller::Search

=head1 DESCRIPTION

FAQ page

=head1 EXAMPLE

I</search/>

=head1 METHODS

=cut

=head2 index: Path Args(0)

B<@args = undef>

=over

loads chat template... 

=back

=cut
sub index: Path Args(0){
    my ( $self, $c ) = @_;

    my $q = $c->req->param('q');
    my $page = $c->req->param('page') || 1;

    if ( my ( $objects, $pager ) = $c->model('Search')->search( $q, $page ) ){
        $c->stash->{'index'} = $c->model('Index')->indexinate($c, $objects, $pager);
    }

    $c->stash(
        'page_title' => "${q} - Search",
        'template' => 'search.tt',
    );
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
