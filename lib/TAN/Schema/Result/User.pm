package TAN::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
__PACKAGE__->table("user");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "username",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "join_date",
  {
    data_type => 'datetime',
    is_nullable => 0,
    datetime_undef_if_invalid => 1,
    size => 14,
    accessor => '_join_date',
  },
  "email",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "password",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 128,
  },
  "confirmed",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
  "deleted",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key("user_id");

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:y1r+PaK7ykzu5OXwbRRICw

__PACKAGE__->has_many(
  "plus_minus",
  "TAN::Schema::Result::PlusMinus",
  { "foreign.user_id" => "self.user_id" },
);

__PACKAGE__->has_many(
  "comments",
  "TAN::Schema::Result::Comments",
  { "foreign.user_id" => "self.user_id" },
);
__PACKAGE__->has_many(
  "objects",
  "TAN::Schema::Result::Object",
  { "foreign.user_id" => "self.user_id" },
);
__PACKAGE__->has_many(
  "tokens",
  "TAN::Schema::Result::UserTokens",
  { "foreign.user_id" => "self.user_id" },
);
__PACKAGE__->has_many(
  "views",
  "TAN::Schema::Result::Views",
  { "foreign.user_id" => "self.user_id" },
);
__PACKAGE__->has_many(
  "user_admin",
  "TAN::Schema::Result::UserAdmin",
  { "foreign.user_id" => "self.user_id" },
);

__PACKAGE__->many_to_many(
  "map_user_role" => "user_admin",
  "admin" 
);

sub join_date{
    my ( $self ) = @_;
    
    return TAN::Schema::Result::Object->date_ago( $self->_join_date );
}

=head2 confirm

B<@args = (undef)

=over

confirms a users token

=back

=cut
sub confirm{
    my ( $self ) = @_;

    $self->update({
        'confirmed' => 'Y',
    });
}

sub avatar{
    my ( $self, $c ) = @_;

    my $avatar_http = "@{[ $c->config->{'avatar_path'} ]}/@{[ $self->id ]}";
    my $avatar_image = "@{[ $c->path_to('root') ]}${avatar_http}";
    my $avatar_mtime;

    if ( -e $avatar_image ){
    #avatar exists
        my @stats = stat($avatar_image);
        $avatar_http = "$avatar_http/" . $stats[9];
    } else {
        $avatar_http = "@{[ $c->config->{'static_path'} ]}/images/_user.png";
    }
    
    return $avatar_http;
}

sub profile_url{
    my ( $self ) = @_;

#username can only contain word chars, so it should be safe
    return "/profile/@{[ $self->username ]}/";
}

1;
