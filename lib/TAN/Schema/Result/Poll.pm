package TAN::Schema::Result::Poll;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("poll");
__PACKAGE__->add_columns(
  "poll_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "picture_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "title",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "description",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 1000,
  },
  "end_date",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
);
__PACKAGE__->set_primary_key("poll_id");

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2yuJn4YdJ2YjHiMM992ceQ

__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "poll_id" },
);

__PACKAGE__->belongs_to(
  "image",
  "TAN::Schema::Result::Picture",
  { picture_id => "picture_id" },
);

__PACKAGE__->has_many(
  "answers",
  "TAN::Schema::Result::PollAnswer",
  { "foreign.poll_id" => "self.poll_id" },
);

1;
