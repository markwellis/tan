package TAN::Schema::ResultSet::Comments;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Tie::Hash::Indexed;

sub recent_comments {
    my ( $self, $count ) = @_;

    local $DBIx::Class::ResultSourceHandle::thaw_schema = $self->result_source->schema;

    my $recent_comments = $self->result_source->schema->cache->get('recent_comments');

    if ( !$recent_comments ){

        @{$recent_comments} = $self->search({
            'me.deleted' => 'N'
        },{
            'order_by' =>  {
                '-desc' => 'me.created',
            },
            'rows' => $count,
            'prefetch' => {
                'user' => [],
                'object' => [
                    'link',
                    'picture',
                    'blog',
                    'poll',
                ],
            },
        })->all;

        $self->result_source->schema->cache->set('recent_comments', $recent_comments, 600 );
    }

    tie my %grouped_comments, 'Tie::Hash::Indexed';
    foreach my $comment ( @{$recent_comments} ){
        if ( !defined($grouped_comments{$comment->object_id}) ){
            $grouped_comments{$comment->object_id} = [];
        }
        push(@{$grouped_comments{$comment->object_id}}, $comment);
    }

    return \%grouped_comments;
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
