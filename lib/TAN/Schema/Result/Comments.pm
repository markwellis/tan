package TAN::Schema::Result::Comments;

use strict;
use warnings;

use base 'DBIx::Class';

use Parse::TAN;
my $parser = new Parse::TAN;

__PACKAGE__->load_components("Core");
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
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
  "object_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "deleted",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key("comment_id");

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1eFIzFs/gXnMuzdofLP07Q

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
    
    my $comment = $self->result_source->schema->cache->get("comment.${no_bb}:" . $self->id);
    if ( !defined($comment) ){
        $comment = $parser->parse( $self->_comment, $no_bb );
        $self->result_source->schema->cache->set("comment.${no_bb}:" . $self->id, $comment, 120);
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
