package TAN::Schema::Result::Object;

use strict;
use warnings;

use base 'DBIx::Class';

use DateTime;
use DateTime::Format::Human::Duration;

use POSIX;

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
__PACKAGE__->table("object");
__PACKAGE__->add_columns(
  "object_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "type",
  { data_type => "ENUM", default_value => undef, is_nullable => 0, size => 7 },
  "created",
  {
      data_type => 'datetime',
      is_nullable => 0,
      datetime_undef_if_invalid => 1,
      size => 14,
      accessor => '_created',
  },
  "promoted",
  {
      data_type => 'datetime',
      datetime_undef_if_invalid => 1,
      default_value => undef,
      is_nullable => 1,
      size => 14,
      accessor => '_promoted',
  },
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "nsfw",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
  "views",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "plus",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "minus",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "comments",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "deleted",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
  "score",
  { data_type => "FLOAT", default_value => undef, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("object_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zHtxjN50TOUzr4b7Jb877A

sub created{
    my ( $self ) = @_;

    return $self->date_ago( $self->_created );
}

sub promoted{
    my ( $self ) = @_;

    return $self->date_ago( $self->_promoted );
}

sub date_ago{
    my ( $self, $date ) = @_;

    return undef if !$date;
    return undef if ( ref( $date ) eq 'SCALAR' );

    my $now = DateTime->now;
    my $formatter = DateTime::Format::Human::Duration->new();
    my $duration = $now - $date;

    my @formatted = split(', ', $formatter->format_duration( $duration ));

    return $formatted[0] if !$formatted[1];
    return join(' ', @formatted[0,1]);
}

__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
);

__PACKAGE__->might_have(
  "blog",
  "TAN::Schema::Result::Blog",
  { "foreign.blog_id" => "self.object_id" },
);

__PACKAGE__->might_have(
  "link",
  "TAN::Schema::Result::Link",
  { "foreign.link_id" => "self.object_id" },
);

__PACKAGE__->might_have(
  "video",
  "TAN::Schema::Result::Video",
  { "foreign.video_id" => "self.object_id" },
);

__PACKAGE__->might_have(
  "forum",
  "TAN::Schema::Result::Forum",
  { "foreign.forum_id" => "self.object_id" },
);

__PACKAGE__->might_have(
  "picture",
  "TAN::Schema::Result::Picture",
  { "foreign.picture_id" => "self.object_id" },
);

__PACKAGE__->might_have(
  "profile",
  "TAN::Schema::Result::Profile",
  { "foreign.profile_id" => "self.object_id" },
);

__PACKAGE__->might_have(
  "poll",
  "TAN::Schema::Result::Poll",
  { "foreign.poll_id" => "self.object_id" },
);

__PACKAGE__->might_have(
  "old_lookup",
  "TAN::Schema::Result::OldLookup",
  { "foreign.new_id" => "self.object_id" },
);

__PACKAGE__->has_many(
  "comments",
  "TAN::Schema::Result::Comments",
  { "foreign.object_id" => "self.object_id" },
);

__PACKAGE__->has_many(
  "plus_minus",
  "TAN::Schema::Result::PlusMinus",
  { "foreign.object_id" => "self.object_id" },
);

__PACKAGE__->has_many(
  "views",
  "TAN::Schema::Result::Views",
  { "foreign.object_id" => "self.object_id" },
);

__PACKAGE__->has_many(
  "tag_objects",
  "TAN::Schema::Result::TagObjects",
  { "foreign.object_id" => "self.object_id" },
);

__PACKAGE__->many_to_many(
  "tags" => "tag_objects",
  "tag" 
);

sub url_title{
    my ( $self ) = @_;

    my $type = $self->type;
    my $title = $self->$type->title;
    if ( $self->nsfw eq 'Y' ){
        $title .= '-NSFW';
    }

    my $not_alpha_numeric_reg = TAN->model('CommonRegex')->not_alpha_numeric;
    $title =~ s/$not_alpha_numeric_reg/-/g;
    return $title;
}

sub url{
    my ( $self ) = @_;

    return '/view/' . $self->type . '/' 
        . $self->object_id .'/' 
        . $self->url_title;
}

sub update_score{
    my ( $self ) = @_;

    my $score = $self->_calculate_score;

    if ( $self->score != $score ){
        $self->update( {
            'score' => $score,
        } );
    }

    if ( 
        ( !$self->promoted ) 
        && ( $score >= TAN->config->{'promotion_cutoff'} )
    ){
    eval{
        $self->result_source->schema->txn_do(sub{
            $self->update({
                'promoted' => \'NOW()',
            })->discard_changes;
        });
    };
    warn "1:" . $self->promoted;

        $self->result_source->schema->trigger_event->( 'object_promoted', $self );
    }
}

sub _calculate_score{
    my ( $self ) = @_;

    my $age = ( 
        ( 
            ( DateTime->now->epoch - $self->_created->epoch ) 
            / 3600 
        ) / 24 
    ) || 1;

    $age = ceil( $age );

    if ( $age < 50 ){
# if is less than 50 days old, pretend it's 50 days old
# to stop it promoting just because it's new
        $age = 50;
    }

#weights
#   plus 4
#   minus 3
#   comments 2 
#   views 1
    my $plus = ( $self->get_column('plus') * 4 );
    my $minus = ( $self->get_column('minus') * 3 ) || 1;
    my $comments = ( $self->get_column('comments') * 2 );
    my $views = $self->get_column('views');

    my $score = ( ( $plus + $views + $comments ) - $minus ) * ( 1 / $age );

    return sprintf( "%.3f", $score );
}

1;
