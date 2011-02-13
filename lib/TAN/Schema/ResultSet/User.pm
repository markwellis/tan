package TAN::Schema::ResultSet::User;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Digest::SHA;

sub username_exists{
    my ( $self, $username ) = @_;
    
    return $self->search({
        'username' => {
            'like' => $username
        },
    })->count || undef;
}

sub email_exists{
    my ( $self, $email ) = @_;
    
    return $self->search({
        'email' => {
            'like' => $email
        },
    })->count || undef;
}

sub by_email{
    my ( $self, $email ) = @_;
    
    return $self->find({
        'email' => $email,
    }) || undef;
}

sub new_user{
    my ( $self, $username, $password, $email ) = @_;
    
# create new user
# create tokens
# return new user
    my $new_user = $self->create({
        'username' => $username,
        'join_date' => \'NOW()',
        'email' => $email,
        'password' => Digest::SHA::sha512_hex($password),
    });

    return undef if ( !defined($new_user) );
    my $token = $new_user->tokens->new_token($new_user->id, 'reg');

    return $new_user;
}

sub change_password{
    my ( $self, $user_id, $password ) = @_;

    my $user = $self->find({
        'user_id' => $user_id,
    });

    return undef if ( !defined($user) );

    $user->update({
        'password' => Digest::SHA::sha512_hex($password),
    });

    return 1;
}

1;
