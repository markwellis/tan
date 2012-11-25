package TAN::Schema::Result::Comments;

use strict;
use warnings;
use utf8;

use base 'DBIx::Class';

use DateTime;
use DateTime::Format::Human::Duration;

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
__PACKAGE__->table("comments");
__PACKAGE__->add_columns(qw/comment_id user_id number object_id deleted/);
__PACKAGE__->add_columns(
    "comment" => {
        accessor => '_comment',
    },
    "created" => {
        data_type => 'datetime',
        datetime_undef_if_invalid => 1,
        accessor => '_created',
    },
);
__PACKAGE__->set_primary_key("comment_id");

sub created{
    my ( $self ) = @_;

    my $date = $self->_created;

    return undef if !$date;

    my $now = DateTime->now;
    my $formatter = DateTime::Format::Human::Duration->new();
    my $duration = $now - $date;

    my @formatted = split(', ', $formatter->format_duration( $duration ));
    return $formatted[0] if !$formatted[1];
    return join(' ', @formatted[0,1]);
}

sub comment{
    my ( $self ) = @_;

    return $self->get_comment(0);
}

sub comment_nobb{
    my ( $self ) = @_;

    return $self->get_comment(1);
}

sub get_comment{
    my ( $self, $no_bb ) = @_;

    $no_bb ||= 0;
    
    my $key = "comment.${no_bb}:" . $self->id;

    my $comment = $self->result_source->schema->cache->get($key);
    if ( !$comment ){
        $comment = TAN->model('ParseHTML')->parse( $self->_comment, $no_bb );
        $self->result_source->schema->cache->set($key, $comment, 600);
    } else {
#decode cached comment coz otherwise its double encoded!
        utf8::decode($comment);
    }

    return $comment;
}

__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
);
__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "object_id" },
);

1;
