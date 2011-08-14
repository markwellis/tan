package TAN::Schema::ResultSet::Cms;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Exception::Simple;

sub index{
    my ( $self, $page ) = @_;

    my $cms_pages = $self->search( {}, {
        'page' => $page,
        'rows' => 50,
        'order_by' => {
            '-desc' => 'me.created',
        },
    } );

    if ( !$cms_pages ){
        Exception::Simple->throw;
    }

    return $cms_pages;
}

1;
