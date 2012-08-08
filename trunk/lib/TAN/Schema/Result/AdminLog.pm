package TAN::Schema::Result::AdminLog;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
__PACKAGE__->table("admin_log");
__PACKAGE__->add_columns( qw/log_id admin_id action reason bulk user_id comment_id object_id other/ );

__PACKAGE__->add_columns( "created" =>
  {
    data_type => 'datetime',
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
    datetime_undef_if_invalid => 1,
    accessor => '_created',
  },
);

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

__PACKAGE__->set_primary_key("log_id");

__PACKAGE__->belongs_to(
  "admin",
  "TAN::Schema::Result::User",
  { "foreign.user_id" => "self.admin_id" },
);

__PACKAGE__->has_one(
  "user",
  "TAN::Schema::Result::User",
  { "foreign.user_id" => "self.user_id" },
);

__PACKAGE__->might_have(
  "comment",
  "TAN::Schema::Result::Comments",
  { "foreign.comment_id" => "self.comment_id" },
);

__PACKAGE__->might_have(
  "object",
  "TAN::Schema::Result::Object",
  { "foreign.object_id" => "self.object_id" },
);

1;
