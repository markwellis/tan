use strict;
use warnings;
use LucyX::Simple;
use Data::Dumper;

my $searcher = LucyX::Simple->new({
    'index_path' => '/mnt/stuff/TAN/search_index',
    'schema' => [
        {
            'name' => 'id',
            'type' => 'string',
        },{
            'name' => 'title', 
            'boost' => 3,
            'stored' => 0,
        },{
            'name' => 'description',
            'stored' => 0,
        },{
            'name' => 'content',
            'stored' => 0,
        },{
            'name' => 'type',
            'type' => 'string',
        },{
            'name' => 'nsfw',
            'stored' => 0,
        },{
            'name' => 'date',
            'type' => 'int32',
            'indexed' => 0,
            'stored' => 0,
            'sortable' => 1,
        },{
            'name' => 'username',
            'stored' => 0,
        },{
            'name' => 'tag',
            'stored' => 0,
        },
    ],
    'search_fields' => ['title', 'description', 'content', 'tag'],
    'search_boolop' => 'AND',
    'entries_per_page' => 27,
});

my $query = $ARGV[0];
my $page = $ARGV[1] || 1;

my ( $objects, $pager ) = $searcher->search( $query, $page );

warn Dumper( $objects );
