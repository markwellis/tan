package TAN::Schema::Result::Object;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("object");
__PACKAGE__->add_columns(
  "object_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "type",
  { data_type => "ENUM", default_value => undef, is_nullable => 0, size => 7 },
  "created",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
  "promoted",
  {
    data_type => "TIMESTAMP",
    default_value => undef,
    is_nullable => 1,
    size => 14,
    datetime_undef_if_invalid => 1,
  },
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "nsfw",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key("object_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zHtxjN50TOUzr4b7Jb877A

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

my $url_title = qr/[^a-zA-Z0-9]/;
sub url_title{
    my ( $self ) = @_;

    my $object_meta = eval ( '$self->' . $self->type );

    return '' if ( !defined($object_meta) );

    my $title = $object_meta->title;
    if ( $self->nsfw eq 'Y' ){
        $title .= '-NSFW';
    }

    $title =~ s/$url_title/-/g;
    return $title;
}

sub url{
    my ( $self ) = @_;

    return "/view/" . $self->type . '/' 
        . $self->object_id .'/' 
        . $self->url_title;
}

=head2 promote

B<@args = (undef)>

=over

promotes object

=back

=cut
sub promote{
    my ( $self ) = @_;
#so somethings been updated, do some tiwtter shit n that

    $self->update({
        'promoted' => \'NOW()',
    });
}

1;
