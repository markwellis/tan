package TAN::Schema::Result::Cms;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
__PACKAGE__->table("cms");
__PACKAGE__->add_columns(
  "url",
  { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255 },
  "created",
  {
      data_type => 'datetime',
      is_nullable => 0,
      datetime_undef_if_invalid => 1,
      size => 14,
  },
  "updated",
  {
      data_type => 'datetime',
      is_nullable => 1,
      default_value => undef,
      datetime_undef_if_invalid => 1,
      size => 14,
  },
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "content",
  {
    data_type => "MEDIUMTEXT",
    default_value => undef,
    is_nullable => 0,
    size => 16777215,
  },
);
__PACKAGE__->set_primary_key("url");

__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
);

1;
