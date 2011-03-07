package TAN::Schema::Result::RecentComments;
use strict;
use warnings;
use utf8;

use base qw/DBIx::Class::Core/;

use Parse::TAN;
my $parser = new Parse::TAN;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->load_components(qw/InflateColumn::DateTime/);

__PACKAGE__->table("recent_comments");

__PACKAGE__->add_columns(
  "comment_id",
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
  "username",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "link_title",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "picture_title",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "blog_title",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "poll_title",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "nsfw",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
  "type",
  { data_type => "ENUM", default_value => undef, is_nullable => 0, size => 7 },
);
__PACKAGE__->set_primary_key("comment_id");

sub comment{
    my ( $self ) = @_;

    my $key = "comment.0:" . $self->id;

    my $comment = $self->result_source->schema->cache->get($key);
    if ( !$comment ){
        $comment = $parser->parse( $self->_comment );
        $self->result_source->schema->cache->set($key, $comment, 600);
    } else {
#decode cached comment coz otherwise its double encoded!
        utf8::decode($comment);
    }

    return $comment;
}

sub url_title{
    my ( $self ) = @_;

    my $title_key = $self->type . '_title';

    my $title = $self->$title_key;
    if ( $self->nsfw eq 'Y' ){
        $title .= '-NSFW';
    }

    my $not_alpha_numeric_reg = TAN->model('CommonRegex')->not_alpha_numeric;
    $title =~ s/$not_alpha_numeric_reg/-/g;
    return $title;
}

sub url{
    my ( $self ) = @_;

    return "/view/" . $self->type . '/' 
        . $self->object_id .'/' 
        . $self->url_title;
}

1;
