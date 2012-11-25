package TAN::Schema::Result::Link;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("link");
__PACKAGE__->add_columns(qw/link_id title description picture_id url/);
__PACKAGE__->set_primary_key("link_id");

__PACKAGE__->belongs_to(
  "picture",
  "TAN::Schema::Result::Picture",
  { picture_id => "picture_id" },
);
__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "link_id" },
);

1;
