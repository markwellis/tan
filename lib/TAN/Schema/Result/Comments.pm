package TAN::Schema::Result::Comments;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("comments");
__PACKAGE__->add_columns(
  "comment_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "comment",
  {
    data_type => "MEDIUMTEXT",
    default_value => undef,
    is_nullable => 0,
    size => 16777215,
  },
  "created",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
  "object_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "deleted",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
  "rev",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("comment_id");

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 20:07:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AIeWYMo0x0qXH1SZ0SSu8g

__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
);
__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "object_id" },
);

1;
