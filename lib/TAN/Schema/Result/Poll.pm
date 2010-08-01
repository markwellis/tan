package TAN::Schema::Result::Poll;

use strict;
use warnings;

use base 'DBIx::Class';

use DateTime;
use DateTime::Format::Human::Duration;

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
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
      data_type => 'datetime',
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
        return $formatter->format_duration( $duration );
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

#transaction
# prevents race condition
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
            return 1;
        }
    });
}

1;
