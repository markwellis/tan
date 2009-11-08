package TAN::SchemaOld::Result::BlogDetails;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("blog_details");
__PACKAGE__->add_columns(
  "link_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 1, size => 20 },
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
    size => 300,
  },
  "user_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
  "username",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "date",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
  "promoted",
  {
    data_type => "TIMESTAMP",
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
    size => 14,
  },
  "url",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 300,
  },
  "views",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "category",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "blog_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "ised",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "details",
  {
    data_type => "MEDIUMTEXT",
    default_value => undef,
    is_nullable => 0,
    size => 16777215,
  },
);
__PACKAGE__->set_primary_key("blog_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-08 15:18:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JIR4UtmdOTd66eKSfUixCg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
