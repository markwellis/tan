package TAN::Controller::Search;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Try::Tiny;

has '_mobile' => (
    'is' => 'ro',
    'isa' => 'HashRef',
    'default' => sub{
        return {'index' => 1};
    },
);

sub index: Path Args(0){
    my ( $self, $c ) = @_;

    my $q = $c->req->param('q') || '';
    my $page = $c->req->param('page') || 1;

    #nsfw...
    if ( !$c->nsfw && ($q !~ m/nsfw\:?/) ){
        $q .= ' NOT nsfw:y';
    }

    try{
        my ( $objects, $pager ) = $c->model('Search')->sorted_search( $q, {'date' => 1}, $page );
        $c->stash->{'index'} = $c->model('Index')->indexinate($c, $objects, $pager);
    };

    $c->stash(
        'page_title' => ( $c->req->param('q') || '' ) . " - Search",
        'template' => 'index.tt',
        'search' => 1,
        'can_rss' => 1,
    );
}

__PACKAGE__->meta->make_immutable;
