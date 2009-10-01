package TAN::Schema::Result::ObjectDetails;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("object_details");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
  "type",
  { data_type => "ENUM", default_value => undef, is_nullable => 0, size => 7 },
  "date",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
  "promoted",
  {
    data_type => "TIMESTAMP",
    default_value => "0000-00-00 00:00:00",
    is_nullable => 1,
    datetime_undef_if_invalid => 1,
    size => 14,
  },
  "user",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
  "nsfw",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
  "old_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 10 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-09-28 19:19:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:am+ObG0aZtqpwkRV1pFe5Q

__PACKAGE__->might_have('link' => 'TAN::Schema::Result::Links', 'id');
__PACKAGE__->might_have('blog' => 'TAN::Schema::Result::Blogs', 'id');
__PACKAGE__->might_have('picture' => 'TAN::Schema::Result::Pictures', 'id');
__PACKAGE__->resultset_class('TAN::Schema::ResultSet::ObjectDetails');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
