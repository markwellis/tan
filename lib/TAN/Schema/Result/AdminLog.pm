use utf8;
package TAN::Schema::Result::AdminLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("TimeStamp");
__PACKAGE__->table("admin_log");
__PACKAGE__->add_columns(
  "log_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "admin_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "action",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "reason",
  { data_type => "varchar", is_nullable => 0, size => 512 },
  "bulk",
  { data_type => "longtext", is_nullable => 1 },
  "user_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "comment_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "object_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "created",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "other",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("log_id");
__PACKAGE__->belongs_to(
  "admin",
  "TAN::Schema::Result::User",
  { user_id => "admin_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->belongs_to(
  "comment",
  "TAN::Schema::Result::Comment",
  { id => "comment_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);
__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "object_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);
__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-08-29 18:54:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TAqhRUUCPydsrGdDP9YrAA

__PACKAGE__->add_columns(
    "+created" => {
        accessor => '_created',
        set_on_create => 1,
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

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
