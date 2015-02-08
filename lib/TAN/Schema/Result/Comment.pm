use utf8;
package TAN::Schema::Result::Comment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("TimeStamp");
__PACKAGE__->table("comments");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "user_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "comment",
  { accessor => "_comment", data_type => "mediumtext", is_nullable => 0 },
  "created",
  {
    accessor => "_created",
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
  "object_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "deleted",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "number",
  { data_type => "mediumint", extra => { unsigned => 1 }, is_nullable => 0 },
  "updated",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "plus",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "minus",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "admin_logs",
  "TAN::Schema::Result::AdminLog",
  { "foreign.comment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "object_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);
__PACKAGE__->has_many(
  "plus_minuses",
  "TAN::Schema::Result::PlusMinus",
  { "foreign.comment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-09-06 15:37:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MWm3bBlfIDY2I2t6Mip3pQ

__PACKAGE__->add_columns( '+created' => { set_on_create => 1 } );
__PACKAGE__->add_columns( '+updated' => { set_on_update => 1 } );

use DateTime::Format::Human::Duration;

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

sub set_deleted {
    my $self = shift;

    $self->result_source->schema->txn_do( sub {
        $self->update( {
            'deleted' => 1,
        } );

        $self->object->update( {
            comments => $self->object->comments->visible->count,
        } );
    });
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
