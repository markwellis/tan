package TAN::Schema::Result::Object;

use strict;
use warnings;

use base 'DBIx::Class';

use DateTime;
use DateTime::Format::Human::Duration;

use POSIX;

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
__PACKAGE__->table("object");
__PACKAGE__->add_columns(qw/object_id type user_id nsfw views plus minus comments deleted score locked/);

__PACKAGE__->add_columns(
  "created" => {
      data_type => 'datetime',
      datetime_undef_if_invalid => 1,
      accessor => '_created',
  },
  "promoted" => {
      data_type => 'datetime',
      datetime_undef_if_invalid => 1,
      accessor => '_promoted',
  }
);

__PACKAGE__->set_primary_key("object_id");

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
  "TAN::Schema::Result::Comment",
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
    if ( $self->nsfw ){
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
    my $old_score = $self->score || undef;

    if ( 
        !defined( $old_score ) 
        || ( $old_score != $score ) 
    ){
        #might get a deadlock [342] - ignore in that case
        eval{
            $self->update( {
                'score' => $score,
            } );
        };
    }

    if ( 
        ( !$self->promoted ) 
        && ( $score >= 100 )
    ){
        eval{
            $self->result_source->schema->txn_do(sub{
                $self->update({
                    'promoted' => \'NOW()',
                })->discard_changes;
            });
        };

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

    if ( $age < 60 ){
#stop promoting just because it's new
        $age = 60;
    }

#weights
    my $plus = ( $self->plus * 4 );
    my $minus = ( $self->minus * 12 ) || 0;
    my $comments = ( $self->get_column('comments') * 2 );
    my $views = $self->get_column('views');

#perhaps add in type weights...

    my $score = ( ( $plus + $views + $comments ) - $minus ) * ( 1 / $age );

# make look nicer
    $score = ( $score * 100 ) - 20;
    return sprintf("%d", $score);
}

sub add_plus_minus {
    my ( $self, $type, $user_id ) = @_;

    return $self->result_source->schema->txn_do( sub {
        my $created = $self->plus_minus->add( $type, $user_id );

        #update score and things now
        $self->update( {
                plus    => $self->plus_minus->search( { type => 'plus' } )->count,
                minus   => $self->plus_minus->search( { type => 'minus' } )->count,
            } );

        $self->update_score;
        return $created;
    } );
}

1;
