package TAN::Schema::ResultSet::User;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Digest::SHA;

=head1 NAME

TAN::Schema::ResultSet::User

=head1 DESCRIPTION

User ResultSet

=head1 METHODS

=cut

=head2 username_exists

B<@args = ($username)

=over

returns true if a username exists

=back

=cut

sub username_exists{
    my ( $self, $username ) = @_;
    
    return $self->search({
        'username' => {
            'like' => $username
        },
    })->count || undef;
}

=head2 email_exists

B<@args = ($email)

=over

returns true if the email exists

=back

=cut

sub email_exists{
    my ( $self, $email ) = @_;
    
    return $self->search({
        'email' => {
            'like' => $email
        },
    })->count || undef;
}

=head2 by_email

B<@args = ($email)

=over

returns a user by email

=back

=cut

sub by_email{
    my ( $self, $email ) = @_;
    
    return $self->find({
        'email' => $email,
    }) || undef;
}

=head2 new_user

B<@args = ($username, $password, $email)

=over

registers a new user

=back

=cut
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

=head2 change_password

B<@args = ($user_id, $password)

=over

changes a users password

=back

=cut
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

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;