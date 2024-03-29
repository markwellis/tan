package TAN::Schema::Result::PollAnswer;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("poll_answer");
__PACKAGE__->add_columns(qw/poll_id answer_id answer votes/);
__PACKAGE__->set_primary_key("answer_id");

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

sub percent{
    my ( $self, $total_votes ) = @_;

    my $votes = $self->get_column('votes');
    return 0 if ( !$total_votes || !$votes );
    my $percentage = sprintf("%0.2f", ((100 / $total_votes) * $votes) );
    $percentage =~ s/\.00//;
    return $percentage;
}

1;
