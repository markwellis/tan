package KinoSearch::TAN;

use Moose;
use namespace::autoclean;

use KinoSearch::InvIndexer;
use KinoSearch::Searcher;
use KinoSearch::Analysis::PolyAnalyzer;
use KinoSearch::Search::Result::TAN;
use KinoSearch::Index::Term;
use KinoSearch::QueryParser::QueryParser;

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

has invindexer => (
    'is' => 'ro',
    'init_arg' => undef,
    'lazy_build' => 1,
);

sub _build_invindexer{
    my $self = shift;

    my $invindexer = KinoSearch::InvIndexer->new(
        'invindex' => $self->index_path,
        'create'   => ( -f $self->index_path . '/segments' ) ? 0 : 1,
        'analyzer' => $self->analyser,
    );

    $invindexer->spec_field( 'name'  => 'title', 'boost' => 3 );

    $invindexer->spec_field( 'name' => 'description' );

    $invindexer->spec_field( 'name'  => 'id' );

    $invindexer->spec_field( 'name'  => 'type' );

    $invindexer->spec_field( 'name' => 'nsfw' );

    return $invindexer;
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

    my $query = $self->query_parser->parse( $query_string );

    my $hits = $self->searcher->search( query => $query );
    my $pager = Data::Page->new($hits->total_hits, 27, $page);
    $hits->seek( $pager->skipped, $pager->entries_on_this_page );

    my @return;
    while ( my $hit = $hits->fetch_hit_hashref ) {
        push( @return, KinoSearch::Search::Result::TAN->new($hit) );
    }

    return ( \@return, $pager );
}

sub add{
    my ( $self, $document ) = @_;

    my $doc = $self->invindexer->new_doc;

    foreach my $key ( keys(%{$document}) ){
        $doc->set_value(
            $key => $document->{$key},
        );
    }
    $self->invindexer->add_doc($doc);
}

sub optimise{
    my ( $self ) = @_;

    $self->invindexer->finish( 'optimize' => 1 );

    #clear the searcher and indexer
    # they're lazy so they get rebuilt on next call...
    $self->clear_invindexer;
    $self->clear_searcher;
}

__PACKAGE__->meta->make_immutable;

1;
