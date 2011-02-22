package TAN::Schema::Result::Twitter;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("twitter");
__PACKAGE__->add_columns(
  "object_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "tweet",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 140,
  },
);
__PACKAGE__->set_primary_key("object_id");

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2yuJn4YdJ2YjHiMM992ceQ

__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "object_id" },
);

1;
