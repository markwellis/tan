use strict;
use warnings;

use Lucy::Plan::Schema;
use Lucy::Plan::FullTextType;
use Lucy::Plan::StringType;
use Lucy::Analysis::PolyAnalyzer;
use Lucy::Index::Indexer;
use Lucy::Store::RAMFolder;
use Lucy::Search::IndexSearcher;
use Test::More;

my $schema = Lucy::Plan::Schema->new;
my $polyanalyzer = Lucy::Analysis::PolyAnalyzer->new(
    language => 'en',
);
my $type = Lucy::Plan::FullTextType->new(
    analyzer => $polyanalyzer,
);
$schema->spec_field( name => 'title',   type => $type );
$schema->spec_field( name => 'type', type => Lucy::Plan::StringType->new );

my $index = Lucy::Store::RAMFolder->new;

my $indexer = Lucy::Index::Indexer->new(
    index    => $index,
    schema   => $schema,
    create   => 1,
    truncate => 1,
);

foreach my $letter ('a' .. 'z') {
    $indexer->add_doc( {
        title => $letter,
        type => 'link',
    } );
    
    $indexer->add_doc( {
        title => $letter,
        type => 'picture',
    } );
    
    $indexer->add_doc( {
        title => $letter,
        type => 'cats',
    } );
    
    $indexer->add_doc( {
        title => $letter,
        type => 'sheep',
    } );
    
    $indexer->add_doc( {
        title => $letter,
        type => 'door',
    } );
    
    $indexer->add_doc( {
        title => $letter,
        type => 'doors',
    } );
}

$indexer->commit;
    
my $searcher = Lucy::Search::IndexSearcher->new( 
    index => $index,
);

my $query_parser = Lucy::Search::QueryParser->new(
    schema => $searcher->get_schema,
    analyzer => $polyanalyzer,
);

$query_parser->set_heed_colons(1);

{
    my $hits = $searcher->hits(
        query      => $query_parser->parse( "type:link" ),
        num_wanted => 100,
    );
    my $hit_count = $hits->total_hits;

    is( $hit_count, 26, '26 results for type:link' );
}

{
    my $hits = $searcher->hits(
        query      => $query_parser->parse( "type:picture" ),
        num_wanted => 100,
    );
    my $hit_count = $hits->total_hits;

    is( $hit_count, 26, '26 results for type:picture' );
}

{
    my $hits = $searcher->hits(
        query      => $query_parser->parse( "type:cats" ),
        num_wanted => 100,
    );
    my $hit_count = $hits->total_hits;

    is( $hit_count, 26, '26 results for type:cats' );
}

{
    my $hits = $searcher->hits(
        query      => $query_parser->parse( "type:sheep" ),
        num_wanted => 100,
    );
    my $hit_count = $hits->total_hits;

    is( $hit_count, 26, '26 results for type:sheep' );
}

{
    my $hits = $searcher->hits(
        query      => $query_parser->parse( "type:door" ),
        num_wanted => 100,
    );
    my $hit_count = $hits->total_hits;

    is( $hit_count, 26, '26 results for type:door' );
}
{
    my $hits = $searcher->hits(
        query      => $query_parser->parse( "type:doors" ),
        num_wanted => 100,
    );
    my $hit_count = $hits->total_hits;

    is( $hit_count, 26, '26 results for type:doors' );

#i would have expected this one to fail, since doors should be stemmed to door, and then no results found, however door is a type so it works, although just not in the way expected
}
