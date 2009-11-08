use strict;
use warnings;

use lib '../../lib';
use TAN::Model::MySQL;
use TAN::Model::OldDB;

my $newdb = new TAN::Model::MySQL;
my $olddb = new TAN::Model::OldDB;


my $foobar = $olddb->resultset('LinkDetails');
foreach my $row ($foobar->all){
    warn $row->url;
}