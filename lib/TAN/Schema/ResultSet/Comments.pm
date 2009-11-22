package TAN::Schema::ResultSet::Comments;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 recent_comments
gets the recent comments
=cut
sub recent_comments {
    my $self = shift;

    return $self->search({
        'me.deleted' => 'N'
    },{
        'order_by' =>  {
            '-desc' => 'me.created',
        },
        'rows' => 20,
        'prefetch' => ['user', 'object'],
    });
}

1;
