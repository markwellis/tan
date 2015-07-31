package TAN::Schema::ResultSet::UserTokens;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Digest::SHA;
use Time::HiRes qw/time/;

sub new_token{
    my ( $self, $user_id, $type ) = @_;

    my $token = Digest::SHA::sha512_hex( '4234fdgg$£dsfsdf$$"%£SDFsdfxcv@@;~/.' . ( rand(30) * time() ) );

    $self->create({
        'token' => $token,
        'type' => $type,
        'user_id' => $user_id,
        'expires' => \"(current_timestamp + interval '5' day)",
    });

    return $token;
}

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

sub clean{
    my ( $self ) = @_;
    
    return $self->search({
        'expires' => {
            '<' => \'NOW()',
        },
    })->delete;
}

1;
