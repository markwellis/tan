package TAN::Schema::Result::UserTokens;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("user_tokens");
__PACKAGE__->add_columns(
  "token_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "token",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 516,
  },
  "expires",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
  "token_type",
  { data_type => "ENUM", default_value => undef, is_nullable => 0, size => 6 },
);
__PACKAGE__->set_primary_key("token_id");
__PACKAGE__->belongs_to(
  "user_id",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 00:45:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nEGRRmltMC8gNvoVDqZH6w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
