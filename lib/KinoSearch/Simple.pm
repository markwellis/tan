package KinoSearch::Simple;

use Moose;
use namespace::autoclean;

use KinoSearch::InvIndexer;
use KinoSearch::Searcher;
use KinoSearch::Analysis::PolyAnalyzer;
use KinoSearch::Search::Result::Simple;
use KinoSearch::Index::Term;
use KinoSearch::QueryParser::QueryParser;
use KinoSearch::Search::TermQuery;

use Data::Page;

has _language => (
    'is' => 'ro',
    'isa' => 'Str',
    'default' => 'en',
    'init_arg' => 'language',
);

has _index_path => (
    'is' => 'ro',
    'isa' => 'Str',
    'required' => 1,
    'init_arg' => 'index_path',
);

has _analyser => (
    'is' => 'ro',
    'init_arg' => undef,
    'default' => sub { return KinoSearch::Analysis::PolyAnalyzer->new( language => shift->_language ) },
);

has schema => (
    'is' => 'ro',
    'isa' => 'ArrayRef[HashRef]',
    'required' => 1,
);

has _indexer => (
    'is' => 'ro',
    'init_arg' => undef,
    'lazy_build' => 1,
);

sub _build__indexer{
    my $self = shift;

    my $indexer = KinoSearch::InvIndexer->new(
        'invindex' => $self->_index_path,
        'create'   => ( -f $self->_index_path . '/segments' ) ? 0 : 1,
        'analyzer' => $self->_analyser,
    );

    foreach my $spec ( @{$self->schema} ){
        $indexer->spec_field( %{$spec} );
    }

    return $indexer;
}

has _searcher => (
    'is' => 'ro',
    'init_arg' => undef,
    'lazy_build' => 1,
);

sub _build__searcher{
    my $self = shift;

    return KinoSearch::Searcher->new(
        'invindex' => $self->_index_path,
        'analyzer' => $self->_analyser,
    );
}

has search_fields => (
    'is' => 'ro',
    'isa' => 'ArrayRef[Str]',
    'required' => 1,
);

has search_boolop => (
    'is' => 'ro',
    'isa' => 'Str',
    'default' => 'OR',
);

has _query_parser => (
    'is' => 'ro',
    'init_arg' => undef,
    'lazy_build' => 1,
);

sub _build__query_parser{
    my $self = shift;

    return KinoSearch::QueryParser::QueryParser->new(
        analyzer       => $self->_analyser,
        fields         => $self->search_fields,
        default_boolop => $self->search_boolop,
    );
}

has resultclass => (
    'is' => 'rw',
    'isa' => 'ClassName',
    'lazy' => 1,
    'default' => 'KinoSearch::Search::Result::Simple',
);

has entries_per_page => (
    'is' => 'rw',
    'isa' => 'Num',
    'lazy' => 1,
    'default' => 100,
);

sub search{
    my ( $self, $query_string, $page ) = @_;

    return undef if ( !$query_string );
    $page ||= 1;

    my $query = $self->_query_parser->parse( $query_string );

    my $hits = $self->_searcher->search( 'query' => $query );
    my $pager = Data::Page->new($hits->total_hits, $self->entries_per_page, $page);
    $hits->seek( $pager->skipped, $pager->entries_on_this_page );

    my @results;
    while ( my $hit = $hits->fetch_hit_hashref ) {
        push( @results, $self->resultclass->new($hit) );
    }

    return ( \@results, $pager ) if scalar(@results);
    return undef;
}

sub create{
    my ( $self, $document ) = @_;

    return undef if ( !$document );

    my $doc = $self->_indexer->new_doc;

    foreach my $key ( keys(%{$document}) ){
        $doc->set_value(
            $key => $document->{$key},
        );
    }
    $self->_indexer->add_doc($doc);
}

sub update_or_create{
    my ( $self, $document ) = @_;

    return undef if ( !$document );
    $self->delete( $document->{'id'} );

    $self->create( $document );
}

sub delete{
    my ( $self, $key, $value ) = @_;

    return undef if ( !$key || !$value );

    my $term = KinoSearch::Index::Term->new( $key => $value );
    $self->_indexer->delete_docs_by_term($term);
}

sub commit{
    my ( $self ) = @_;

    $self->_indexer->finish( 'optimize' => 1 );

    #clear the searcher and indexer
    # they're lazy so they get rebuilt on next call...
    $self->_clear_indexer;
    $self->_clear_searcher;
}

__PACKAGE__->meta->make_immutable;

1;
