package TAN::Controller::Search;
use strict;
use warnings;

use parent 'Catalyst::Controller';

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
    my @ids;
    if ( $q  ){
        @ids = $c->model('Search')->search( $q );
    }

#perhaps there should be some kind of splice here to prevent massive sql ids lookup

    if ( scalar(@ids) ){
        my $page = $c->req->param('page') || 1;

        my $order = $c->req->param('order') || 'created';
        $c->stash->{'order'} = $order;

        my $search = {
            'object_id' => \@ids,
        };
        my $key = $q;
        $key =~ s/\W+/_/g;
        my ( $objects, $pager ) = $c->model('MySQL::Object')->index( 'all', $page, 1, $search, $order, $c->nsfw, "search:${key}" );

        if ( $objects ){
            $c->stash->{'index'} = $c->model('Index')->indexinate($c, $objects, $pager);
        }
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
