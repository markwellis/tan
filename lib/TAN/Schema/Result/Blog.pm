package TAN::Schema::Result::Blog;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("blog");
__PACKAGE__->add_columns(
  "blog_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "picture_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "details",
  {
    data_type => "MEDIUMTEXT",
    default_value => undef,
    is_nullable => 0,
    size => 16777215,
    accessor => '_details',
  },
  "title",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "description",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 1000,
  },
);
__PACKAGE__->set_primary_key("blog_id");

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2yuJn4YdJ2YjHiMM992ceQ

use Parse::TAN;
my $parser = new Parse::TAN;

sub details{
    my ( $self ) = @_;

    return $self->get_details(0);
}

sub details_nobb{
    my ( $self ) = @_;

    return $self->get_details(1);
}

sub get_details{
    my ( $self, $no_bb ) = @_;

    $no_bb ||= 0;
    
    my $key = "blog.${no_bb}:" . $self->id;

    my $details = $self->result_source->schema->cache->get($key);
    if ( !$details ){
        $details = $parser->parse( $self->_details, $no_bb );
        $self->result_source->schema->cache->set($key, $details, 600);
    } else {
#decode cached coz otherwise its double encoded!
        utf8::decode($details);
    }

    return $details;
}

__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "blog_id" },
);
__PACKAGE__->belongs_to(
  "picture",
  "TAN::Schema::Result::Picture",
  { picture_id => "picture_id" },
);

1;
