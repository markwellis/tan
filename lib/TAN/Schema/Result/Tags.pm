package TAN::Schema::Result::Tags;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tags");
__PACKAGE__->add_columns(qw/tag_id tag stem/);
__PACKAGE__->set_primary_key("tag_id");

__PACKAGE__->has_many(
  "tag_objects",
  "TAN::Schema::Result::TagObjects",
  { "foreign.tag_id" => "self.tag_id" },
);

__PACKAGE__->many_to_many(
  "objects" => "tag_objects",
  "object" 
);

1;
