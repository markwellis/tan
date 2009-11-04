package TAN::Schema::Result::Link;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("link");
__PACKAGE__->add_columns(
  "link_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "title",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "description",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 1000,
  },
  "picture_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "url",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 400,
  },
);
__PACKAGE__->set_primary_key("link_id");
__PACKAGE__->belongs_to(
  "picture_id",
  "TAN::Schema::Result::Picture",
  { picture_id => "picture_id" },
);
__PACKAGE__->belongs_to(
  "link_id",
  "TAN::Schema::Result::Object",
  { object_id => "link_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 20:07:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:f2mIjTlqe7amRjbRdDvC2A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
