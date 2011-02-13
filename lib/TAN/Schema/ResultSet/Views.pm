package TAN::Schema::ResultSet::Views;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub whos_online {
    my ( $self ) = @_;

    my $who = $self->result_source->schema->cache->get("whos_online");

    if ( !$who ){
        @{$who} = $self->search({
            'created' => {
                '>' => \'DATE_SUB(NOW(), INTERVAL 5 MINUTE)',
            },
        },{
            'select' => [\'DISTINCT(me.user_id)', 'user.username'],
            'as' => ['user_id', 'username'],
            'join' => 'user',
            'rows' => 30,
            'prefetch' => 'user',
        })->all;

        $self->result_source->schema->cache->set("whos_online", $who, 60);
    }

    return $who;
}

sub create_comment {
    my ( $self, $object_id, $user_id, $comment ) = @_;

    my $comment_no = $self->search({
        'user_id' => $user_id,
    })->count;

    my $comment_rs = $self->create({
        'user_id' => $user_id,
        'comment' => $comment,
        'created' => \'NOW()',
        'object_id' => $object_id,
        'number' => $comment_no || 1,
    });

    return $comment_rs;
}

1;
