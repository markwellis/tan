package TAN::Schema::Result::Picture;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("picture");
__PACKAGE__->add_columns(
  "picture_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
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
  "filename",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 300,
  },
  "x",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "y",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "size",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("picture_id");
__PACKAGE__->has_many(
  "blogs",
  "TAN::Schema::Result::Blog",
  { "foreign.picture_id" => "self.picture_id" },
);
__PACKAGE__->has_many(
  "links",
  "TAN::Schema::Result::Link",
  { "foreign.picture_id" => "self.picture_id" },
);
__PACKAGE__->belongs_to(
  "picture_id",
  "TAN::Schema::Result::Object",
  { object_id => "picture_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 00:45:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lTyENA2cLNWx+J7yzm8sVQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
