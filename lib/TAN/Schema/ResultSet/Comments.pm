package TAN::Schema::ResultSet::Comments;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Tie::Hash::Indexed;

sub create_comment {
    my ( $self, $object_id, $user_id, $comment ) = @_;

#this could be a trigger
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
