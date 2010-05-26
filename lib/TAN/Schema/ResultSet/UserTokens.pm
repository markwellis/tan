package TAN::Schema::ResultSet::UserTokens;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Digest::SHA;
use Time::HiRes qw/time/;

=head1 NAME

TAN::Schema::ResultSet::UserTokens

=head1 DESCRIPTION

UserTokens ResultSet

=head1 METHODS

=cut

=head2 new_tokene

B<@args = ($user_id, $type)

=over

creates a new token for $user_id of $type and returns $token

=back

=cut

sub new_token{
    my ( $self, $user_id, $type ) = @_;

    my $token = Digest::SHA::sha512_hex( '4234fdgg$£dsfsdf$$"%£SDFsdfxcv@@;~/.' . ( rand(30) * time() ) );

    $self->create({
        'token' => $token,
        'type' => $type,
        'user_id' => $user_id,
        'expires' => \'DATE_ADD(NOW(), INTERVAL 5 DAY)',
    });

    return $token;
}

=head2 compare

B<@args = ($user_id, $token, $token_type)

=over

returns true if $token for $user_id of $type matches

=back

=cut

sub compare{
    my ( $self, $user_id, $token, $type, $no_delete ) = @_;
    
    return undef if ( !$user_id || !$token || !$type );

    my $token_rs = $self->search({
        'user_id' => $user_id,
        'token' => $token,
        'type' => $type,
        'expires' => {
            '>' => \'NOW()',
        },
    });

    #clean expired tokens
    $self->clean();

    if ( $token_rs->count ){
        if ( !$no_delete ){
        #delete token
            $token_rs->delete;
        }

        return $token_rs;
    } else {
        return undef;
    }
}

=head2 clean

B<@args = (undef)

=over

deletes expired tokens

=back

=cut

sub clean{
    my ( $self ) = @_;
    
    return $self->search({
        'expires' => {
            '<' => \'NOW()',
        },
    })->delete;
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
