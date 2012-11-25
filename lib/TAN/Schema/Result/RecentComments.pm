package TAN::Schema::Result::RecentComments;
use strict;
use warnings;
use utf8;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->load_components(qw/InflateColumn::DateTime/);
__PACKAGE__->table("recent_comments");

__PACKAGE__->add_columns(qw/comment_id object_id username link_title picture_title blog_title poll_title video_title forum_title nsfw type/);
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

sub comment{
    my ( $self ) = @_;

    my $key = "comment.0:" . $self->id;

    my $comment = $self->result_source->schema->cache->get($key);
    if ( !$comment ){
        $comment = TAN->model('ParseHTML')->parse( $self->_comment );
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
    if ( $self->nsfw  ){
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
