package TAN::Schema::Result::TagObjects;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tag_objects");
__PACKAGE__->add_columns(
  "object_tag_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "tag_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "object_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "created",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
);
__PACKAGE__->set_primary_key("object_tag_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:upRc1jLOcXGENJbhvwg+bA

__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "object_id" },
);

__PACKAGE__->belongs_to(
  "tag",
  "TAN::Schema::Result::Tags",
  { tag_id => "tag_id" },
);

1;
