package TAN::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
__PACKAGE__->table("user");
__PACKAGE__->add_columns(qw/user_id username email password confirmed deleted paypal tcs/);
__PACKAGE__->add_columns(
    "avatar" => {
        accessor => '_avatar',
    },
    "join_date" => {
        data_type => 'datetime',
        datetime_undef_if_invalid => 1,
    },
);
__PACKAGE__->set_primary_key("user_id");

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
    my ( $self ) = @_;

    my $avatar = $self->_avatar;

    if ( !$avatar ){
        return TAN->config->{'static_path'} . '/images/_user.png';
    }

    return TAN->config->{'avatar_path'} . '/' . $self->id . '/' . $avatar;
}

sub profile_url{
    my ( $self ) = @_;

#username can only contain word chars, so it should be safe
    return "/profile/@{[ $self->username ]}/";
}

1;
