package TAN::Schema::Result::TagDetails;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("tag_details");
__PACKAGE__->add_columns(
  "td_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
  "tag_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
  "user_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 10 },
  "username",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "picture_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 10 },
  "blog_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 10 },
  "link_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 10 },
  "date",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
);
__PACKAGE__->set_primary_key("td_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-09-28 19:19:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FTrZ381y/4bYlL+yiPzZeQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
