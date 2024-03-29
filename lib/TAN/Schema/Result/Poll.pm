package TAN::Schema::Result::Poll;

use strict;
use warnings;

use base 'DBIx::Class';

use DateTime;
use DateTime::Format::Human::Duration;

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
__PACKAGE__->table("poll");
__PACKAGE__->add_columns(qw/poll_id picture_id title description votes/);
__PACKAGE__->add_columns(
    "end_date" => {
        data_type => 'datetime',
        datetime_undef_if_invalid => 1,
    },
);
__PACKAGE__->set_primary_key("poll_id");

__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "poll_id" },
);

__PACKAGE__->belongs_to(
  "picture",
  "TAN::Schema::Result::Picture",
  { picture_id => "picture_id" },
);

__PACKAGE__->has_many(
  "answers",
  "TAN::Schema::Result::PollAnswer",
  { "foreign.poll_id" => "self.poll_id" },
);

__PACKAGE__->many_to_many(
  "votes" => "answers",
  "votes" 
);

sub ends{
    my ( $self ) = @_;

    my $now = DateTime->now;
    my $formatter = DateTime::Format::Human::Duration->new();
    my $duration = $now - $self->end_date;

    if ( $duration->is_negative ){
        my @formatted = split(', ', $formatter->format_duration( $duration ));
        return $formatted[0] if !$formatted[1];
        return join(', ', @formatted[0,1]);
    }

    return 0;
}

sub voted{
    my ( $self, $user_id ) = @_;
    
    return $self->votes->find({
        'user_id' => $user_id,
    });
}

sub vote{
    my ( $self, $user_id, $answer_id ) = @_;

    $self->result_source->schema->txn_do(sub{
        my $vote = $self->votes->find({
            'user_id' => $user_id,
        });

        if ( $vote ){
            return 0;
        } else {
            $self->votes->create({
                'user_id' => $user_id,
                'answer_id' => $answer_id,
            });
            $self->update( {
                    votes   => scalar $self->votes,
                } );
            my $answer = $self->answers->search( {
                    answer_id   => $answer_id,
                } )->first;

            $answer->set_column( votes => scalar $answer->votes );
            $answer->update;

            return 1;
        }
    });
}

1;
