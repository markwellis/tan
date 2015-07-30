package TAN::Schema::ResultSet::Comment;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Tie::Hash::Indexed;

sub create_comment {
    my ( $self, $object_id, $user_id, $comment ) = @_;

    $self->result_source->schema->txn_do( sub {
        my $comment_no = $self->search({
            'user_id' => $user_id,
        })->count + 1;

        my $comment_rs = $self->create({
            'user_id' => $user_id,
            'comment' => $comment,
            'object_id' => $object_id,
            'number' => $comment_no || 1,
        });

        $comment_rs->object->update( {
            comments => $comment_rs->object->comments->visible->count,
        } );

        return $comment_rs;
    } );
}

use Tie::Hash::Indexed;

sub recent {
    my ( $self ) = @_;

    my $recent_comments = $self->search(
        {
            'me.deleted'     => 0,
            'object.deleted' => 0,
        },
        {
            rows     => 20,
            order_by => { -desc => 'me.created' },
            prefetch => [
                'user',
                {
                    'object' => [ qw/link picture blog poll video/ ],
                },
            ],
        }
    );

    tie my %grouped_comments, 'Tie::Hash::Indexed';
    while ( my $comment = $recent_comments->next ) {
        $grouped_comments{ $comment->object_id } //= [];

        push @{$grouped_comments{ $comment->object_id } }, $comment;
    }
    return \%grouped_comments;
}

sub visible {
    $_[0]->search( {
        deleted => 0,
    } );
}

1;
