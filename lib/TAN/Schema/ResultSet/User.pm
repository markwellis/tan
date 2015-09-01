package TAN::Schema::ResultSet::User;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub username_exists{
    my ( $self, $username ) = @_;

    return $self->search(
        [
            \[ 'LOWER(username) = LOWER(?)', $username ],
        ],
    )->count || undef;
}

sub email_exists{
    my ( $self, $email ) = @_;

    return $self->search(
        [
            \[ 'LOWER(email) = LOWER(?)', $email ],
        ],
    )->count || undef;
}

sub by_email{
    my ( $self, $email ) = @_;

    return $self->find(
        [
            \[ 'LOWER(email) = LOWER(?)', $email ],
        ],
    );
}

sub new_user{
    my ( $self, $username, $password, $email ) = @_;

    $self->result_source->schema->txn_do( sub {
        my $new_user = $self->create({
            username  => $username,
            join_date => \'NOW()',
            email     => $email,
            password  => 'this is not the password', #horrible hack. tan's code is shit
        });

        $new_user->set_password( $password );
        $new_user->insert;

        return undef if ( !defined($new_user) );
        my $token = $new_user->tokens->new_token($new_user->id, 'reg');

        return $new_user;
    } );
}

1;
