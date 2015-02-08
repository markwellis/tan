package TAN::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class';

use Digest::SHA;
use Crypt::PBKDF2;
use Math::Random::Secure qw/irand/;
use Exception::Simple;

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
  "TAN::Schema::Result::Comment",
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

my $salt_dir = '/mnt/stuff/TAN/salt/';
sub _get_salt{
    my ( $self ) = @_;

    open my $salt_fh, '<', $salt_dir . $self->id || die "$!";
    chomp( my $salt = <$salt_fh> );
    close $salt_fh;

    return $salt;
}

sub _set_salt{
    my ( $self ) = @_;

    my $salt = unpack( 'H*', join "", ('.', '/', '_', '+', '-', '=', 0..9, 'A'..'Z', 'a'..'z')[map {irand(67)} (0..31)] );

    open my $salt_fh, '>', $salt_dir . $self->id || die "$!";
    print $salt_fh $salt;
    close $salt_fh;

    return $salt;
}

my $crypt = Crypt::PBKDF2->new(
    hash_class => 'HMACSHA2',
    hash_args => {
        sha_size => 512,
    },
    iterations => 10_000,
);

sub set_password{
    my ( $self, $password ) = @_;

    $password = Digest::SHA::sha512_hex( $password );

#reset salt, update password
    $self->update( {
        'password' => $crypt->PBKDF2_base64( $self->_set_salt, $password )
    } );
}

sub check_password{
    my ( $self, $password ) = @_;

    $password = Digest::SHA::sha512_hex( $password );

    return $crypt->PBKDF2_base64( $self->_get_salt, $password ) eq $self->password;
}

sub me_plus_minus {
    my ( $self, $object_ids, $comment_ids ) = @_;

    $object_ids //= [];
    $comment_ids //= [];

    my $plus_minuses = $self->plus_minus->search( [
            {
                object_id   => $object_ids,
            },
            {
                comment_id  => $comment_ids,
            }
        ] );

    my $me_plus_minus = {
        objects     => {},
        comments    => {},
    };
    while ( my $plus_minus = $plus_minuses->next ) {
        if ( $plus_minus->object_id ) {
            $me_plus_minus->{objects}->{ $plus_minus->object_id } = $plus_minus->type;
        }
        else {
            $me_plus_minus->{comments}->{ $plus_minus->comment_id } = $plus_minus->type;
        }
    }

    return $me_plus_minus;
}

1;
