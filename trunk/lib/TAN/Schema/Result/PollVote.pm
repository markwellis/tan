package TAN::Schema::Result::PollVote;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("poll_vote");
__PACKAGE__->add_columns(
  "vote_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "answer_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
);
__PACKAGE__->set_primary_key("vote_id");

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2yuJn4YdJ2YjHiMM992ceQ

__PACKAGE__->belongs_to(
  "answer",
  "TAN::Schema::Result::PollAnswer",
  { answer_id => "answer_id" },
);

__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
);

1;
