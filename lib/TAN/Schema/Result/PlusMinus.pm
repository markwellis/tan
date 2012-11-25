package TAN::Schema::Result::PlusMinus;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("plus_minus");
__PACKAGE__->add_columns(qw/plus_minus_id user_id object_id type/);
__PACKAGE__->set_primary_key("plus_minus_id");

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
