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
        $order ||= 'object.created'
    } else {
        $search = { '!=' => 0 };
        $order ||= 'object.promoted';
        $order = 'object.promoted' if ($order eq 'date');
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
            { 'unix_timestamp' => 'created' },
            { 'unix_timestamp' => 'promoted' },
        ],
        'as' => ['created', 'promoted'],
        'order_by' => {
            -desc => [$order],
        },
        'page' => $page,
        'rows' => 27,
#        'join' =>  [$type, 'user'],
#        'prefetch' => [$type, 'user'],
    });
}

1;
