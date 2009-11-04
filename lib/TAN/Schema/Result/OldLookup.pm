package TAN::Schema::Result::OldLookup;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("old_lookup");
__PACKAGE__->add_columns(
  "new_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "old_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("new_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sWBj5FcSRXxXG5Qd3S0TQA

__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "new_id" },
);

1;
