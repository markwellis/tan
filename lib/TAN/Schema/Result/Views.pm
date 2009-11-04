package TAN::Schema::Result::Views;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("views");
__PACKAGE__->add_columns(
  "view_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "ip",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
  "object_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "session_id",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 512,
  },
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 1, size => 20 },
  "created",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
);
__PACKAGE__->set_primary_key("view_id");
__PACKAGE__->belongs_to(
  "user_id",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
);
__PACKAGE__->belongs_to(
  "object_id",
  "TAN::Schema::Result::Object",
  { object_id => "object_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 00:45:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:X/7Poyt89UzfoUEQlNBdhQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
