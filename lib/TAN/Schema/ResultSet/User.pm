package TAN::Schema::ResultSet::User;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

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
# set password
# create tokens
# return new user
    my $new_user = $self->create({
        'username' => $username,
        'join_date' => \'NOW()',
        'email' => $email,
    });

    $new_user->set_password( $password );

    return undef if ( !defined($new_user) );
    my $token = $new_user->tokens->new_token($new_user->id, 'reg');

    return $new_user;
}

1;
