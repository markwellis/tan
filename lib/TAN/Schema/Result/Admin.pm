package TAN::Schema::Result::Admin;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("admin");
__PACKAGE__->add_columns(
  "admin_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "role",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("admin_id");

__PACKAGE__->has_many(
  "map_user_role",
  "TAN::Schema::Result::UserAdmin",
  { "foreign.admin_id" => "self.admin_id" },
);

1;
