package TAN::Schema::Result::Video;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("video");
__PACKAGE__->add_columns(qw/video_id title description picture_id url/);
__PACKAGE__->set_primary_key("video_id");

__PACKAGE__->belongs_to(
  "picture",
  "TAN::Schema::Result::Picture",
  { picture_id => "picture_id" },
);
__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "video_id" },
);

1;
