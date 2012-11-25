package TAN::Schema::Result::TagObjects;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tag_objects");
__PACKAGE__->add_columns(qw/object_tag_id tag_id user_id object_id/);
__PACKAGE__->set_primary_key("object_tag_id");

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
