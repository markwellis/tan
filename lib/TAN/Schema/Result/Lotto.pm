package TAN::Schema::Result::Lotto;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
__PACKAGE__->table("lotto");
__PACKAGE__->add_columns(
  "lotto_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "created",
  {
    data_type => 'datetime',
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
    datetime_undef_if_invalid => 1,
  },
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "number",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 1 },
  "confirmed",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
  "winner",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key(qw/lotto_id/);

__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
);

1;
