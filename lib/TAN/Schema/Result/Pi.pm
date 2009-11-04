package TAN::Schema::Result::Pi;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("pi");
__PACKAGE__->add_columns(
  "pi_id",
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
__PACKAGE__->set_primary_key("pi_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 00:43:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AExPGb7hD3fyLVcl1eXu3g

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
