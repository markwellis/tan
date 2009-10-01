package TAN::Schema::ResultSet::ObjectDetails;

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
        $order ||= 'date'
    } else {
        $search = { '>' => 0 };
        $order ||= 'promoted'
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
        'order_by' => "${order} desc",
        'page' => $page,
        'rows' => 27,
        'join' => $type,
        'prefetch' => $type,
    });
}

1;
