package TAN::SchemaOld::Result::PictureDetails;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("picture_details");
__PACKAGE__->add_columns(
  "picture_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
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
    is_nullable => 1,
    size => 300,
  },
  "user_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
  "date",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
    datetime_undef_if_invalid => 1,
  },
  "promoted",
  {
    data_type => "TIMESTAMP",
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
    size => 14,
    datetime_undef_if_invalid => 1,
  },
  "filename",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 300,
  },
  "views",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "category",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "username",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 300,
  },
  "x",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "y",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "size",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "nsfw",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key("picture_id");

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-08 15:18:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OPGO2qbGq6SmnE7daXqG8g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
