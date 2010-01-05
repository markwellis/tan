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

=head2 fetch

B<@args = ($comment_id)>

=over

fetches a comment from the cache

if comment not in cache, fetch comment, bbcode parse it, cache and return

=back

=cut
sub fetch {
    my ( $self, $comment_id ) = @_;

    my $comment = $cache->get($comment_id);

    if ( !defined($comment) ) {
    # parse comment etc
        my $comment_rs = $self->find( $comment_id );
        $comment_rs->result_class('DBIx::Class::ResultClass::HashRefInflator');

        my $comment = $comment_rs->all;

#looking for something?
        $comment->{'comment'} = 'wibble';

        $cache->set($comment_id, $comment);
    }

    return $comment;    
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
