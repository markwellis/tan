package TAN::Schema::Result::Views;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("views");
__PACKAGE__->add_columns(qw/view_id ip object_id session_id user_id created type/);
__PACKAGE__->set_primary_key("view_id");

__PACKAGE__->add_unique_constraint('session_objectid' => [ qw/session_id object_id type/ ]);

__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
);
__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "object_id" },
);

1;
