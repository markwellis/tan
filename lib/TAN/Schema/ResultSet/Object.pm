package TAN::Schema::ResultSet::Object;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 index
gets the stuff for the index
=cut
sub index {
    my ($self, $location, $page, $upcoming, $order) = @_;
    
    my ($type, $search, $prefetch);
    
    if ($upcoming){
        $search = \'= 0';
        $order ||= 'me.created'
    } else {
        $search = \'!= 0';
        $order ||= 'me.promoted';
        $order = 'me.promoted' if ($order eq 'date');
    }

    if ($location eq 'all'){
        $type = ['link', 'blog'];
    } else {
        $type = $location;
    }

    return $self->search({
        'promoted' => $search,
        'type' => $type,
    },{
        '+select' => [
            { 'unix_timestamp' => 'me.created' },
            { 'unix_timestamp' => 'me.promoted' },
            \'(SELECT COUNT(*) FROM views WHERE views.object_id = me.object_id) views',
            \'(SELECT COUNT(*) FROM comments WHERE comments.object_id = me.object_id) comments',
            \'(SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = me.object_id AND type="plus") plus',
            \'(SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = me.object_id AND type="minus") minus',
        ],
        '+as' => ['created', 'promoted', 'views', 'comments', 'plus', 'minus'],
        'order_by' => {
            -desc => [$order],
        },
        'page' => $page,
        'rows' => 27,
        'prefetch' => [$type, 'user'],
    });
}

1;
