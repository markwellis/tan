package TAN::Schema::ResultSet::Comments;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Cache::FastMmap;

my $cache = Cache::FastMmap->new(
    'expire_time' => 0,
    'cache_size' => '200m',
    'share_file'=>'/tmp/comment_cache',
);

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
    my ( $self ) = @_;

    return $self->search({
        'me.deleted' => 'N'
    },{
        'order_by' =>  {
            '-desc' => 'me.created',
        },
        'rows' => 20,
        'prefetch' => {
            'user' => [],
            'object' => [
                'link',
                'picture',
                'blog',
            ],
        },
    });
}

=head2 create_comment

B<@args = ($object_id, $user_id, $comment, $rev = 0)>

=over

creates a comment 

=back

=cut
sub create_comment {
    my ( $self, $object_id, $user_id, $comment, $rev ) = @_;

    my $comment_rs = $self->create({
        'user_id' => $user_id,
        'comment' => $comment,
        'created' => \'NOW()',
        'object_id' => $object_id,
        'rev' => $rev || 0,
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
