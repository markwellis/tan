use strict;
use warnings;

use Lingua::Stem::Snowball;
use Data::Dumper;

use TAN::Model::MySQL;
my $db = TAN::Model::MySQL->new;

my $stemmer = Lingua::Stem::Snowball->new( lang => 'en' );

my $stemmed_tags = {};

my $tags = $db->resultset('Tags')->search;

foreach my $tag_row ( $tags->all ){
    my $tag = $tag_row->tag;
    next if !defined( $tag );

    my $stemmed_tag = $stemmer->stem( $tag );
    next if !defined( $stemmed_tag );

    if ( !defined( $stemmed_tags->{ $stemmed_tag } ) ){
        $stemmed_tags->{ $stemmed_tag } = [];
    }
    push( @{ $stemmed_tags->{ $stemmed_tag } }, $tag );
}

warn Dumper( $stemmed_tags );
