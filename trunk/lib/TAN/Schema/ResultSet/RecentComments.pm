package TAN::Schema::ResultSet::RecentComments;
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use Tie::Hash::Indexed;

sub grouped {
    my ( $self ) = @_;

    local $DBIx::Class::ResultSourceHandle::thaw_schema = $self->result_source->schema;

    my $recent_comments = $self->result_source->schema->cache->get('recent_comments');

    if ( !$recent_comments ){
        tie my %grouped_comments, 'Tie::Hash::Indexed';
        foreach my $comment ( $self->all ){
            if ( !defined($grouped_comments{$comment->object_id}) ){
                $grouped_comments{$comment->object_id} = [];
            }
            push(@{$grouped_comments{$comment->object_id}}, $comment);
        }
        $recent_comments = \%grouped_comments;

        $self->result_source->schema->cache->set('recent_comments', $recent_comments, 600 );
    }

    return $recent_comments;
}

1;
