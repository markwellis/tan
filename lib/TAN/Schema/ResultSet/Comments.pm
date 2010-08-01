package TAN::Schema::ResultSet::Comments;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

TAN::Schema::ResultSet::Comments

=head1 DESCRIPTION

Comments ResultSet

=head1 METHODS

=cut

=head2 recent_comments

B<@args = undef>

=over

gets the 20 most recent comments

=back

=cut
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

    return $recent_comments;
}

=head2 create_comment

B<@args = ($object_id, $user_id, $comment)>

=over

creates a comment 

=back

=cut
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

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
