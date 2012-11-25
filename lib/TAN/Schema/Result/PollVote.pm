package TAN::Schema::Result::PollVote;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("poll_vote");
__PACKAGE__->add_columns(qw/vote_id answer_id user_id/);
__PACKAGE__->set_primary_key("vote_id");

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
