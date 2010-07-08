package KinoSearch::TAN;

use Moose;
use namespace::autoclean;

use KinoSearch::InvIndexer;
use KinoSearch::Searcher;
use KinoSearch::Analysis::PolyAnalyzer;
use KinoSearch::Search::Result::TAN;
use KinoSearch::Index::Term;
use KinoSearch::QueryParser::QueryParser;
use KinoSearch::Search::TermQuery;

use Data::Page;

has index_path => (
    'is' => 'rw',
    'isa' => 'Str',
    'required' => 1,
);

has analyser => (
    'is' => 'ro',
    'init_arg' => undef,
    'default' => sub { return KinoSearch::Analysis::PolyAnalyzer->new( language => 'en' ) },
);

has indexer => (
    'is' => 'ro',
    'init_arg' => undef,
    'lazy_build' => 1,
);

sub _build_indexer{
    my $self = shift;

    my $indexer = KinoSearch::InvIndexer->new(
        'invindex' => $self->index_path,
        'create'   => ( -f $self->index_path . '/segments' ) ? 0 : 1,
        'analyzer' => $self->analyser,
    );

    $indexer->spec_field( 'name' => 'title', 'boost' => 3 );
    $indexer->spec_field( 'name' => 'description' );
    $indexer->spec_field( 'name' => 'id' );
    $indexer->spec_field( 'name' => 'type' );
    $indexer->spec_field( 'name' => 'nsfw' );

    return $indexer;
}

has searcher => (
    'is' => 'ro',
    'init_arg' => undef,
    'lazy_build' => 1,
);

sub _build_searcher{
    my $self = shift;

    return KinoSearch::Searcher->new(
        'invindex' => $self->index_path,
        'analyzer' => $self->analyser,
    );
}

has query_parser => (
    'is' => 'ro',
    'init_arg' => undef,
    'lazy_build' => 1,
);

sub _build_query_parser{
    my $self = shift;

    return KinoSearch::QueryParser::QueryParser->new(
        analyzer       => $self->analyser,
        fields         => [ 'title', 'description' ],
        default_boolop => 'AND',
    );
}

sub search{
    my ( $self, $query_string, $page ) = @_;

    return undef if ( !$query_string );
    $page ||= 1;

    my $query = $self->query_parser->parse( $query_string );

    my $hits = $self->searcher->search( 'query' => $query );
    my $pager = Data::Page->new($hits->total_hits, 27, $page);
    $hits->seek( $pager->skipped, $pager->entries_on_this_page );

    my @return;
    while ( my $hit = $hits->fetch_hit_hashref ) {
        push( @return, KinoSearch::Search::Result::TAN->new($hit) );
    }

    return ( \@return, $pager );
}

sub create{
    my ( $self, $document ) = @_;

    return undef if ( !$document );

    my $doc = $self->indexer->new_doc;

    foreach my $key ( keys(%{$document}) ){
        $doc->set_value(
            $key => $document->{$key},
        );
    }
    $self->indexer->add_doc($doc);
}

sub update_or_create{
    my ( $self, $document ) = @_;

    return undef if ( !$document );
    $self->delete( $document->{'id'} );

    $self->create( $document );
}

sub by_id{
    my ( $self, $id ) = @_;

    return undef if ( !$id );

    my $term = KinoSearch::Index::Term->new( 'id' => $id );
    my $term_query = KinoSearch::Search::TermQuery->new( 'term' => $term );

    my $hits = $self->searcher->search( 'query' => $term_query );
    if ( $hits->total_hits ){
        #return the first hit
        my $hit = $hits->fetch_hit;
        return KinoSearch::Search::Result::TAN->new({
            'score' =>$hit->get_score,
            %{$hit->get_field_values},
        });
    }
    return undef;
}

sub delete{
    my ( $self, $id ) = @_;

    return undef if ( !$id );

    my $term = KinoSearch::Index::Term->new( 'id' => $id );
    $self->indexer->delete_docs_by_term($term);
}

sub commit{
    my ( $self ) = @_;

    $self->indexer->finish( 'optimize' => 1 );

    #clear the searcher and indexer
    # they're lazy so they get rebuilt on next call...
    $self->clear_indexer;
    $self->clear_searcher;
}

__PACKAGE__->meta->make_immutable;

1;
