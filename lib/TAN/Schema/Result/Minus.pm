package TAN::Schema::Result::Minus;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("minus");
__PACKAGE__->add_columns(
  "minus_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "user_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
  "date",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
  "picture_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 10 },
  "blog_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 10 },
  "link_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 10 },
);
__PACKAGE__->set_primary_key("minus_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-09-28 19:19:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1O2oLipU3IaMEQQo3rFmPg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
