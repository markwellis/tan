package TAN::Schema::Result::PollAnswer;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("poll_answer");
__PACKAGE__->add_columns(
  "poll_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "answer_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "answer",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("answer_id");

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2yuJn4YdJ2YjHiMM992ceQ

__PACKAGE__->belongs_to(
  "poll",
  "TAN::Schema::Result::Poll",
  { poll_id => "poll_id" },
);

__PACKAGE__->has_many(
  "votes",
  "TAN::Schema::Result::PollVote",
  { "foreign.answer_id" => "self.answer_id" },
);

1;
