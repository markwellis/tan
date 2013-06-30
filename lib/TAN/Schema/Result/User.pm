package TAN::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class';

use TAN::Salt;
use Digest::SHA;
use Crypt::PBKDF2;

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
        accessor => '_join_date',
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
        'confirmed' => 1,
    });
}

sub avatar{
    my ( $self, $avatar ) = @_;

    if ( !defined( $avatar) ){
        $avatar = $self->_avatar;
    }

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

sub _get_salt{
    my ( $self ) = @_;

    open my $salt_fh, '<', '/mnt/stuff/TAN/salt/' . $self->id || die "$!";
    chomp( my $salt = <$salt_fh> );
    close $salt_fh;

    return $salt;
}

# tan::salt::salt can probably be in here

sub _set_salt{
    my ( $self ) = @_;

    my $salt = TAN::Salt::salt;

    open my $salt_fh, '>', '/mnt/stuff/TAN/salt/' . $self->id || die "$!";
    print $salt_fh $salt;
    close $salt_fh;
}

#add sub new_password

sub check_password{
    my ( $self, $password ) = @_;

    $password = Digest::SHA::sha512_hex( $password );
    my $crypt = Crypt::PBKDF2->new(
        hash_class => 'HMACSHA2',
        hash_args => {
            sha_size => 512,
        },
        iterations => 10_000,
    );

    my $salt = $self->_get_salt;

    return $crypt->PBKDF2_base64( $self->_get_salt, $password ) eq $self->password;
}
1;
