package TAN::Schema::Result::UserTokens;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("user_tokens");
__PACKAGE__->add_columns(
  "token_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
  "user_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 10 },
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
  "type",
  { data_type => "ENUM", default_value => "reg", is_nullable => 0, size => 6 },
);
__PACKAGE__->set_primary_key("token_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-09-28 19:19:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PKtoJnY5MPEDjOt2NrSL/w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
