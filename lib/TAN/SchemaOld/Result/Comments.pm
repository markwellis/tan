package TAN::SchemaOld::Result::Comments;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("comments");
__PACKAGE__->add_columns(
  "comment_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "username",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
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
  "details",
  {
    data_type => "MEDIUMTEXT",
    default_value => undef,
    is_nullable => 0,
    size => 16777215,
  },
  "picture_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 10 },
  "blog_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 10 },
  "link_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 10 },
  "edited",
  {
    data_type => "TIMESTAMP",
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
    size => 14,
    datetime_undef_if_invalid => 1,
  },
  "deleted",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key("comment_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-08 15:18:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cmTHJVzCW7hoTNVipDRTIg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
