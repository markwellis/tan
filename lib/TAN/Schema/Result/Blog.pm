package TAN::Schema::Result::Blog;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
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

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 20:07:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BnbstlSbZyjsVsB2jmaaGA

__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "blog_id" },
);
__PACKAGE__->belongs_to(
  "image",
  "TAN::Schema::Result::Picture",
  { picture_id => "picture_id" },
);

1;
