package TAN::Schema::Result::Pictures;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("pictures");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 10 },
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
  "filename",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 300,
  },
  "x",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
  "y",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
  "size",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-09-28 19:19:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WunxBc/cK3OiIiNBU6wjfA

__PACKAGE__->belongs_to('details' => 'TAN::Schema::Result::ObjectDetails', 'id');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
