package TAN::Schema::Result::Picture;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("picture");
__PACKAGE__->add_columns(qw/picture_id title description filename x y size sha512sum/);
__PACKAGE__->set_primary_key("picture_id");

__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "picture_id" },
);

__PACKAGE__->has_many(
  "blogs",
  "TAN::Schema::Result::Blog",
  { "foreign.picture_id" => "self.picture_id" },
);

__PACKAGE__->has_many(
  "links",
  "TAN::Schema::Result::Link",
  { "foreign.picture_id" => "self.picture_id" },
);

1;
