package TAN::Schema::Result::Tags;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("tags");
__PACKAGE__->add_columns(
  "tag_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "tag",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 30,
  },
);
__PACKAGE__->set_primary_key("tag_id");
__PACKAGE__->has_many(
  "tag_objects",
  "TAN::Schema::Result::TagObjects",
  { "foreign.tag_id" => "self.tag_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 00:45:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lP3gRj4zXCKGgcoultCjZw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
