package TAN::Schema::Result::OldLookup;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("old_lookup");
__PACKAGE__->add_columns(qw/new_id old_id type/);
__PACKAGE__->set_primary_key("new_id");

__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "new_id" },
);

1;
