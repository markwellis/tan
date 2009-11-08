package TAN::SchemaOld::Result::Log;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("log");
__PACKAGE__->add_columns(
  "log_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "username",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "user_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
  "link_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "blog_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "picture_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "type",
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
  "comment_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
);
__PACKAGE__->set_primary_key("log_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-08 15:18:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RkGItCBuUanDZDW+nTAKnA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
