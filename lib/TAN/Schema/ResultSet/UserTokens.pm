package TAN::Schema::ResultSet::UserTokens;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

TAN::Schema::ResultSet::UserTokens

=head1 DESCRIPTION

UserTokens ResultSet

=head1 METHODS

=cut

=head2 compare

B<@args = ($user_id, $token, $token_type)

=over

returns true if $token for $user_id of $type matches

=back

=cut

sub compare{
    my ( $self, $user_id, $token, $type ) = @_;
    
    return undef if ( !$user_id || !$token || !$type );

    return $self->search({
        'user_id' => $user_id,
        'token' => $token,
        'type' => $type,
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
# return new user
    my $new_user = $self->create({
        'username' => $username,
        'join_date' => \'NOW()',
        'email' => $email,
        'password' => Digest::SHA::sha512_hex($password),
    });

    my $token = Digest::SHA::sha512_hex( '4234fdgg$£dsfsdf$$"%£SDFsdfxcv@@;~/.' . ( rand(30) * time() ) );
    $new_user->tokens->create({
        'token' => $token,
        'type' => 'reg',
        'expires' => \'DATE_ADD(NOW(), INTERVAL 5 DAY)',
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
