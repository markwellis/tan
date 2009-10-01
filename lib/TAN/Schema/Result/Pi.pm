package TAN::Schema::Result::Pi;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("pi");
__PACKAGE__->add_columns(
  "ip",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 15,
  },
  "ua",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "url",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 512,
  },
  "referer",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 512,
  },
  "id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 1, size => 20 },
  "type",
  { data_type => "ENUM", default_value => undef, is_nullable => 1, size => 7 },
  "session_id",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 512,
  },
  "user_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 10 },
  "date",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-09-28 19:19:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Rquxe97Sciu751AAWzoqiw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
