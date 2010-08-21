package TAN::Schema::Result::Comments;

use strict;
use warnings;
use utf8;

use base 'DBIx::Class';

use Parse::TAN;
my $parser = new Parse::TAN;

use DateTime;
use DateTime::Format::Human::Duration;

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
__PACKAGE__->table("comments");
__PACKAGE__->add_columns(
  "comment_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "number",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "comment",
  {
    data_type => "MEDIUMTEXT",
    default_value => undef,
    is_nullable => 0,
    size => 16777215,
    accessor => '_comment',
  },
  "created",
  {
    data_type => 'datetime',
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
    datetime_undef_if_invalid => 1,
    accessor => '_created',
  },
  "object_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "deleted",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key("comment_id");

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1eFIzFs/gXnMuzdofLP07Q

sub created{
    my ( $self ) = @_;

    my $date = $self->_created;

    return undef if !$date;

    my $now = DateTime->now;
    my $formatter = DateTime::Format::Human::Duration->new();
    my $duration = $now - $date;

    return $formatted[0] if !$formatted[1];
    my @formatted = split(', ', $formatter->format_duration( $duration ));
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
        $comment = $parser->parse( $self->_comment, $no_bb );
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
