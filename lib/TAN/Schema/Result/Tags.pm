package TAN::Schema::Result::Tags;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("tags");
__PACKAGE__->add_columns(
  "tag_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
  "tag",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 30,
  },
);
__PACKAGE__->set_primary_key("tag_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-09-28 19:19:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lZs2OEZL2TgTNNldYhk6Jg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
