package TAN::Schema::ResultSet::Cms;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Exception::Simple;

sub index{
    my ( $self, $page ) = @_;

    my $cms_pages = $self->search( {
        'revision' => \' = (SELECT MAX(revision) FROM cms sub WHERE me.url = sub.url)',
    }, {
        'page' => $page,
        'rows' => 50,
        'group_by' => 'url',
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
