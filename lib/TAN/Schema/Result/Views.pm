package TAN::Schema::Result::Views;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('UTF8Columns', "Core");
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
__PACKAGE__->utf8_columns(qw/ip/);

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lF3E02Bwvewu/kyyW2RvAw

__PACKAGE__->add_unique_constraint('session_objectid' => [ qw/session_id object_id/ ]);

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
