package TAN::Schema::ResultSet::User;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Digest::SHA;
use Time::HiRes qw/time/;

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
# return new user or error string
    $password = Digest::SHA::sha512_hex($password);
    my $new_user = $self->create({
        'username' => $username,
        'join_date' => \'NOW()',
        'email' => $email,
        'password' => $password,
    });

    my $token = Digest::SHA::sha512_hex( '4234fdgg$£dsfsdf$$"%£SDFsdfxcv@@;~/.' . ( rand(30) * time() ) );
    $new_user->tokens->create({
        'token' => $token,
        'type' => 'reg',
    });

    return $new_user;
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
